import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';

class AdminConfiguracoesPage extends StatefulWidget {
  const AdminConfiguracoesPage({super.key});

  @override
  State<AdminConfiguracoesPage> createState() => _AdminConfiguracoesPageState();
}

class _AdminConfiguracoesPageState extends State<AdminConfiguracoesPage> {
  bool _notificacoesEmail = true;
  bool _notificacoesWhatsApp = true;
  bool _notificacoesPromocoes = false;
  String _idioma = 'Português';
  String _moeda = 'BRL (R\$)';
  bool _temaEscuro = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Perfil do Administrador',
            icon: Icons.person,
            children: [
              _buildProfileCard(isMobile),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Notificações',
            icon: Icons.notifications,
            children: [
              _buildSwitchTile(
                title: 'Notificações por Email',
                subtitle: 'Receba alertas de novos agendamentos e pedidos',
                value: _notificacoesEmail,
                onChanged: (value) => setState(() => _notificacoesEmail = value),
              ),
              _buildSwitchTile(
                title: 'Notificações WhatsApp',
                subtitle: 'Receba mensagens de clientes via WhatsApp',
                value: _notificacoesWhatsApp,
                onChanged: (value) => setState(() => _notificacoesWhatsApp = value),
              ),
              _buildSwitchTile(
                title: 'Promoções e Ofertas',
                subtitle: 'Receba notifies sobre promoções especiais',
                value: _notificacoesPromocoes,
                onChanged: (value) => setState(() => _notificacoesPromocoes = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Preferências',
            icon: Icons.settings,
            children: [
              _buildDropdownTile(
                title: 'Idioma',
                value: _idioma,
                items: const ['Português', 'Inglês', 'Espanhol'],
                onChanged: (value) => setState(() => _idioma = value ?? 'Português'),
              ),
              _buildDropdownTile(
                title: 'Moeda',
                value: _moeda,
                items: ['BRL (R\$)', 'USD (\$\)', 'EUR (€)'],
                onChanged: (value) => setState(() => _moeda = value ?? 'BRL (R\$)'),
              ),
              _buildSwitchTile(
                title: 'Tema Escuro',
                subtitle: 'Ative o modo escuro da interface',
                value: _temaEscuro,
                onChanged: (value) => setState(() => _temaEscuro = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Dados da Empresa',
            icon: Icons.business,
            children: [
              _buildInfoTile('Nome', 'Loah Stúdio'),
              _buildInfoTile('Email', 'contato@loahstudio.com'),
              _buildInfoTile('Telefone', '(11) 99999-9999'),
              _buildInfoTile('Endereço', 'Av. Paulista, 1000 - São Paulo'),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: ' Segurança',
            icon: Icons.security,
            children: [
              _buildActionTile(
                title: 'Alterar Senha',
                subtitle: 'Atualize sua senha de acesso',
                icon: Icons.lock,
                onTap: () => _showSnackbar('Funcionalidade em desenvolvimento'),
              ),
              _buildActionTile(
                title: 'Autenticação em 2 Fatores',
                subtitle: 'Adicione uma camada extra de segurança',
                icon: Icons.verified_user,
                onTap: () => _showSnackbar('Funcionalidade em desenvolvimento'),
              ),
              _buildActionTile(
                title: 'Ver Sessões Ativas',
                subtitle: 'Gerencie dispositivos conectados',
                icon: Icons.devices,
                onTap: () => _showSnackbar('Funcionalidade em desenvolvimento'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Suporte',
            icon: Icons.help,
            children: [
              _buildActionTile(
                title: 'Central de Ajuda',
                subtitle: 'Perguntas frequentes e tutoriais',
                icon: Icons.help_center,
                onTap: () => _showSnackbar('Funcionalidade em desenvolvimento'),
              ),
              _buildActionTile(
                title: 'Fale Conosco',
                subtitle: 'Entre em contato com o suporte',
                icon: Icons.chat,
                onTap: () => _showSnackbar('Funcionalidade em desenvolvimento'),
              ),
              _buildActionTile(
                title: 'Terms de Serviço',
                subtitle: 'Leia nossos terms e condições',
                icon: Icons.description,
                onTap: () => _showSnackbar('Funcionalidade em desenvolvimento'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Dados',
            icon: Icons.storage,
            children: [
              _buildActionTile(
                title: 'Backup Manual',
                subtitle: 'Faça um backup dos seus dados',
                icon: Icons.cloud_upload,
                onTap: () => _showSnackbar('Funcionalidade em desenvolvimento'),
              ),
              _buildActionTile(
                title: 'Exportar Dados',
                subtitle: 'Exporte seus dados em formato Excel/CSV',
                icon: Icons.download,
                onTap: () => _showSnackbar('Funcionalidade em desenvolvimento'),
              ),
              _buildActionTile(
                title: 'Limpar Cache',
                subtitle: 'Libere espaço removendo arquivos temporários',
                icon: Icons.cleaning_services,
                onTap: () => _showSnackbar('Funcionalidade em desenvolvimento'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Loah Stúdio v1.0.0',
              style: TextStyle(
                color: AppColors.grey.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.pinkStrong, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.brown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileCard(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              color: AppColors.pinkNude.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: AppColors.pinkStrong,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Administrador',
                  style: TextStyle(
                    color: AppColors.brown,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'admin@loahstudio.com',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showSnackbar('Funcionalidade em desenvolvimento'),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar Perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinkStrong,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: AppColors.brown, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.pinkStrong,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: AppColors.brown, fontWeight: FontWeight.w500)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: AppColors.brown)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: AppColors.brown, fontWeight: FontWeight.w500)),
      trailing: Text(value, style: const TextStyle(color: AppColors.grey)),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.pinkStrong),
      title: Text(title, style: const TextStyle(color: AppColors.brown, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: onTap,
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}