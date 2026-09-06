import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/dashboard_controller.dart';
import 'package:loahstudio/model/dashboard_stats_model.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final DashboardController _controller = DashboardController();
  late Future<DashboardStats> _statsFuture;

  String _selectedFilter = 'semana';

  @override
  void initState() {
    super.initState();
    _statsFuture = _controller.fetchDashboardStats();
  }

  Future<void> _recarregar() async {
    final novoFuture = _controller.fetchDashboardStats();
    setState(() => _statsFuture = novoFuture);
    await novoFuture;
  }

  String _formatarMoeda(double valor) => '€${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return FutureBuilder<DashboardStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data ?? DashboardStats.vazio();

        return RefreshIndicator(
          onRefresh: _recarregar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCards(context, stats),
                const SizedBox(height: 24),
                _buildRendimentoChart(context, stats),
                const SizedBox(height: 24),
                isMobile
                    ? Column(
                        children: [
                          _buildServicosChart(context, stats.topServicos),
                          const SizedBox(height: 24),
                          _buildProdutosChart(context, stats.topProdutos),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildServicosChart(context, stats.topServicos)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildProdutosChart(context, stats.topProdutos)),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(BuildContext context, DashboardStats stats) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    final cards = [
      _buildStatCard('Vendas de Serviços', _formatarMoeda(stats.totalVendasServicos), Icons.content_cut, AppColors.pinkStrong),
      _buildStatCard('Vendas de Encomendas', _formatarMoeda(stats.totalVendasEncomendas), Icons.shopping_cart, Colors.green),
      _buildStatCard('Clientes', '${stats.totalClientes}', Icons.people, Colors.blue),
      _buildStatCard('Agendamentos', '${stats.totalAgendamentos}', Icons.calendar_month, Colors.purple),
    ];

    if (isMobile) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            cards[i],
          ],
        ],
      );
    }

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.1,
      children: cards,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.grey, fontSize: 13), overflow: TextOverflow.ellipsis),
                Text(
                  value,
                  style: const TextStyle(color: AppColors.brown, fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRendimentoChart(BuildContext context, DashboardStats stats) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final pontos = _pontosParaFiltro(stats);

    final maxValor = pontos.isEmpty ? 0.0 : pontos.map((p) => p.valor).reduce((a, b) => a > b ? a : b);
    final maxY = maxValor <= 0 ? 100.0 : (maxValor * 1.2);
    final horizontalInterval = maxY / 4;
    final bottomInterval = pontos.length <= 7
        ? 1.0
        : pontos.length <= 15
            ? 2.0
            : (pontos.length / 6).ceilToDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rendimento',
            style: TextStyle(color: AppColors.brown, fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterButton('semana', 'Semana'),
              _buildFilterButton('mes', 'Mês'),
              _buildFilterButton('tudo', 'Tudo'),
            ],
          ),
          const SizedBox(height: 24),
          if (pontos.isEmpty)
            SizedBox(
              height: isMobile ? 200 : 250,
              child: const Center(child: Text('Sem dados para este período', style: TextStyle(color: AppColors.grey))),
            )
          else
            SizedBox(
              height: isMobile ? 200 : 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: horizontalInterval,
                    getDrawingHorizontalLine: (value) => FlLine(color: AppColors.grey.withValues(alpha: 0.1), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: bottomInterval,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= pontos.length) return const SizedBox();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(pontos[index].label, style: const TextStyle(color: AppColors.grey, fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isMobile ? 44 : 54,
                        interval: horizontalInterval,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Text(_formatarMoeda(value), style: const TextStyle(color: AppColors.grey, fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (pontos.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(pontos.length, (i) => FlSpot(i.toDouble(), pontos[i].valor)),
                      isCurved: true,
                      color: AppColors.pinkStrong,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.white,
                          strokeWidth: 2,
                          strokeColor: AppColors.pinkStrong,
                        ),
                      ),
                      belowBarData: BarAreaData(show: true, color: AppColors.pinkStrong.withValues(alpha: 0.1)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<RendimentoPonto> _pontosParaFiltro(DashboardStats stats) {
    switch (_selectedFilter) {
      case 'semana':
        return stats.rendimentoSemana;
      case 'mes':
        return stats.rendimentoMes;
      case 'tudo':
        return stats.rendimentoTudo;
      default:
        return stats.rendimentoSemana;
    }
  }

  Widget _buildFilterButton(String filter, String label) {
    final bool isSelected = _selectedFilter == filter;
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: isMobile ? 6 : 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pinkStrong : AppColors.lightCreamBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.pinkStrong : AppColors.grey.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? AppColors.white : AppColors.brown, fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildServicosChart(BuildContext context, List<ServicoRanking> topServicos) {
    return _buildRankingChart(
      context: context,
      titulo: 'Serviços mais Prestados',
      itens: topServicos.map((s) => _RankingItem(nome: s.nome, quantidade: s.quantidade, valor: s.valor)).toList(),
      corBarra: AppColors.pinkStrong,
      unidade: 'agend.',
    );
  }

  Widget _buildProdutosChart(BuildContext context, List<ProdutoRanking> topProdutos) {
    return _buildRankingChart(
      context: context,
      titulo: 'Produtos mais Vendidos',
      itens: topProdutos.map((p) => _RankingItem(nome: p.nome, quantidade: p.quantidade, valor: p.valor)).toList(),
      corBarra: Colors.orange,
      unidade: 'un.',
    );
  }

  Widget _buildRankingChart({
    required BuildContext context,
    required String titulo,
    required List<_RankingItem> itens,
    required Color corBarra,
    required String unidade,
  }) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(color: AppColors.brown, fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (itens.isEmpty)
            const SizedBox(
              height: 120,
              child: Center(child: Text('Ainda sem dados suficientes', style: TextStyle(color: AppColors.grey))),
            )
          else ...[
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: itens.first.quantidade.toDouble() * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${itens[groupIndex].nome}\n${rod.toY.toInt()} $unidade',
                          const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (value % 1 != 0 || index >= itens.length) return const SizedBox();
                          final nome = itens[index].nome;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: SizedBox(
                              width: 60,
                              child: Text(
                                nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.grey, fontSize: 10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: AppColors.grey, fontSize: 10)),
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(itens.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: itens[index].quantidade.toDouble(),
                          color: corBarra,
                          width: 20,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...itens.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(item.nome, style: const TextStyle(color: AppColors.brown, fontSize: 14), overflow: TextOverflow.ellipsis)),
                      Text('${item.quantidade}x', style: const TextStyle(color: AppColors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Text(_formatarMoeda(item.valor), style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _RankingItem {
  final String nome;
  final int quantidade;
  final double valor;
  const _RankingItem({required this.nome, required this.quantidade, required this.valor});
}