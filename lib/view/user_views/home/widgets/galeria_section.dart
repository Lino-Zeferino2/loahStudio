import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/site_config_model.dart';
import 'package:loahstudio/view/user_views/home/widgets/home_defaults.dart';

class GaleriaSection extends StatefulWidget {
  final SiteConfigModel config;
  const GaleriaSection({super.key, required this.config});

  @override
  State<GaleriaSection> createState() => _GaleriaSectionState();
}

class _GaleriaSectionState extends State<GaleriaSection> {
  static const _intervaloAutoplay = Duration(seconds: 3);
  static const _duracaoAnimacao = Duration(milliseconds: 600);
  // Número grande de "páginas virtuais": o índice real da imagem é sempre
  // `index % imagens.length`. Começar a meio deste intervalo dá a ilusão
  // de um carrossel infinito, sem nunca precisar de saltar de volta ao
  // índice 0 de forma visível quando o autoplay chega ao fim da lista.
  static const _paginasVirtuais = 100000;

  late PageController _pageController;
  Timer? _autoplayTimer;
  bool? _isMobileAtual;
  int _totalImagensAtual = 0;
  bool _trocaAgendada = false;

  int get _paginaInicial => _paginasVirtuais ~/ 2;

  double _fracaoViewport(bool isMobile) => isMobile ? 0.42 : 0.22;

  // NÃO usar MediaQuery/ResponsiveHelper aqui dentro — dependOnInheritedWidgetOfExactType
  // só é seguro a partir de didChangeDependencies() ou build(), nunca em initState().
  @override
  void initState() {
    super.initState();
  }

  /// Primeira vez que as dependências (incluindo MediaQuery) ficam
  /// disponíveis — corre sempre depois de initState() e antes do
  /// primeiro build(), por isso é o sítio seguro para a configuração
  /// inicial do PageController que depende do breakpoint mobile/desktop.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isMobileAtual == null) {
      final isMobile = ResponsiveHelper.isMobile(context);
      _isMobileAtual = isMobile;
      _pageController = PageController(viewportFraction: _fracaoViewport(isMobile), initialPage: _paginaInicial);
    }
  }

  /// Agenda a troca do PageController para depois deste frame terminar —
  /// trocar/descartar o controller a meio do build fazia o PageView
  /// antigo e o novo disputarem o mesmo Element no mesmo frame.
  void _agendarTrocaDeBreakpoint(bool isMobile) {
    if (_trocaAgendada) return;
    _trocaAgendada = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _trocarControllerParaBreakpoint(isMobile));
  }

  void _trocarControllerParaBreakpoint(bool isMobile) {
    _trocaAgendada = false;
    if (!mounted || _isMobileAtual == isMobile) return;

    final paginaAtual = _pageController.hasClients ? (_pageController.page?.round() ?? _paginaInicial) : _paginaInicial;
    final controllerAntigo = _pageController;

    setState(() {
      _pageController = PageController(viewportFraction: _fracaoViewport(isMobile), initialPage: paginaAtual);
      _isMobileAtual = isMobile;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => controllerAntigo.dispose());
  }

  void _iniciarAutoplay(int totalImagens) {
    if (totalImagens <= 1) return;
    _autoplayTimer?.cancel();
    _autoplayTimer = Timer.periodic(_intervaloAutoplay, (_) {
      if (!_pageController.hasClients) return;
      final proxima = (_pageController.page ?? _paginaInicial.toDouble()).round() + 1;
      _pageController.animateToPage(proxima, duration: _duracaoAnimacao, curve: Curves.easeInOut);
    });
  }

  void _pausarTemporariamente(int totalImagens) {
    _autoplayTimer?.cancel();
    _autoplayTimer = Timer(const Duration(seconds: 5), () => _iniciarAutoplay(totalImagens));
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    if (_isMobileAtual != isMobile) {
      _agendarTrocaDeBreakpoint(isMobile);
    }

    final titulo = HomeDefaults.valorOuPadrao(widget.config.galeriaTitulo, HomeDefaults.galeriaTitulo);
    final subtitulo = HomeDefaults.valorOuPadrao(widget.config.galeriaSubtitulo, HomeDefaults.galeriaSubtitulo);
    final imagens = widget.config.galeriaImagens.isNotEmpty ? widget.config.galeriaImagens : HomeDefaults.galeriaImagensFallback;

    if (imagens.length != _totalImagensAtual) {
      _totalImagensAtual = imagens.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _iniciarAutoplay(_totalImagensAtual);
      });
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: isMobile ? 40 : 60),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontSize: isMobile ? 24 : 36, fontWeight: FontWeight.bold, color: AppColors.brown)),
          SizedBox(height: 10),
          Text(subtitulo, style: TextStyle(fontSize: isMobile ? 14 : 16, color: AppColors.grey)),
          SizedBox(height: isMobile ? 30 : 40),
          SizedBox(
            height: isMobile ? 160 : 280,
            child: imagens.isEmpty
                ? const SizedBox.shrink()
                : NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollStartNotification && notification.dragDetails != null) {
                        _autoplayTimer?.cancel();
                      } else if (notification is ScrollEndNotification && notification.dragDetails != null) {
                        _pausarTemporariamente(imagens.length);
                      }
                      return false;
                    },
                    child: PageView.builder(
                      key: ValueKey(_isMobileAtual),
                      controller: _pageController,
                      itemCount: imagens.length > 1 ? _paginasVirtuais : 1,
                      itemBuilder: (context, index) {
                        final indiceReal = index % imagens.length;
                        return Center(child: _galeriaCard(imagens[indiceReal], isMobile));
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _galeriaCard(String imagem, bool isMobile) {
    final width = isMobile ? 140.0 : 200.0;
    final height = isMobile ? 160.0 : 250.0;
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(isMobile ? 16 : 20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: isMobile ? 10 : 15, offset: Offset(0, isMobile ? 6 : 8))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: Image.network(imagem, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: AppColors.grey.withValues(alpha: 0.1), child: Icon(Icons.image_not_supported_outlined, color: AppColors.grey))),
      ),
    );
  }
}