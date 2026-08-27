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
      endDrawer: Drawer(
        child: Container(
          padding: EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 40),
              ListTile(leading: Icon(Icons.home, color: selectedIndex == 0 ? AppColors.pinkNude : AppColors.brown), title: Text("Início", style: TextStyle(color: selectedIndex == 0 ? AppColors.pinkNude : AppColors.brown, fontWeight: selectedIndex == 0 ? FontWeight.bold : FontWeight.normal)), onTap: () => _navigateTo(0)),
              ListTile(leading: Icon(Icons.face, color: selectedIndex == 1 ? AppColors.pinkNude : AppColors.brown), title: Text("Serviços", style: TextStyle(color: selectedIndex == 1 ? AppColors.pinkNude : AppColors.brown, fontWeight: selectedIndex == 1 ? FontWeight.bold : FontWeight.normal)), onTap: () => _navigateTo(1)),
              ListTile(leading: Icon(Icons.shopping_bag, color: selectedIndex == 2 ? AppColors.pinkNude : AppColors.brown), title: Text("Produtos", style: TextStyle(color: selectedIndex == 2 ? AppColors.pinkNude : AppColors.brown, fontWeight: selectedIndex == 2 ? FontWeight.bold : FontWeight.normal)), onTap: () => _navigateTo(2)),
              ListTile(leading: Icon(Icons.event, color: selectedIndex == 3 ? AppColors.pinkNude : AppColors.brown), title: Text("Agendamento", style: TextStyle(color: selectedIndex == 3 ? AppColors.pinkNude : AppColors.brown, fontWeight: selectedIndex == 3 ? FontWeight.bold : FontWeight.normal)), onTap: () => _navigateTo(3)),
              _buildAuthMenuItem(isMobile: true),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
                },
                child: Text("Agendar", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
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
                _buildAuthMenuItem(),
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

  Widget _buildAuthMenuItem({bool isMobile = false}) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.data != null;
        if (isMobile) {
          return ListTile(
            leading: Icon(isLoggedIn ? Icons.logout : Icons.login, color: AppColors.brown),
            title: Text(isLoggedIn ? "Logout" : "Login", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w500)),
            onTap: () async {
              if (isLoggedIn) {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) Navigator.pop(context);
              } else {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage()));
              }
            },
          );
        }
        return GestureDetector(
          onTap: () async {
            if (isLoggedIn) {
              await FirebaseAuth.instance.signOut();
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage()));
            }
          },
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text(isLoggedIn ? "Logout" : "Login", style: TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.w500))),
        );
      },
    );
  }
}