import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';


class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;
  bool _isExtended = true;

  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(icon: Icons.dashboard, label: 'Dashboard', index: 0),
    AdminMenuItem(icon: Icons.calendar_month, label: 'Agendamentos', index: 1),
    AdminMenuItem(icon: Icons.shopping_cart, label: 'Compras', index: 2),
    AdminMenuItem(icon: Icons.people, label: 'Clientes', index: 3),
    AdminMenuItem(icon: Icons.inventory, label: 'Produtos', index: 4),
    AdminMenuItem(icon: Icons.settings, label: 'Configurações', index: 5),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isTablet = ResponsiveHelper.isTablet(context);

    // Ajustar sidebar para tablet/mobile
    if (isMobile) {
      _isExtended = false;
    } else if (isTablet) {
      _isExtended = false;
    }

    return Scaffold(
      backgroundColor: AppColors.lightCreamBg,
      body: SafeArea(
        child: Row(
          children: [
            // 🔹 Sidebar Lateral Esquerdo
            _buildSidebar(isMobile, isTablet),
            // 🔹 Divisor
            if (!isMobile)
              Container(
                width: 1,
                color: AppColors.grey.withValues(alpha: 0.2),
              ),
            // 🔹 Área Principal (Página)
            Expanded(
              child: Column(
                children: [
                  _buildAppBar(isMobile),
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isMobile, bool isTablet) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isExtended ? 250 : 80,
      color: AppColors.white,
      child: Column(
        children: [
          // 🔹 Logo / Título do Sidebar
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.pinkStrong,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_isExtended) const SizedBox(width: 12),
                if (_isExtended)
                  Expanded(
                    child: Text(
                      'Loah\nStúdio',
                      style: TextStyle(
                        color: AppColors.brown,
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 🔹 Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                return _buildMenuItem(_menuItems[index], isMobile);
              },
            ),
          ),
          const Divider(height: 1),
          // 🔹 Log Out
          _buildLogoutItem(isMobile),
          // 🔹 Botão para expandir/recolher sidebar (apenas em desktop)
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isExtended = !_isExtended;
                  });
                },
                icon: Icon(
                  _isExtended ? Icons.chevron_left : Icons.chevron_right,
                  color: AppColors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(AdminMenuItem item, bool isMobile) {
    final bool isSelected = _selectedIndex == item.index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: isSelected ? AppColors.pinkStrong.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = item.index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _isExtended ? 16 : 12,
              vertical: 14,
            ),
            child: Row(
              mainAxisAlignment: _isExtended ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? AppColors.pinkStrong : AppColors.grey,
                  size: 24,
                ),
                if (_isExtended) const SizedBox(width: 16),
                if (_isExtended)
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? AppColors.pinkStrong : AppColors.brown,
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutItem(bool isMobile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            _showLogoutDialog();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _isExtended ? 16 : 12,
              vertical: 14,
            ),
            child: Row(
              mainAxisAlignment: _isExtended ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                  size: 24,
                ),
                if (_isExtended) const SizedBox(width: 16),
                if (_isExtended)
                  const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isMobile) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔹 Título da Página Atual
          Expanded(
            child: Text(
              _menuItems[_selectedIndex].label,
              style: TextStyle(
                color: AppColors.brown,
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 🔹 Notificações
          IconButton(
            onPressed: () {
              // TODO: Abrir notificações
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificações')),
              );
            },
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.brown,
                  size: 28,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.pinkStrong,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 🔹 Foto de Perfil
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.pinkNude,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.pinkStrong,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.person,
                      color: AppColors.white,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const AdminDashboardPage();
      case 1:
        return const AdminAgendamentosPage();
      case 2:
        return const AdminComprasPage();
      case 3:
        return const AdminClientesPage();
      case 4:
        return const AdminProdutosPage();
      case 5:
        return const AdminConfiguracoesPage();
      default:
        return const AdminDashboardPage();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da conta admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implementar logout
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout realizado com sucesso')),
              );
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Modelo para Menu Item
class AdminMenuItem {
  final IconData icon;
  final String label;
  final int index;

  AdminMenuItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

// 🔹 Placeholder das Páginas (serão implementadas depois)
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _selectedFilter = 'semana'; // semana, mes, tudo

  // Dados de exemplo para os gráficos
  final List<double> _rendimentoSemana = [150, 280, 190, 320, 250, 400, 350];
  final List<double> _rendimentoMes = [1200, 1800, 1400, 2100, 1900, 2500, 2200, 2800, 2400, 3100, 2700, 3200];
  final List<double> _rendimentoTudo = [15000, 18000, 22000, 19000, 25000, 28000, 32000, 35000, 31000, 38000, 42000, 45000];

  final List<Map<String, dynamic>> _servicos = [
    {'nome': 'Corte Feminino', 'quantidade': 45, 'valor': 4500},
    {'nome': 'Escova Progressiva', 'quantidade': 38, 'valor': 7600},
    {'nome': 'Mechas', 'quantidade': 25, 'valor': 12500},
    {'nome': 'Corte Masculino', 'quantidade': 32, 'valor': 2880},
    {'nome': 'Coloração', 'quantidade': 18, 'valor': 5400},
    {'nome': 'Tratamento Capilar', 'quantidade': 22, 'valor': 4400},
  ];

  final List<Map<String, dynamic>> _produtos = [
    {'nome': 'Shampoo', 'quantidade': 85, 'valor': 2550},
    {'nome': 'Máscara', 'quantidade': 62, 'valor': 3100},
    {'nome': 'Óleo', 'quantidade': 45, 'valor': 2250},
    {'nome': 'Serum', 'quantidade': 28, 'valor': 1960},
    {'nome': 'Spray', 'quantidade': 55, 'valor': 1650},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Cards de Estatísticas
          _buildStatsCards(context),
          const SizedBox(height: 24),
          // 🔹 Card de Rendimento Diário com Filtros
          _buildRendimentoChart(context),
          const SizedBox(height: 24),
          // 🔹 Cards de Serviços e Produtos (Lado a Lado)
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
    final bool isTablet = ResponsiveHelper.isTablet(context);

    int crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 4);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          icon: Icons.calendar_month,
          label: 'Agendamentos',
          value: '24',
          color: AppColors.pinkStrong,
        ),
        _buildStatCard(
          context,
          icon: Icons.shopping_cart,
          label: 'Compras',
          value: 'R\$ 2.450',
          color: Colors.green,
        ),
        _buildStatCard(
          context,
          icon: Icons.people,
          label: 'Clientes',
          value: '156',
          color: Colors.blue,
        ),
        _buildStatCard(
          context,
          icon: Icons.inventory,
          label: 'Produtos',
          value: '45',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                ),
              ),
            ],
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
          // 🔹 Título e Filtros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Rendimento Diário',
                  style: TextStyle(
                    color: AppColors.brown,
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 🔹 Botões de Filtro (Em lista para mobile)
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
          // 🔹 Gráfico de Linha
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
                            if (value.toInt() < dias.length) {
                              text = dias[value.toInt()];
                            }
                            break;
                          case 'mes':
                            text = '${value.toInt() + 1}';
                            break;
                          case 'tudo':
                            final meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
                            if (value.toInt() < meses.length) {
                              text = meses[value.toInt()];
                            }
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 10,
                            ),
                          ),
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
                          _selectedFilter == 'tudo'
                              ? 'R\$${(value / 1000).toStringAsFixed(0)}k'
                              : 'R\$${value.toInt()}',
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 10,
                          ),
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
      case 'semana':
        return 100;
      case 'mes':
        return 500;
      case 'tudo':
        return 10000;
      default:
        return 100;
    }
  }

  double _getBottomInterval() {
    switch (_selectedFilter) {
      case 'semana':
        return 1;
      case 'mes':
        return 2;
      case 'tudo':
        return 2;
      default:
        return 1;
    }
  }

  Widget _buildFilterButton(String filter, String label) {
    final bool isSelected = _selectedFilter == filter;
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 14,
          vertical: isMobile ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pinkStrong : AppColors.lightCreamBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.pinkStrong : AppColors.grey.withValues(alpha: 0.3),
            width: 1,
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

  double _getMaxX() {
    switch (_selectedFilter) {
      case 'semana':
        return 6;
      case 'mes':
        return 11;
      case 'tudo':
        return 11;
      default:
        return 6;
    }
  }

  double _getMaxY() {
    switch (_selectedFilter) {
      case 'semana':
        return 450;
      case 'mes':
        return 3500;
      case 'tudo':
        return 50000;
      default:
        return 450;
    }
  }

  List<FlSpot> _getSpots() {
    List<double> data;
    switch (_selectedFilter) {
      case 'semana':
        data = _rendimentoSemana;
        break;
      case 'mes':
        data = _rendimentoMes;
        break;
      case 'tudo':
        data = _rendimentoTudo;
        break;
      default:
        data = _rendimentoSemana;
    }

    return List.generate(data.length, (index) {
      return FlSpot(index.toDouble(), data[index]);
    });
  }

  Widget _buildServicosChart(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    // Ordenar por quantidade
    final sortedServicos = List<Map<String, dynamic>>.from(_servicos)
      ..sort((a, b) => b['quantidade'].compareTo(a['quantidade']));

    // Pegar top 5
    final topServicos = sortedServicos.take(5).toList();

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
          Text(
            'Serviços mais Prestados',
            style: TextStyle(
              color: AppColors.brown,
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // 🔹 Gráfico de Barras Horizontal
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: topServicos[0]['quantidade'].toDouble() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${topServicos[groupIndex]['nome']}\n${rod.toY.toInt()} vendas',
                        const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                        if (index < topServicos.length) {
                          final nome = topServicos[index]['nome'] as String;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              nome.length > 10 ? '${nome.substring(0, 10)}...' : nome,
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
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
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 🔹 Lista de Serviços com Valores
          ...topServicos.map((servico) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      servico['nome'] as String,
                      style: const TextStyle(
                        color: AppColors.brown,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${servico['quantidade']}x',
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'R\$ ${(servico['valor'] as int).toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProdutosChart(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    // Ordenar por quantidade
    final sortedProdutos = List<Map<String, dynamic>>.from(_produtos)
      ..sort((a, b) => b['quantidade'].compareTo(a['quantidade']));

    // Pegar top 5
    final topProdutos = sortedProdutos.take(5).toList();

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
          Text(
            'Produtos mais Vendidos',
            style: TextStyle(
              color: AppColors.brown,
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // 🔹 Gráfico de Barras Horizontal
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: topProdutos[0]['quantidade'].toDouble() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${topProdutos[groupIndex]['nome']}\n${rod.toY.toInt()} vendas',
                        const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                        if (index < topProdutos.length) {
                          final nome = topProdutos[index]['nome'] as String;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              nome.length > 10 ? '${nome.substring(0, 10)}...' : nome,
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
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
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 🔹 Lista de Produtos com Valores
          ...topProdutos.map((produto) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      produto['nome'] as String,
                      style: const TextStyle(
                        color: AppColors.brown,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${produto['quantidade']}x',
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'R\$ ${(produto['valor'] as int).toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// 🔹 Página de Agendamentos
class AdminAgendamentosPage extends StatelessWidget {
  const AdminAgendamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Página de Agendamentos',
        style: TextStyle(
          color: AppColors.brown,
          fontSize: 24,
        ),
      ),
    );
  }
}

// 🔹 Página de Compras
class AdminComprasPage extends StatelessWidget {
  const AdminComprasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Página de Compras',
        style: TextStyle(
          color: AppColors.brown,
          fontSize: 24,
        ),
      ),
    );
  }
}

// 🔹 Página de Clientes
class AdminClientesPage extends StatelessWidget {
  const AdminClientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Página de Clientes',
        style: TextStyle(
          color: AppColors.brown,
          fontSize: 24,
        ),
      ),
    );
  }
}

// 🔹 Página de Produtos
class AdminProdutosPage extends StatelessWidget {
  const AdminProdutosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Página de Produtos',
        style: TextStyle(
          color: AppColors.brown,
          fontSize: 24,
        ),
      ),
    );
  }
}

// 🔹 Página de Configurações
class AdminConfiguracoesPage extends StatelessWidget {
  const AdminConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Página de Configurações',
        style: TextStyle(
          color: AppColors.brown,
          fontSize: 24,
        ),
      ),
    );
  }
}