import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/auth_controller.dart';
import 'package:loahstudio/model/user_model.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';
import 'package:loahstudio/view/user_views/perfil/editar_perfil_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final AuthController _authController = AuthController();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarUtilizador();
  }

  Future<void> _carregarUtilizador() async {
    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final user = await _authController.getUserData(uid);
    if (!mounted) return;
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _confirmarSair() async {
    final confirmar = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Terminar sessão',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brown),
              ),
              const SizedBox(height: 8),
              Text(
                'Tens a certeza que queres sair da tua conta?',
                style: TextStyle(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sair'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmar == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.lightCreamBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.brown),
        title: Text('Perfil', style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child: Text(
                    'Não foi possível carregar o perfil.',
                    style: TextStyle(color: AppColors.grey),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 20 : 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.pinkNude,
                            child: Icon(Icons.person, size: 48, color: AppColors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _user!.nome,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.brown),
                          ),
                          const SizedBox(height: 4),
                          Text(_user!.email, style: TextStyle(fontSize: 14, color: AppColors.grey)),
                          const SizedBox(height: 32),
                          _buildInfoCard(),
                          const SizedBox(height: 24),
                          _buildOptionsCard(context),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.grey.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          _infoTile(Icons.phone_outlined, 'Telemóvel', _user!.telefone.isEmpty ? 'Não definido' : _user!.telefone),
          const Divider(height: 24),
          _infoTile(
            Icons.location_on_outlined,
            'Morada',
            (_user!.morada == null || _user!.morada!.isEmpty) ? 'Não definida' : _user!.morada!,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.pinkStrong, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.grey)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 15, color: AppColors.brown, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.grey.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          _optionTile(
            icon: Icons.edit_outlined,
            label: 'Editar Perfil',
            onTap: () async {
              final atualizado = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => EditarPerfilPage(user: _user!)),
              );
              if (atualizado == true) _carregarUtilizador();
            },
          ),
          const Divider(height: 1),
          _optionTile(
            icon: Icons.support_agent_outlined,
            label: 'Suporte',
            onTap: () {
              // TODO: ligar a um ecrã ou contacto de suporte real (email/WhatsApp).
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Função em desenvolvimento')),
              );
            },
          ),
          const Divider(height: 1),
          _optionTile(
            icon: Icons.logout,
            label: 'Sair',
            color: Colors.red,
            onTap: _confirmarSair,
          ),
        ],
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.brown),
      title: Text(label, style: TextStyle(color: color ?? AppColors.brown, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
      onTap: onTap,
    );
  }
}