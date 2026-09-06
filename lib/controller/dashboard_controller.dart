import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:loahstudio/model/dashboard_stats_model.dart';

/// Calcula as estatísticas do dashboard admin a partir dos dados reais.
/// Faz fetch único (não stream) — o dashboard é atualizado por
/// pull-to-refresh, não precisa de tempo real.
class DashboardController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _agendamentosRef => _firestore.collection('agendamentos');
  CollectionReference get _pedidosRef => _firestore.collection('pedidos');
  CollectionReference get _clientesRef => _firestore.collection('clientes');

  // Status que contam como "venda" efetiva em cada coleção.
  static const List<String> _statusAgendamentoConta = ['confirmado', 'concluido'];
  static const List<String> _statusPedidoConta = ['confirmado', 'preparando', 'entregue'];
  static const String _statusCancelado = 'cancelado';

  static const List<String> _mesesAbrev = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
  static const List<String> _diasSemanaAbrev = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  Future<DashboardStats> fetchDashboardStats() async {
    try {
      final resultados = await Future.wait([
        _agendamentosRef.get(),
        _pedidosRef.get(),
        _clientesRef.where('role', isEqualTo: 'user').get(),
      ]);

      final agendamentosSnap = resultados[0];
      final pedidosSnap = resultados[1];
      final clientesSnap = resultados[2];

      // Exclui cancelados logo à partida — não contam em nenhum lado.
      final agendamentos = agendamentosSnap.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .where((m) => (m['status'] as String?) != _statusCancelado)
          .toList();

      final pedidos = pedidosSnap.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .where((m) => (m['status'] as String?) != _statusCancelado)
          .toList();

      final totalVendasServicos = agendamentos
          .where((m) => _statusAgendamentoConta.contains(m['status']))
          .fold<double>(0, (soma, m) => soma + ((m['servicoPreco'] as num?)?.toDouble() ?? 0));

      final totalVendasEncomendas = pedidos
          .where((m) => _statusPedidoConta.contains(m['status']))
          .fold<double>(0, (soma, m) => soma + ((m['valorTotal'] as num?)?.toDouble() ?? 0));

      return DashboardStats(
        totalVendasServicos: totalVendasServicos,
        totalVendasEncomendas: totalVendasEncomendas,
        totalClientes: clientesSnap.docs.length,
        totalAgendamentos: agendamentos.length,
        rendimentoSemana: _calcularRendimentoPorDia(agendamentos, pedidos, dias: 7),
        rendimentoMes: _calcularRendimentoMes(agendamentos, pedidos),
        rendimentoTudo: _calcularRendimentoTudo(agendamentos, pedidos),
        topServicos: _calcularTopServicos(agendamentos),
        topProdutos: _calcularTopProdutos(pedidos),
      );
    } catch (e) {
      debugPrint('Erro ao carregar estatísticas do dashboard: $e');
      return DashboardStats.vazio();
    }
  }

  DateTime? _parseData(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  double _valorSeContar(Map<String, dynamic> m, {required bool isAgendamento}) {
    final status = m['status'] as String?;
    if (isAgendamento) {
      if (!_statusAgendamentoConta.contains(status)) return 0;
      return (m['servicoPreco'] as num?)?.toDouble() ?? 0;
    }
    if (!_statusPedidoConta.contains(status)) return 0;
    return (m['valorTotal'] as num?)?.toDouble() ?? 0;
  }

  double _somarNoIntervalo(
    List<Map<String, dynamic>> agendamentos,
    List<Map<String, dynamic>> pedidos,
    DateTime inicio,
    DateTime fim,
  ) {
    double total = 0;
    for (final a in agendamentos) {
      final data = _parseData(a['data']);
      if (data != null && !data.isBefore(inicio) && data.isBefore(fim)) {
        total += _valorSeContar(a, isAgendamento: true);
      }
    }
    for (final p in pedidos) {
      final data = _parseData(p['criadoEm']);
      if (data != null && !data.isBefore(inicio) && data.isBefore(fim)) {
        total += _valorSeContar(p, isAgendamento: false);
      }
    }
    return total;
  }

  /// Últimos [dias] dias (incluindo hoje), um ponto por dia.
  List<RendimentoPonto> _calcularRendimentoPorDia(
    List<Map<String, dynamic>> agendamentos,
    List<Map<String, dynamic>> pedidos, {
    required int dias,
  }) {
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final diasRef = List.generate(dias, (i) => inicioHoje.subtract(Duration(days: dias - 1 - i)));

    return diasRef.map((dia) {
      final total = _somarNoIntervalo(agendamentos, pedidos, dia, dia.add(const Duration(days: 1)));
      return RendimentoPonto(label: _diasSemanaAbrev[dia.weekday - 1], valor: total);
    }).toList();
  }

  /// Mês atual, um ponto por dia (do dia 1 até hoje).
  List<RendimentoPonto> _calcularRendimentoMes(
    List<Map<String, dynamic>> agendamentos,
    List<Map<String, dynamic>> pedidos,
  ) {
    final hoje = DateTime.now();
    final inicioMes = DateTime(hoje.year, hoje.month, 1);
    final diasDecorridos = hoje.day;
    final diasRef = List.generate(diasDecorridos, (i) => inicioMes.add(Duration(days: i)));

    return diasRef.map((dia) {
      final total = _somarNoIntervalo(agendamentos, pedidos, dia, dia.add(const Duration(days: 1)));
      return RendimentoPonto(label: '${dia.day}', valor: total);
    }).toList();
  }

  /// Últimos 12 meses (incluindo o atual), um ponto por mês.
  List<RendimentoPonto> _calcularRendimentoTudo(
    List<Map<String, dynamic>> agendamentos,
    List<Map<String, dynamic>> pedidos,
  ) {
    final hoje = DateTime.now();
    final mesesRef = List.generate(12, (i) => DateTime(hoje.year, hoje.month - 11 + i, 1));

    return mesesRef.map((mesRef) {
      final fimMes = DateTime(mesRef.year, mesRef.month + 1, 1);
      final total = _somarNoIntervalo(agendamentos, pedidos, mesRef, fimMes);
      return RendimentoPonto(label: _mesesAbrev[mesRef.month - 1], valor: total);
    }).toList();
  }

  /// Serviços mais prestados: conta agendamentos confirmados/concluídos
  /// agrupados por 'servicoNome', ordenados por quantidade.
  List<ServicoRanking> _calcularTopServicos(List<Map<String, dynamic>> agendamentos) {
    final mapa = <String, _AcumuladorRanking>{};

    for (final a in agendamentos) {
      if (!_statusAgendamentoConta.contains(a['status'])) continue;
      final nome = (a['servicoNome'] as String?)?.trim();
      if (nome == null || nome.isEmpty) continue;

      final acumulador = mapa.putIfAbsent(nome, () => _AcumuladorRanking());
      acumulador.quantidade += 1;
      acumulador.valor += (a['servicoPreco'] as num?)?.toDouble() ?? 0;
    }

    final lista = mapa.entries
        .map((e) => ServicoRanking(nome: e.key, quantidade: e.value.quantidade, valor: e.value.valor))
        .toList()
      ..sort((x, y) => y.quantidade.compareTo(x.quantidade));

    return lista.take(5).toList();
  }

  /// Produtos mais vendidos: percorre os itens de cada pedido válido
  /// (não cancelado/pendente/expirado) e agrupa por nome do produto.
  List<ProdutoRanking> _calcularTopProdutos(List<Map<String, dynamic>> pedidos) {
    final mapa = <String, _AcumuladorRanking>{};

    for (final p in pedidos) {
      if (!_statusPedidoConta.contains(p['status'])) continue;
      final itens = p['itens'];
      if (itens is! List) continue;

      for (final itemRaw in itens) {
        if (itemRaw is! Map) continue;
        final nome = (itemRaw['nome'] as String?)?.trim();
        if (nome == null || nome.isEmpty) continue;

        final quantidade = (itemRaw['quantidade'] as num?)?.toInt() ?? 0;
        final precoUnitario = (itemRaw['precoUnitario'] as num?)?.toDouble() ?? 0;

        final acumulador = mapa.putIfAbsent(nome, () => _AcumuladorRanking());
        acumulador.quantidade += quantidade;
        acumulador.valor += precoUnitario * quantidade;
      }
    }

    final lista = mapa.entries
        .map((e) => ProdutoRanking(nome: e.key, quantidade: e.value.quantidade, valor: e.value.valor))
        .toList()
      ..sort((x, y) => y.quantidade.compareTo(x.quantidade));

    return lista.take(5).toList();
  }
}

class _AcumuladorRanking {
  int quantidade = 0;
  double valor = 0;
}