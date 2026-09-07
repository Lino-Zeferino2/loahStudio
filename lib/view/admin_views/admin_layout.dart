import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/auth_controller.dart';
import 'package:loahstudio/view/admin_views/pages/admin_agendamentos_page.dart';
import 'package:loahstudio/view/admin_views/pages/admin_avaliacoes_page.dart';
import 'package:loahstudio/view/admin_views/pages/admin_clientes_page.dart';
import 'package:loahstudio/view/admin_views/pages/admin_compras_page.dart';
import 'package:loahstudio/view/admin_views/pages/admin_configuracoes_page.dart';
import 'package:loahstudio/view/admin_views/pages/admin_dashboard_page.dart';
import 'package:loahstudio/view/admin_views/pages/admin_produtos_page.dart';
import 'package:loahstudio/view/admin_views/pages/admin_servicos_page.dart';
import 'package:loahstudio/view/shared/notificacao_icon_button.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';


class AdminLayout extends StatefulWidget {
  /// Índice inicial do menu — usado para abrir já na tab certa quando se
  /// chega aqui a partir de uma notificação (1 = Agendamentos, 2 = Compras).
  final int initialIndex;

  const AdminLayout({super.key, this.initialIndex = 0});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  late int _selectedIndex;
  bool _isExtended = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

 final List<AdminMenuItem> _menuItems = [
  AdminMenuItem(icon: Icons.dashboard, label: 'Dashboard', index: 0),
  AdminMenuItem(icon: Icons.calendar_month, label: 'Agendamentos', index: 1),
  AdminMenuItem(icon: Icons.shopping_cart, label: 'Compras', index: 2),
  AdminMenuItem(icon: Icons.inventory, label: 'Produtos', index: 3),
  AdminMenuItem(icon: Icons.content_cut, label: 'Serviços', index: 4),
  AdminMenuItem(icon: Icons.people, label: 'Clientes', index: 5),
  AdminMenuItem(icon: Icons.reviews, label: 'Avaliações', index: 6),
  AdminMenuItem(icon: Icons.settings, label: 'Configurações', index: 7),
];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isTablet = ResponsiveHelper.isTablet(context);

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
            _buildSidebar(isMobile, isTablet),
            if (!isMobile)
              Container(
                width: 1,
                color: AppColors.grey.withValues(alpha: 0.2),
              ),
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
          _buildLogoutItem(isMobile),
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
          const NotificacaoIconButton(),
          const SizedBox(width: 8),
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
      return const AdminProdutosPage();
    case 4:
      return const AdminServicosPage();
    case 5:
      return const AdminClientesPage();
    case 6:
      return const AdminAvaliacoesPage();
    case 7:
      return const AdminConfiguracoesPage();
    default:
      return const AdminDashboardPage();
  }
}

 void _showLogoutDialog() {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Sair'),
      content: const Text('Tem certeza que deseja sair da conta admin?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(dialogContext);

            final authController = AuthController();
            await authController.logoutUser(
              onComplete: (success, errorMessage) {
                if (!mounted) return;

                if (success) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage ?? 'Erro ao sair.')),
                  );
                }
              },
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