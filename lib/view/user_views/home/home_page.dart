// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/home_controller.dart';
import 'package:loahstudio/view/auth/auth_page.dart';
import 'package:loahstudio/view/user_views/home/widgets/hero_section.dart';
import 'package:loahstudio/view/user_views/home/widgets/servicos_destaque_section.dart';
import 'package:loahstudio/view/user_views/home/widgets/produtos_destaque_section.dart';
import 'package:loahstudio/view/user_views/home/widgets/galeria_section.dart';
import 'package:loahstudio/view/user_views/home/widgets/essencia_section.dart';
import 'package:loahstudio/view/user_views/home/widgets/pilares_section.dart';
import 'package:loahstudio/view/user_views/home/widgets/avaliacoes_section.dart';
import 'package:loahstudio/view/user_views/home/widgets/pronta_brilhar_section.dart';
import 'package:loahstudio/view/user_views/widgets/app_drawer.dart';
import 'package:loahstudio/view/user_views/widgets/build_auth_menu_item.dart';
import 'package:loahstudio/view/user_views/widgets/footer_section.dart';
import 'package:loahstudio/view/user_views/home/widgets/whatsapp_floating_button.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';
import 'package:loahstudio/view/user_views/agendamento/agendamento_page.dart';
import 'package:loahstudio/view/user_views/produtos/produtos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();

  int selectedIndex = 0;
  int? hoverIndex;

  final List<String> menuItems = ["Início", "Serviços", "Produtos", "Agendamento"];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.carregarDados();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final scaffold = isMobile ? _buildMobileScaffold() : _buildDesktopScaffold();
    final numeroWhatsapp = _controller.config.footerWhatsapp.replaceAll(RegExp(r'[^0-9]'), '');

    return Stack(
      children: [
        scaffold,
        Positioned(bottom: 24, right: 20, child: WhatsappFloatingButton(numeroWhatsapp: numeroWhatsapp)),
      ],
    );
  }

  Widget _buildMobileScaffold() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 2)),
        centerTitle: true,
      ),
    endDrawer: AppDrawer(
        selectedIndex: selectedIndex,
        menuItems: menuItems,
        onNavigate: _navigateTo,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              HeroSection(config: _controller.config),
              SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
              ServicosDestaqueSection(tituloConfig: _controller.config.specialtyTitulo, descricaoConfig: _controller.config.specialtyDescricao, servicos: _controller.servicosDestaque, isLoading: _controller.isLoading),
              SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
              ProdutosDestaqueSection(produtos: _controller.produtosDestaque, isLoading: _controller.isLoading),
              SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
              GaleriaSection(config: _controller.config),
              SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
              EssenciaSection(config: _controller.config),
              SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
              PilaresSection(config: _controller.config),
              SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
              AvaliacoesSection(avaliacoes: _controller.avaliacoes, isLoading: _controller.isLoading, isSubmitting: _controller.isSubmittingAvaliacao, onEnviarAvaliacao: _controller.enviarAvaliacao),
              SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
              ProntaBrilharSection(config: _controller.config),
              SizedBox(height: 40),
              FooterSection(config: _controller.config),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopScaffold() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: 22, letterSpacing: 3, height: 1.2)),
            Row(
              children: [
                ...List.generate(menuItems.length, (index) {
                  final isSelected = selectedIndex == index;
                  final isHover = hoverIndex == index;
                  return MouseRegion(
                    onEnter: (_) => setState(() => hoverIndex = index),
                    onExit: (_) => setState(() => hoverIndex = null),
                    child: GestureDetector(
                      onTap: () => _navigateTo(index),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(border: isSelected ? Border(bottom: BorderSide(color: AppColors.pinkNude, width: 2)) : null),
                        child: Text(menuItems[index], style: TextStyle(color: isSelected || isHover ? AppColors.pinkNude : AppColors.brown, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                      ),
                    ),
                  );
                }),
                SizedBox(width: 20),
                 buildAuthMenuItem(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage())),
                  
                  child: Text("Agendar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              HeroSection(config: _controller.config),
              SizedBox(height: 100),
              ServicosDestaqueSection(tituloConfig: _controller.config.specialtyTitulo, descricaoConfig: _controller.config.specialtyDescricao, servicos: _controller.servicosDestaque, isLoading: _controller.isLoading),
              SizedBox(height: 100),
              ProdutosDestaqueSection(produtos: _controller.produtosDestaque, isLoading: _controller.isLoading),
              SizedBox(height: 100),
              GaleriaSection(config: _controller.config),
              SizedBox(height: 100),
              EssenciaSection(config: _controller.config),
              SizedBox(height: 100),
              PilaresSection(config: _controller.config),
              SizedBox(height: 100),
              AvaliacoesSection(avaliacoes: _controller.avaliacoes, isLoading: _controller.isLoading, isSubmitting: _controller.isSubmittingAvaliacao, onEnviarAvaliacao: _controller.enviarAvaliacao),
              SizedBox(height: 100),
              ProntaBrilharSection(config: _controller.config),
              SizedBox(height: 60),
              FooterSection(config: _controller.config),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProdutosPage()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AgendamentoPage()));
    } else {
      setState(() => selectedIndex = index);
    }
  }

}