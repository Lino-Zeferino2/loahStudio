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
  // Hero Section
  final _heroTituloCtrl = TextEditingController(text: SiteConfig.heroTitulo);
  final _heroDescricaoCtrl = TextEditingController(text: SiteConfig.heroSubtitulo);


  // Specialty Section
  final _specialtyTituloCtrl = TextEditingController(text: SiteConfig.specialtyTitulo);
  final _specialtyDescricaoCtrl = TextEditingController(text: SiteConfig.specialtyDescricao);


  // Galeria Section
  final _galeriaTituloCtrl = TextEditingController(text: SiteConfig.galeriaTitulo);
  final _galeriaDescricaoCtrl = TextEditingController(text: SiteConfig.galeriaSubtitulo);


  // Essencia Section
  final _essenciaTituloCtrl = TextEditingController(text: SiteConfig.essenciaTitulo);
  final _essenciaDescricaoCtrl = TextEditingController(text: SiteConfig.essenciaDescricao);


  // Pilares Section (apenas titulo)
  final _pilaresTituloCtrl = TextEditingController(text: SiteConfig.pilaresTitulo);


  // Testemunhos Section (apenas titulo)
  final _testemunhosTituloCtrl = TextEditingController(text: SiteConfig.testemunhosTitulo);


  // Pronta Brilhar Section
  final _prontaTituloCtrl = TextEditingController(text: SiteConfig.prontaBrilharTitulo);
  final _prontaDescricaoCtrl = TextEditingController(text: SiteConfig.prontaBrilharDescricao);


  // Footer Section (apenas nome)
  final _footerNomeCtrl = TextEditingController(text: SiteConfig.footerNome);


  void _salvarConfiguracoes() {
    // Hero
    SiteConfig.heroTitulo = _heroTituloCtrl.text;
    SiteConfig.heroSubtitulo = _heroDescricaoCtrl.text;


    // Specialty
    SiteConfig.specialtyTitulo = _specialtyTituloCtrl.text;
    SiteConfig.specialtyDescricao = _specialtyDescricaoCtrl.text;


    // Galeria
    SiteConfig.galeriaTitulo = _galeriaTituloCtrl.text;
    SiteConfig.galeriaSubtitulo = _galeriaDescricaoCtrl.text;


    // Essencia
    SiteConfig.essenciaTitulo = _essenciaTituloCtrl.text;
    SiteConfig.essenciaDescricao = _essenciaDescricaoCtrl.text;

    // Pilares
    SiteConfig.pilaresTitulo = _pilaresTituloCtrl.text;


    // Testemunhos
    SiteConfig.testemunhosTitulo = _testemunhosTituloCtrl.text;


    // Pronta Brilhar
    SiteConfig.prontaBrilharTitulo = _prontaTituloCtrl.text;
    SiteConfig.prontaBrilharDescricao = _prontaDescricaoCtrl.text;


    // Footer
    SiteConfig.footerNome = _footerNomeCtrl.text;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Configuracoes salvas!'), backgroundColor: AppColors.pinkStrong),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);


    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _salvarConfiguracoes,
        backgroundColor: AppColors.pinkStrong,
        icon: Icon(Icons.save, color: Colors.white),
        label: Text('Salvar', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Hero Section', Icons.home, [
              _buildField('Titulo', _heroTituloCtrl),
              _buildField('Descricao', _heroDescricaoCtrl, maxLines: 3),
            ]),
            SizedBox(height: 20),
            _buildSection('Specialty Section', Icons.star, [
              _buildField('Titulo', _specialtyTituloCtrl),
              _buildField('Descricao', _specialtyDescricaoCtrl, maxLines: 3),
            ]),
            SizedBox(height: 20),
            _buildSection('Galeria Section', Icons.photo_library, [
              _buildField('Titulo', _galeriaTituloCtrl),
              _buildField('Descricao', _galeriaDescricaoCtrl, maxLines: 2),
            ]),
            SizedBox(height: 20),
            _buildSection('Essencia Section', Icons.favorite, [
              _buildField('Titulo', _essenciaTituloCtrl),
              _buildField('Descricao', _essenciaDescricaoCtrl, maxLines: 3),
            ]),
            SizedBox(height: 20),
            _buildSection('Pilares Section', Icons.account_balance, [
              _buildField('Titulo', _pilaresTituloCtrl),
            ]),
            SizedBox(height: 20),
            _buildSection('Testemunhos Section', Icons.format_quote, [
              _buildField('Titulo', _testemunhosTituloCtrl),
            ]),
            SizedBox(height: 20),
            _buildSection('Pronta Brilhar Section', Icons.auto_awesome, [
              _buildField('Titulo', _prontaTituloCtrl),
              _buildField('Descricao', _prontaDescricaoCtrl, maxLines: 2),
            ]),
            SizedBox(height: 20),
            _buildSection('Footer Section', Icons.menu, [
              _buildField('Nome', _footerNomeCtrl),
            ]),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }


  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.pinkStrong, size: 24),
            SizedBox(width: 8),
            Text(title, style: TextStyle(color: AppColors.brown, fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }


  Widget _buildField(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.pinkStrong),
          ),
        ),
        style: TextStyle(color: AppColors.brown),
      ),
    );
  }
}
