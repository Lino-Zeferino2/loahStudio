import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/site_config.dart';

class AdminConfiguracoesPage extends StatefulWidget {
  const AdminConfiguracoesPage({super.key});

  @override
  State<AdminConfiguracoesPage> createState() => _AdminConfiguracoesPageState();
}

class _AdminConfiguracoesPageState extends State<AdminConfiguracoesPage> {
  // Controllers para specialty section
  final _specialtyTituloCtrl = TextEditingController(text: SiteConfig.specialtyTitulo);
  final _specialtyDescricaoCtrl = TextEditingController(text: SiteConfig.specialtyDescricao);
  final _specialtyItem1Ctrl = TextEditingController(text: SiteConfig.specialtyItem1Titulo);
  final _specialtyItem1DescCtrl = TextEditingController(text: SiteConfig.specialtyItem1Descricao);
  final _specialtyItem2Ctrl = TextEditingController(text: SiteConfig.specialtyItem2Titulo);
  final _specialtyItem2DescCtrl = TextEditingController(text: SiteConfig.specialtyItem2Descricao);
  final _specialtyItem3Ctrl = TextEditingController(text: SiteConfig.specialtyItem3Titulo);
  final _specialtyItem3DescCtrl = TextEditingController(text: SiteConfig.specialtyItem3Descricao);
  
  // Controllers para galeria section
  final _galeriaTituloCtrl = TextEditingController(text: SiteConfig.galeriaTitulo);
  final _galeriaSubtituloCtrl = TextEditingController(text: SiteConfig.galeriaSubtitulo);
  
  // Controllers para essencia section
  final _essenciaTituloCtrl = TextEditingController(text: SiteConfig.essenciaTitulo);
  final _essenciaDescricaoCtrl = TextEditingController(text: SiteConfig.essenciaDescricao);
  final _essenciaBotaoCtrl = TextEditingController(text: SiteConfig.essenciaBotaoTexto);
  
  // Controllers para pilares section
  final _pilaresTituloCtrl = TextEditingController(text: SiteConfig.pilaresTitulo);
  final _pilar1TituloCtrl = TextEditingController(text: SiteConfig.pilar1Titulo);
  final _pilar1DescCtrl = TextEditingController(text: SiteConfig.pilar1Descricao);
  final _pilar2TituloCtrl = TextEditingController(text: SiteConfig.pilar2Titulo);
  final _pilar2DescCtrl = TextEditingController(text: SiteConfig.pilar2Descricao);
  final _pilar3TituloCtrl = TextEditingController(text: SiteConfig.pilar3Titulo);
  final _pilar3DescCtrl = TextEditingController(text: SiteConfig.pilar3Descricao);
  
  // Controllers para testemunhos section
  final _testemunhosTituloCtrl = TextEditingController(text: SiteConfig.testemunhosTitulo);
  final _testemunho1NomeCtrl = TextEditingController(text: SiteConfig.testemunho1Nome);
  final _testemunho1TextoCtrl = TextEditingController(text: SiteConfig.testemunho1Texto);
  final _testemunho2NomeCtrl = TextEditingController(text: SiteConfig.testemunho2Nome);
  final _testemunho2TextoCtrl = TextEditingController(text: SiteConfig.testemunho2Texto);
  final _testemunho3NomeCtrl = TextEditingController(text: SiteConfig.testemunho3Nome);
  final _testemunho3TextoCtrl = TextEditingController(text: SiteConfig.testemunho3Texto);
  
  // Controllers para pronta brilhar section
  final _prontaBrilharTituloCtrl = TextEditingController(text: SiteConfig.prontaBrilharTitulo);
  final _prontaBrilharDescCtrl = TextEditingController(text: SiteConfig.prontaBrilharDescricao);
  final _prontaBrilharBotaoCtrl = TextEditingController(text: SiteConfig.prontaBrilharBotao);
  
  // Controllers para footer section
  final _footerNomeCtrl = TextEditingController(text: SiteConfig.footerNome);
  final _footerEmailCtrl = TextEditingController(text: SiteConfig.footerEmail);
  final _footerTelefoneCtrl = TextEditingController(text: SiteConfig.footerTelefone);
  final _footerEnderecoCtrl = TextEditingController(text: SiteConfig.footerEndereco);
  final _footerHorarioCtrl = TextEditingController(text: SiteConfig.footerHorarioTexto);

