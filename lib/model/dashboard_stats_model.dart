/// Estatísticas agregadas do dashboard admin, calculadas a partir dos
/// dados reais em 'agendamentos', 'pedidos' e 'clientes'.
class DashboardStats {
  final double totalVendasServicos;
  final double totalVendasEncomendas;
  final int totalClientes;
  final int totalAgendamentos;
  final List<RendimentoPonto> rendimentoSemana;
  final List<RendimentoPonto> rendimentoMes;
  final List<RendimentoPonto> rendimentoTudo;
  final List<ServicoRanking> topServicos;
  final List<ProdutoRanking> topProdutos;

  const DashboardStats({
    required this.totalVendasServicos,
    required this.totalVendasEncomendas,
    required this.totalClientes,
    required this.totalAgendamentos,
    required this.rendimentoSemana,
    required this.rendimentoMes,
    required this.rendimentoTudo,
    required this.topServicos,
    required this.topProdutos,
  });

  factory DashboardStats.vazio() => const DashboardStats(
        totalVendasServicos: 0,
        totalVendasEncomendas: 0,
        totalClientes: 0,
        totalAgendamentos: 0,
        rendimentoSemana: [],
        rendimentoMes: [],
        rendimentoTudo: [],
        topServicos: [],
        topProdutos: [],
      );
}

/// Um ponto do gráfico de rendimento — já vem com o rótulo pronto
/// (dia da semana, dia do mês ou mês abreviado, consoante o filtro).
class RendimentoPonto {
  final String label;
  final double valor;
  const RendimentoPonto({required this.label, required this.valor});
}

class ServicoRanking {
  final String nome;
  final int quantidade;
  final double valor;
  const ServicoRanking({required this.nome, required this.quantidade, required this.valor});
}

class ProdutoRanking {
  final String nome;
  final int quantidade;
  final double valor;
  const ProdutoRanking({required this.nome, required this.quantidade, required this.valor});
}