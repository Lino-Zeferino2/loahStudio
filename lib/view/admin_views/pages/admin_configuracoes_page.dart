import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/site_config_controller.dart';
import 'package:loahstudio/model/site_config_model.dart';
import 'package:loahstudio/view/admin_views/widgets/config_galeria_imagens_field.dart';
import 'package:loahstudio/view/admin_views/widgets/config_image_upload_field.dart';
import 'package:loahstudio/view/admin_views/widgets/config_section_card.dart';
import 'package:loahstudio/view/admin_views/widgets/config_text_field.dart';
import 'package:loahstudio/view/admin_views/widgets/horario_funcionamento_editor.dart';
import 'package:loahstudio/view/admin_views/widgets/pilares_editor.dart';
class AdminConfiguracoesPage extends StatefulWidget {
  const AdminConfiguracoesPage({super.key});

  @override
  State<AdminConfiguracoesPage> createState() =>
      _AdminConfiguracoesPageState();
}

class _AdminConfiguracoesPageState extends State<AdminConfiguracoesPage> {
  final SiteConfigController _controller = SiteConfigController();

  final _heroTituloCtrl = TextEditingController();
  final _heroDescricaoCtrl = TextEditingController();
  final _specialtyTituloCtrl = TextEditingController();
  final _specialtyDescricaoCtrl = TextEditingController();
  final _galeriaTituloCtrl = TextEditingController();
  final _galeriaDescricaoCtrl = TextEditingController();
  final _essenciaTituloCtrl = TextEditingController();
  final _essenciaDescricaoCtrl = TextEditingController();
  final _pilaresTituloCtrl = TextEditingController();
  final _testemunhosTituloCtrl = TextEditingController();
  final _prontaTituloCtrl = TextEditingController();
  final _prontaDescricaoCtrl = TextEditingController();
  final _footerNomeCtrl = TextEditingController();
  final _footerCopyrightCtrl = TextEditingController();
  final _footerRedesSociaisCtrl = TextEditingController();
  final _footerHorarioCtrl = TextEditingController();
  final _footerHorarioTextoCtrl = TextEditingController();
  final _footerEmailCtrl = TextEditingController();
  final _footerTelefoneCtrl = TextEditingController();
  final _footerEnderecoCtrl = TextEditingController();