  void _salvarConfiguracoes() {
    // Specialty Section
    SiteConfig.specialtyTitulo = _specialtyTituloCtrl.text;
    SiteConfig.specialtyDescricao = _specialtyDescricaoCtrl.text;
    SiteConfig.specialtyItem1Titulo = _specialtyItem1Ctrl.text;
    SiteConfig.specialtyItem1Descricao = _specialtyItem1DescCtrl.text;
    SiteConfig.specialtyItem2Titulo = _specialtyItem2Ctrl.text;
    SiteConfig.specialtyItem2Descricao = _specialtyItem2DescCtrl.text;
    SiteConfig.specialtyItem3Titulo = _specialtyItem3Ctrl.text;
    SiteConfig.specialtyItem3Descricao = _specialtyItem3DescCtrl.text;
    
    // Galeria Section
    SiteConfig.galeriaTitulo = _galeriaTituloCtrl.text;
    SiteConfig.galeriaSubtitulo = _galeriaSubtituloCtrl.text;
    
    // Essencia Section
    SiteConfig.essenciaTitulo = _essenciaTituloCtrl.text;
    SiteConfig.essenciaDescricao = _essenciaDescricaoCtrl.text;
    SiteConfig.essenciaBotaoTexto = _essenciaBotaoCtrl.text;
    
    // Pilares Section
    SiteConfig.pilaresTitulo = _pilaresTituloCtrl.text;
    SiteConfig.pilar1Titulo = _pilar1TituloCtrl.text;
    SiteConfig.pilar1Descricao = _pilar1DescCtrl.text;
    SiteConfig.pilar2Titulo = _pilar2TituloCtrl.text;
    SiteConfig.pilar2Descricao = _pilar2DescCtrl.text;
    SiteConfig.pilar3Titulo = _pilar3TituloCtrl.text;
    SiteConfig.pilar3Descricao = _pilar3DescCtrl.text;
    
    // Testemunhos Section
    SiteConfig.testemunhosTitulo = _testemunhosTituloCtrl.text;
    SiteConfig.testemunho1Nome = _testemunho1NomeCtrl.text;
    SiteConfig.testemunho1Texto = _testemunho1TextoCtrl.text;
    SiteConfig.testemunho2Nome = _testemunho2NomeCtrl.text;
    SiteConfig.testemunho2Texto = _testemunho2TextoCtrl.text;
    SiteConfig.testemunho3Nome = _testemunho3NomeCtrl.text;
    SiteConfig.testemunho3Texto = _testemunho3TextoCtrl.text;
    
    // Pronta Brilhar Section
    SiteConfig.prontaBrilharTitulo = _prontaBrilharTituloCtrl.text;
    SiteConfig.prontaBrilharDescricao = _prontaBrilharDescCtrl.text;
    SiteConfig.prontaBrilharBotao = _prontaBrilharBotaoCtrl.text;
    
    // Footer Section
    SiteConfig.footerNome = _footerNomeCtrl.text;
    SiteConfig.footerEmail = _footerEmailCtrl.text;
    SiteConfig.footerTelefone = _footerTelefoneCtrl.text;
    SiteConfig.footerEndereco = _footerEnderecoCtrl.text;
    SiteConfig.footerHorarioTexto = _footerHorarioCtrl.text;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configurações salvas com sucesso!'),
        backgroundColor: AppColors.pinkStrong,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _salvarConfiguracoes,
        backgroundColor: AppColors.pinkStrong,
        icon: Icon(Icons.save, color: Colors.white),
        label: Text('Salvar Configurações', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Seção Specialty',
              icon: Icons.star,
              children: [
                _buildTextField('Título', _specialtyTituloCtrl),
                _buildTextField('Descrição', _specialtyDescricaoCtrl, maxLines: 3),
                _buildTextField('Item 1 - Título', _specialtyItem1Ctrl),
                _buildTextField('Item 1 - Descrição', _specialtyItem1DescCtrl),
                _buildTextField('Item 2 - Título', _specialtyItem2Ctrl),
                _buildTextField('Item 2 - Descrição', _specialtyItem2DescCtrl),
                _buildTextField('Item 3 - Título', _specialtyItem3Ctrl),
                _buildTextField('Item 3 - Descrição', _specialtyItem3DescCtrl),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Seção Galeria',
              icon: Icons.photo_library,
              children: [
                _buildTextField('Título', _galeriaTituloCtrl),
                _buildTextField('Subtítulo', _galeriaSubtituloCtrl),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Seção Essência',
              icon: Icons.favorite,
              children: [
                _buildTextField('Título', _essenciaTituloCtrl),
                _buildTextField('Descrição', _essenciaDescricaoCtrl, maxLines: 3),
                _buildTextField('Texto do Botão', _essenciaBotaoCtrl),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Seção Pilares',
              icon: Icons.account_tree,
              children: [
                _buildTextField('Título', _pilaresTituloCtrl),
                _buildTextField('Pilar 1 - Título', _pilar1TituloCtrl),
                _buildTextField('Pilar 1 - Descrição', _pilar1DescCtrl),
                _buildTextField('Pilar 2 - Título', _pilar2TituloCtrl),
                _buildTextField('Pilar 2 - Descrição', _pilar2DescCtrl),
                _buildTextField('Pilar 3 - Título', _pilar3TituloCtrl),
                _buildTextField('Pilar 3 - Descrição', _pilar3DescCtrl),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Seção Testemunhos',
              icon: Icons.format_quote,
              children: [
                _buildTextField('Título', _testemunhosTituloCtrl),
                _buildTextField('Testemunho 1 - Nome', _testemunho1NomeCtrl),
                _buildTextField('Testemunho 1 - Texto', _testemunho1TextoCtrl, maxLines: 2),
                _buildTextField('Testemunho 2 - Nome', _testemunho2NomeCtrl),
                _buildTextField('Testemunho 2 - Texto', _testemunho2TextoCtrl, maxLines: 2),
                _buildTextField('Testemunho 3 - Nome', _testemunho3NomeCtrl),
                _buildTextField('Testemunho 3 - Texto', _testemunho3TextoCtrl, maxLines: 2),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Seção Pronta para Brilhar',
              icon: Icons.auto_awesome,
              children: [
                _buildTextField('Título', _prontaBrilharTituloCtrl),
                _buildTextField('Descrição', _prontaBrilharDescCtrl, maxLines: 2),
                _buildTextField('Texto do Botão', _prontaBrilharBotaoCtrl),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Seção Rodapé (Footer)',
              icon: Icons.menu,
              children: [
                _buildTextField('Nome da Empresa', _footerNomeCtrl),
                _buildTextField('Email', _footerEmailCtrl),
                _buildTextField('Telefone', _footerTelefoneCtrl),
                _buildTextField('Endereço', _footerEnderecoCtrl),
                _buildTextField('Horário', _footerHorarioCtrl, maxLines: 2),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.pinkStrong, size: 24),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: AppColors.brown, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          padding: EdgeInsets.all(16),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.pinkStrong)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: maxLines > 1 ? 12 : 8),
        ),
        style: TextStyle(color: AppColors.brown),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
