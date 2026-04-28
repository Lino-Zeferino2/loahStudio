import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _selectedFilter = 'semana';

  final List<double> _rendimentoSemana = [150, 280, 190, 320, 250, 400, 350];
  final List<double> _rendimentoMes = [1200, 1800, 1400, 2100, 1900, 2500, 2200, 2800, 2400, 3100, 2700, 3200];
  final List<double> _rendimentoTudo = [15000, 18000, 22000, 19000, 25000, 28000, 32000, 35000, 31000, 38000, 42000, 45000];

  final List<Map<String, dynamic>> _servicos = [
    {'nome': 'Maquil. Noiva', 'quantidade': 45, 'valor': 11250},
    {'nome': 'Maquil. Festa', 'quantidade': 38, 'valor': 5700},
    {'nome': 'Maquil. Editorial', 'quantidade': 25, 'valor': 5000},
    {'nome': 'Maquil. Natural', 'quantidade': 32, 'valor': 2560},
    {'nome': 'Sombra Olhos', 'quantidade': 18, 'valor': 1080},
    {'nome': 'Gloss Look', 'quantidade': 22, 'valor': 880},
  ];

  final List<Map<String, dynamic>> _produtos = [
    {'nome': 'Batom Rouge', 'quantidade': 85, 'valor': 3825},
    {'nome': 'Gloss Brilho', 'quantidade': 62, 'valor': 2170},
    {'nome': 'Paleta Sombra', 'quantidade': 45, 'valor': 5400},
    {'nome': 'Delineador', 'quantidade': 28, 'valor': 1176},
    {'nome': 'Primer Facial', 'quantidade': 55, 'valor': 4125},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(context),
          const SizedBox(height: 24),
          _buildRendimentoChart(context),
          const SizedBox(height: 24),
          isMobile
              ? Column(
                  children: [
                    _buildServicosChart(context),
                    const SizedBox(height: 24),
                    _buildProdutosChart(context),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildServicosChart(context)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildProdutosChart(context)),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return isMobile
        ? Column(
            children: [
              _buildStatCard('Total Vendas', 'R\$ 8.750', Icons.shopping_cart, Colors.green),
              const SizedBox(height: 12),
              _buildStatCard('Clientes', '156', Icons.people, Colors.blue),
              const SizedBox(height: 12),
              _buildStatCard('Agendamentos', '89', Icons.calendar_month, Colors.purple),
            ],
          )
        : Row(
            children: [
              Expanded(child: _buildStatCard('Total Vendas', 'R\$ 8.750', Icons.shopping_cart, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Clientes', '156', Icons.people, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Agendamentos', '89', Icons.calendar_month, Colors.purple)),
            ],
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
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 13,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.brown,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRendimentoChart(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rendimento Diário',
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
          SizedBox(
            height: isMobile ? 200 : 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getHorizontalInterval(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.grey.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _getBottomInterval(),
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        switch (_selectedFilter) {
                          case 'semana':
                            final dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
                            if (value.toInt() < dias.length) text = dias[value.toInt()];
                            break;
                          case 'mes':
                            text = '${value.toInt() + 1}';
                            break;
                          case 'tudo':
                            final meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
                            if (value.toInt() < meses.length) text = meses[value.toInt()];
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(text, style: const TextStyle(color: AppColors.grey, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isMobile ? 40 : 50,
                      interval: _getHorizontalInterval(),
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          _selectedFilter == 'tudo' ? 'R\$${(value / 1000).toStringAsFixed(0)}k' : 'R\$${value.toInt()}',
                          style: const TextStyle(color: AppColors.grey, fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: _getMaxX(),
                minY: 0,
                maxY: _getMaxY(),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getSpots(),
                    isCurved: true,
                    color: AppColors.pinkStrong,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.white,
                          strokeWidth: 2,
                          strokeColor: AppColors.pinkStrong,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.pinkStrong.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getHorizontalInterval() {
    switch (_selectedFilter) {
      case 'semana': return 100;
      case 'mes': return 500;
      case 'tudo': return 10000;
      default: return 100;
    }
  }

  double _getBottomInterval() {
    switch (_selectedFilter) {
      case 'semana': return 1;
      case 'mes': return 2;
      case 'tudo': return 2;
      default: return 1;
    }
  }

  double _getMaxX() {
    switch (_selectedFilter) {
      case 'semana': return 6;
      case 'mes': return 11;
      case 'tudo': return 11;
      default: return 6;
    }
  }

  double _getMaxY() {
    switch (_selectedFilter) {
      case 'semana': return 450;
      case 'mes': return 3500;
      case 'tudo': return 50000;
      default: return 450;
    }
  }

  List<FlSpot> _getSpots() {
    List<double> data;
    switch (_selectedFilter) {
      case 'semana': data = _rendimentoSemana; break;
      case 'mes': data = _rendimentoMes; break;
      case 'tudo': data = _rendimentoTudo; break;
      default: data = _rendimentoSemana;
    }
    return List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index]));
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
          border: Border.all(
            color: isSelected ? AppColors.pinkStrong : AppColors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.brown,
            fontSize: isMobile ? 11 : 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildServicosChart(BuildContext context) {
    final sortedServicos = List<Map<String, dynamic>>.from(_servicos)..sort((a, b) => b['quantidade'].compareTo(a['quantidade']));
    final topServicos = sortedServicos.take(5).toList();

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
            'Serviços mais Prestados',
            style: TextStyle(color: AppColors.brown, fontSize: ResponsiveHelper.isMobile(context) ? 18 : 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: topServicos[0]['quantidade'].toDouble() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem('${topServicos[groupIndex]['nome']}\n${rod.toY.toInt()} vendas', const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold));
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
  if (value % 1 != 0) return const SizedBox();

  final index = value.toInt();

  if (index >= topServicos.length) return const SizedBox();

  final nome = topServicos[index]['nome'] as String;

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
}
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: AppColors.grey, fontSize: 10)))),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(topServicos.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: topServicos[index]['quantidade'].toDouble(),
                        color: AppColors.pinkStrong,
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
          ...topServicos.map((servico) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(servico['nome'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 14))),
                Text('${servico['quantidade']}x', style: const TextStyle(color: AppColors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Text('R\$ ${(servico['valor'] as int).toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProdutosChart(BuildContext context) {
    final sortedProdutos = List<Map<String, dynamic>>.from(_produtos)..sort((a, b) => b['quantidade'].compareTo(a['quantidade']));
    final topProdutos = sortedProdutos.take(5).toList();

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
            'Produtos mais Vendidos',
            style: TextStyle(color: AppColors.brown, fontSize: ResponsiveHelper.isMobile(context) ? 18 : 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: topProdutos[0]['quantidade'].toDouble() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem('${topProdutos[groupIndex]['nome']}\n${rod.toY.toInt()} vendas', const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold));
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
                        if (index < topProdutos.length) {
                          final nome = topProdutos[index]['nome'] as String;
                          return SideTitleWidget(axisSide: meta.axisSide, child: Text(nome.length > 10 ? '${nome.substring(0, 10)}...' : nome, style: const TextStyle(color: AppColors.grey, fontSize: 10)));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: AppColors.grey, fontSize: 10)))),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(topProdutos.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: topProdutos[index]['quantidade'].toDouble(),
                        color: Colors.orange,
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
          ...topProdutos.map((produto) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(produto['nome'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 14))),
                Text('${produto['quantidade']}x', style: const TextStyle(color: AppColors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Text('R\$ ${(produto['valor'] as int).toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}