  HorarioFuncionamento _horario = const HorarioFuncionamento();
  List<Pilar> _pilares = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await _controller.carregarConfiguracoes();
    _preencherCampos(_controller.config);
  }

  void _preencherCampos(SiteConfigModel config) {
    _heroTituloCtrl.text = config.heroTitulo;
    _heroDescricaoCtrl.text = config.heroSubtitulo;
    _specialtyTituloCtrl.text = config.specialtyTitulo;
    _specialtyDescricaoCtrl.text = config.specialtyDescricao;
    _galeriaTituloCtrl.text = config.galeriaTitulo;
    _galeriaDescricaoCtrl.text = config.galeriaSubtitulo;
    _essenciaTituloCtrl.text = config.essenciaTitulo;
    _essenciaDescricaoCtrl.text = config.essenciaDescricao;
    _pilaresTituloCtrl.text = config.pilaresTitulo;
    _testemunhosTituloCtrl.text = config.testemunhosTitulo;
    _prontaTituloCtrl.text = config.prontaBrilharTitulo;
    _prontaDescricaoCtrl.text = config.prontaBrilharDescricao;
    _footerNomeCtrl.text = config.footerNome;
    _footerCopyrightCtrl.text = config.footerCopyright;
    _footerRedesSociaisCtrl.text = config.footerRedesSociais;
    _footerHorarioCtrl.text = config.footerHorario;
    _footerHorarioTextoCtrl.text = config.footerHorarioTexto;
    _footerEmailCtrl.text = config.footerEmail;
    _footerTelefoneCtrl.text = config.footerTelefone;
    _footerEnderecoCtrl.text = config.footerEndereco;
    setState(() {
      _horario = config.horarioFuncionamento;
      _pilares = List<Pilar>.from(config.pilares);
    });
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _salvarConfiguracoes() async {
    final novaConfig = SiteConfigModel(
      heroTitulo: _heroTituloCtrl.text.trim(),
      heroSubtitulo: _heroDescricaoCtrl.text.trim(),
      heroImagemUrl: _controller.config.heroImagemUrl,
      specialtyTitulo: _specialtyTituloCtrl.text.trim(),
      specialtyDescricao: _specialtyDescricaoCtrl.text.trim(),
      galeriaTitulo: _galeriaTituloCtrl.text.trim(),
      galeriaSubtitulo: _galeriaDescricaoCtrl.text.trim(),
      galeriaImagens: _controller.config.galeriaImagens,
      essenciaTitulo: _essenciaTituloCtrl.text.trim(),
      essenciaDescricao: _essenciaDescricaoCtrl.text.trim(),
      pilaresTitulo: _pilaresTituloCtrl.text.trim(),
      pilares: _pilares,
      testemunhosTitulo: _testemunhosTituloCtrl.text.trim(),
      prontaBrilharTitulo: _prontaTituloCtrl.text.trim(),
      prontaBrilharDescricao: _prontaDescricaoCtrl.text.trim(),
      footerNome: _footerNomeCtrl.text.trim(),
      footerCopyright: _footerCopyrightCtrl.text.trim(),
      footerRedesSociais: _footerRedesSociaisCtrl.text.trim(),
      footerHorario: _footerHorarioCtrl.text.trim(),
      footerHorarioTexto: _footerHorarioTextoCtrl.text.trim(),
      footerEmail: _footerEmailCtrl.text.trim(),
      footerTelefone: _footerTelefoneCtrl.text.trim(),
      footerEndereco: _footerEnderecoCtrl.text.trim(),
      horarioFuncionamento: _horario,
    );

    final sucesso = await _controller.salvarConfiguracoes(novaConfig);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(sucesso
            ? 'Configurações guardadas com sucesso!'
            : (_controller.errorMessage ?? 'Erro ao guardar configurações')),
        backgroundColor: sucesso ? AppColors.pinkStrong : Colors.red,
      ),
    );
  }

  Future<void> _selecionarHeroImagem() async {
    await _controller.selecionarEEnviarHeroImagem();
    _mostrarErroSeExistir();
  }

  Future<void> _adicionarGaleriaImagens() async {
    await _controller.selecionarEEnviarGaleriaImagens();
    _mostrarErroSeExistir();
  }

  Future<void> _removerGaleriaImagem(String url) async {
    await _controller.removerGaleriaImagem(url);
    _mostrarErroSeExistir();
  }

  void _mostrarErroSeExistir() {
    if (_controller.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_controller.errorMessage!),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _heroTituloCtrl.dispose();
    _heroDescricaoCtrl.dispose();
    _specialtyTituloCtrl.dispose();
    _specialtyDescricaoCtrl.dispose();
    _galeriaTituloCtrl.dispose();
    _galeriaDescricaoCtrl.dispose();
    _essenciaTituloCtrl.dispose();
    _essenciaDescricaoCtrl.dispose();
    _pilaresTituloCtrl.dispose();
    _testemunhosTituloCtrl.dispose();
    _prontaTituloCtrl.dispose();
    _prontaDescricaoCtrl.dispose();
    _footerNomeCtrl.dispose();
    _footerCopyrightCtrl.dispose();
    _footerRedesSociaisCtrl.dispose();
    _footerHorarioCtrl.dispose();
    _footerHorarioTextoCtrl.dispose();
    _footerEmailCtrl.dispose();
    _footerTelefoneCtrl.dispose();
    _footerEnderecoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (_controller.isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.pinkStrong)),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _controller.isSaving ? null : _salvarConfiguracoes,
        backgroundColor: AppColors.pinkStrong,
        icon: _controller.isSaving
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(Icons.save, color: Colors.white),
        label: Text(_controller.isSaving ? 'A guardar...' : 'Salvar',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConfigSectionCard(title: 'Hero Section', icon: Icons.home, children: [
              ConfigImageUploadField(
                label: 'Imagem principal',
                imagemUrl: _controller.config.heroImagemUrl,
                isUploading: _controller.isUploadingHeroImage,
                onUploadPressed: _selecionarHeroImagem,
              ),
              SizedBox(height: 16),
              ConfigTextField(label: 'Título', controller: _heroTituloCtrl),
              ConfigTextField(label: 'Descrição', controller: _heroDescricaoCtrl, maxLines: 3),
            ]),
            SizedBox(height: 20),
            ConfigSectionCard(title: 'Specialty Section', icon: Icons.star, children: [
              ConfigTextField(label: 'Título', controller: _specialtyTituloCtrl),
              ConfigTextField(label: 'Descrição', controller: _specialtyDescricaoCtrl, maxLines: 3),
            ]),
            SizedBox(height: 20),
            ConfigSectionCard(title: 'Galeria Section', icon: Icons.photo_library, children: [
              ConfigTextField(label: 'Título', controller: _galeriaTituloCtrl),
              ConfigTextField(label: 'Descrição', controller: _galeriaDescricaoCtrl, maxLines: 2),
              SizedBox(height: 16),
              ConfigGaleriaImagensField(
                imagens: _controller.config.galeriaImagens,
                isUploading: _controller.isUploadingGaleriaImagens,
                onAdicionarPressed: _adicionarGaleriaImagens,
                onRemoverImagem: _removerGaleriaImagem,
              ),
            ]),
            SizedBox(height: 20),
            ConfigSectionCard(title: 'Essência Section', icon: Icons.favorite, children: [
              ConfigTextField(label: 'Título', controller: _essenciaTituloCtrl),
              ConfigTextField(label: 'Descrição', controller: _essenciaDescricaoCtrl, maxLines: 3),
            ]),
            SizedBox(height: 20),
            ConfigSectionCard(title: 'Pilares Section', icon: Icons.account_balance, children: [
              ConfigTextField(label: 'Título geral', controller: _pilaresTituloCtrl),
              SizedBox(height: 8),
              PilaresEditor(
                pilares: _pilares,
                onChanged: (novaLista) => setState(() => _pilares = novaLista),
              ),
            ]),
            SizedBox(height: 20),
            ConfigSectionCard(title: 'Testemunhos Section', icon: Icons.format_quote, children: [
              ConfigTextField(label: 'Título', controller: _testemunhosTituloCtrl),
            ]),
            SizedBox(height: 20),
            ConfigSectionCard(title: 'Pronta a Brilhar Section', icon: Icons.auto_awesome, children: [
              ConfigTextField(label: 'Título', controller: _prontaTituloCtrl),
              ConfigTextField(label: 'Descrição', controller: _prontaDescricaoCtrl, maxLines: 2),
            ]),
            SizedBox(height: 20),
            ConfigSectionCard(title: 'Horário de Funcionamento', icon: Icons.schedule, children: [
              HorarioFuncionamentoEditor(
                horario: _horario,
                onChanged: (novoHorario) => setState(() => _horario = novoHorario),
              ),
            ]),
            SizedBox(height: 20),
            ConfigSectionCard(title: 'Footer Section', icon: Icons.menu, children: [
              ConfigTextField(label: 'Nome', controller: _footerNomeCtrl),
              ConfigTextField(label: 'Copyright', controller: _footerCopyrightCtrl),
              ConfigTextField(label: 'Título "Redes Sociais"', controller: _footerRedesSociaisCtrl),
              ConfigTextField(label: 'Título "Horário"', controller: _footerHorarioCtrl),
              ConfigTextField(label: 'Texto do horário', controller: _footerHorarioTextoCtrl, maxLines: 3),
              ConfigTextField(label: 'Email', controller: _footerEmailCtrl),
              ConfigTextField(label: 'Telefone', controller: _footerTelefoneCtrl),
              ConfigTextField(label: 'Endereço', controller: _footerEnderecoCtrl, maxLines: 2),
            ]),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}