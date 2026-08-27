import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:loahstudio/model/agendamento_model.dart';
import 'package:loahstudio/model/servico_model.dart';
import 'package:loahstudio/model/site_config_model.dart';

class AgendamentoController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _servicosRef => _firestore.collection('servicos');
  CollectionReference get _agendamentosRef => _firestore.collection('agendamentos');

  static const List<String> diasSemana = [
    'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado', 'domingo'
  ];

  Stream<List<Servico>> streamServicosDisponiveis() {
    return _servicosRef.where('disponivel', isEqualTo: true).snapshots().map(
        (snap) => snap.docs.map((d) => Servico.fromDoc(d)).toList());
  }


  /// as configurações do site (hero, horário de funcionamento, etc).
  Future<HorarioFuncionamento> fetchHorarioFuncionamento() async {
  try {
    final doc = await _firestore.collection('configuracoes').doc('site_config').get();
    if (!doc.exists) return const HorarioFuncionamento();
    final data = doc.data();
    return HorarioFuncionamento.fromMap(
        data?['horarioFuncionamento'] as Map<String, dynamic>?);
  } catch (e) {
    debugPrint('Erro ao carregar horário de funcionamento: $e');
    return const HorarioFuncionamento();
  }
}

  Future<List<Agendamento>> fetchAgendamentosPorData(DateTime data) async {
    try {
      final inicio = DateTime(data.year, data.month, data.day);
      final fim = inicio.add(const Duration(days: 1));
      final snap = await _agendamentosRef
          .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('data', isLessThan: Timestamp.fromDate(fim))
          .where('status', whereIn: ['pendente', 'confirmado'])
          .get();
      return snap.docs.map((d) => Agendamento.fromDoc(d)).toList();
    } catch (e) {
      debugPrint('Erro ao carregar agendamentos existentes: $e');
      return [];
    }
  }

  /// Gera as datas dos próximos [dias] dias em que o estúdio funciona,
  /// segundo os dias da semana configurados.
  List<DateTime> gerarDatasDisponiveis(HorarioFuncionamento horario, {int dias = 30, int limite = 14}) {
    final resultado = <DateTime>[];
    final hoje = DateTime.now();
    for (int i = 1; i <= dias && resultado.length < limite; i++) {
      final data = DateTime(hoje.year, hoje.month, hoje.day).add(Duration(days: i));
      final diaSemana = diasSemana[data.weekday - 1];
      if (horario.diasFuncionamento.contains(diaSemana)) {
        resultado.add(data);
      }
    }
    return resultado;
  }



  /// Cria o agendamento, revalidando conflitos no momento da escrita —
  /// importante porque outro cliente pode ter reservado o mesmo horário
  /// entre o momento em que a lista foi gerada e o clique em "Confirmar".
  Future<bool> criarAgendamento(Agendamento agendamento) async {
    try {
      final existentes = await fetchAgendamentosPorData(agendamento.data);
      final inicioNovo = parseHora(agendamento.horaInicio);
      final fimNovo = parseHora(agendamento.horaFim);
      final conflita = existentes.any((a) {
        final aInicio = parseHora(a.horaInicio);
        final aFim = parseHora(a.horaFim);
        return inicioNovo < aFim && fimNovo > aInicio;
      });
      if (conflita) return false;

      await _agendamentosRef.add(agendamento.toMap());
      return true;
    } catch (e) {
      debugPrint('Erro ao criar agendamento: $e');
      return false;
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
  required List<Agendamento> agendamentosExistentes,
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
      final conflita = agendamentosExistentes.any((a) {
        final aInicio = parseHora(a.horaInicio);
        final aFim = parseHora(a.horaFim);
        return cursor < aFim && fimSlot > aInicio;
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
class HorariosAgrupados {
  final List<String> manha;
  final List<String> tarde;
  final List<String> noite;

  const HorariosAgrupados({
    this.manha = const [],
    this.tarde = const [],
    this.noite = const [],
  });

  bool get isEmpty => manha.isEmpty && tarde.isEmpty && noite.isEmpty;
}