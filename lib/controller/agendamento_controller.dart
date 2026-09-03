// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:loahstudio/model/agendamento_model.dart';
import 'package:loahstudio/model/servico_model.dart';
import 'package:loahstudio/model/site_config_model.dart';

/// Resultado da tentativa de criar um agendamento — permite à UI
/// distinguir "conflito de horário" (o utilizador deve escolher outro)
/// de "erro genérico" (rede, servidor, etc).
enum AgendamentoResultado { sucesso, conflito, erro }

class AgendamentoController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _regiao = 'europe-west1';

  CollectionReference get _servicosRef => _firestore.collection('servicos');
  CollectionReference get _agendamentosRef => _firestore.collection('agendamentos');
  CollectionReference get _horariosOcupadosRef => _firestore.collection('horariosOcupados');

  static const List<String> diasSemana = [
    'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado', 'domingo'
  ];

  Stream<List<Servico>> streamServicosDisponiveis() {
    return _servicosRef.where('disponivel', isEqualTo: true).snapshots().map(
        (snap) => snap.docs.map((d) => Servico.fromDoc(d)).toList());
  }

  Future<HorarioFuncionamento> fetchHorarioFuncionamento() async {
    try {
      final doc = await _firestore.collection('configuracoes').doc('site_config').get();
      if (!doc.exists) return const HorarioFuncionamento();
      final data = doc.data();
      return HorarioFuncionamento.fromMap(data?['horarioFuncionamento'] as Map<String, dynamic>?);
    } catch (e) {
      debugPrint('Erro ao carregar horário de funcionamento: $e');
      return const HorarioFuncionamento();
    }
  }

  /// Busca todos os serviços (incluindo os já desativados), para mostrar
  /// nome/imagem corretos mesmo em agendamentos antigos cujo serviço já
  /// não esteja mais disponível hoje. Fetch único, não stream — a lista
  /// de serviços de um estúdio é pequena e não precisa de tempo real aqui.
  Future<Map<String, Servico>> fetchServicosMap() async {
    try {
      final snap = await _servicosRef.get();
      return {for (final d in snap.docs) d.id: Servico.fromDoc(d)};
    } catch (e) {
      debugPrint('Erro ao carregar mapa de serviços: $e');
      return {};
    }
  }

  /// Lê da coleção pública (sem PII) 'horariosOcupados' — usado apenas
  /// para mostrar ao cliente quais horários já estão ocupados na tela.
  /// A verificação real de conflito (que decide se o agendamento é
  /// criado) acontece do lado do servidor, na Cloud Function
  /// 'criarAgendamento', dentro de uma transação — nunca aqui.
  Future<List<HorarioOcupado>> fetchHorariosOcupadosPorData(DateTime data) async {
    try {
      final inicio = DateTime(data.year, data.month, data.day);
      final fim = inicio.add(const Duration(days: 1));
      final snap = await _horariosOcupadosRef
          .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('data', isLessThan: Timestamp.fromDate(fim))
          .get();
      return snap.docs.map((d) {
        final m = d.data() as Map<String, dynamic>;
        return HorarioOcupado(horaInicio: m['horaInicio'] as String, horaFim: m['horaFim'] as String);
      }).toList();
    } catch (e) {
      debugPrint('Erro ao carregar horários ocupados: $e');
      return [];
    }
  }

  List<DateTime> gerarDatasDisponiveis(HorarioFuncionamento horario, {int dias = 30, int limite = 14}) {
    final resultado = <DateTime>[];
    final hoje = DateTime.now();
    for (int i = 1; i <= dias && resultado.length < limite; i++) {
      final data = DateTime(hoje.year, hoje.month, hoje.day).add(Duration(days: i));
      final diaSemana = diasSemana[data.weekday - 1];
      if (horario.diasFuncionamento.contains(diaSemana)) resultado.add(data);
    }
    return resultado;
  }

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
  bool get isUserLoggedIn => FirebaseAuth.instance.currentUser != null;

  /// Lista reativa dos agendamentos do utilizador logado. Filtra por
  /// clienteId — tem de ser assim, e não por email, porque a Firestore
  /// Rule exige que a própria query já traga esse filtro para autorizar
  /// a leitura em lote.
  Stream<List<Agendamento>> streamMeusAgendamentos() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);
    return _agendamentosRef
        .where('clienteId', isEqualTo: uid)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Agendamento.fromDoc(d)).toList());
  }

  Future<bool> cancelarAgendamento(String agendamentoId) async {
    try {
      final batch = _firestore.batch();
      batch.update(_agendamentosRef.doc(agendamentoId), {'status': 'cancelado'});

      // Liberta o horário no espelho público, se ainda existir.
      final ocupado = await _horariosOcupadosRef.where('agendamentoId', isEqualTo: agendamentoId).limit(1).get();
      if (ocupado.docs.isNotEmpty) batch.delete(ocupado.docs.first.reference);

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Erro ao cancelar agendamento: $e');
      return false;
    }
  }

  /// Cria o agendamento chamando a Cloud Function 'criarAgendamento',
  /// que faz a verificação de conflito e a escrita dentro de uma
  /// transação Firestore no servidor — isto elimina a janela de corrida
  /// que existia ao fazer leitura+escrita em dois passos a partir do
  /// cliente. O envio do email de "recebido" acontece automaticamente
  /// via trigger 'onAgendamentoCriado', não precisa de ser chamado aqui.
  Future<AgendamentoResultado> criarAgendamento(Agendamento agendamento) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: _regiao).httpsCallable('criarAgendamento');

      await callable.call({
        'clienteNome': agendamento.clienteNome,
        'clienteEmail': agendamento.clienteEmail,
        'clienteTelefone': agendamento.clienteTelefone,
        'observacao': agendamento.observacao,
        'servicoId': agendamento.servicoId,
        'servicoNome': agendamento.servicoNome,
        'servicoPreco': agendamento.servicoPreco,
        'servicoDuracaoMinutos': agendamento.servicoDuracaoMinutos,
        'data': agendamento.data.toIso8601String(),
        'horaInicio': agendamento.horaInicio,
        'horaFim': agendamento.horaFim,
      });

      return AgendamentoResultado.sucesso;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro ao criar agendamento: ${e.code} — ${e.message}');
      if (e.code == 'already-exists') return AgendamentoResultado.conflito;
      return AgendamentoResultado.erro;
    } catch (e) {
      debugPrint('Erro ao criar agendamento: $e');
      return AgendamentoResultado.erro;
    }
  }

  static int parseHora(String hora) {
    final partes = hora.split(':');
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }

  static String formatHora(int minutos) {
    final h = (minutos ~/ 60).toString().padLeft(2, '0');
    final m = (minutos % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  HorariosAgrupados gerarHorariosAgrupados({
    required HorarioFuncionamento horario,
    required int duracaoMinutos,
    required DateTime data,
    required List<HorarioOcupado> horariosOcupados,
  }) {
    final diaSemana = diasSemana[data.weekday - 1];
    if (!horario.diasFuncionamento.contains(diaSemana) || duracaoMinutos <= 0) {
      return const HorariosAgrupados();
    }

    final agora = DateTime.now();
    final isHoje = data.year == agora.year && data.month == agora.month && data.day == agora.day;
    final minutosAgora = agora.hour * 60 + agora.minute;

    List<String> gerarParaTurno(Turno turno) {
      if (!turno.ativo) return [];
      final inicioMin = parseHora(turno.horaInicio);
      final fimMin = parseHora(turno.horaFim);
      final intervalo = horario.intervaloAgendamentoMinutos;
      final slots = <String>[];
      var cursor = inicioMin;

      while (cursor + duracaoMinutos <= fimMin) {
        final fimSlot = cursor + duracaoMinutos;
        final passado = isHoje && cursor <= minutosAgora;
        final conflita = horariosOcupados.any((o) {
          final oInicio = parseHora(o.horaInicio);
          final oFim = parseHora(o.horaFim);
          return cursor < oFim && fimSlot > oInicio;
        });
        if (!passado && !conflita) slots.add(formatHora(cursor));
        cursor += duracaoMinutos + intervalo;
      }
      return slots;
    }

    return HorariosAgrupados(
      manha: gerarParaTurno(horario.manha),
      tarde: gerarParaTurno(horario.tarde),
      noite: gerarParaTurno(horario.noite),
    );
  }
}

class HorarioOcupado {
  final String horaInicio;
  final String horaFim;
  HorarioOcupado({required this.horaInicio, required this.horaFim});
}

class HorariosAgrupados {
  final List<String> manha;
  final List<String> tarde;
  final List<String> noite;
  const HorariosAgrupados({this.manha = const [], this.tarde = const [], this.noite = const []});
  bool get isEmpty => manha.isEmpty && tarde.isEmpty && noite.isEmpty;
}