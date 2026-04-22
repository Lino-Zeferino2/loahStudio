import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/view/user_views/home/home_components.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';
import 'package:loahstudio/view/user_views/agendamento/agendamento_page.dart';
import 'package:loahstudio/view/user_views/produtos/produtos_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  int? hoverIndex;

  final List<String> menuItems = [
    "Início",
    "Serviços",
    "Produtos",
    "Agendamento",
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return Scaffold(
      appBar: isMobile ? _buildMobileAppBar() : null,
      body: isMobile ? _buildMobileBody() : _buildDesktopBody(),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 2)),
          Builder(builder: (context) => IconButton(icon: Icon(Icons.menu, color: AppColors.brown), onPressed: () => Scaffold.of(context).openEndDrawer())),
        ],
      ),
    );
  }

  IconData _getMenuIcon(int index) {
    switch(index){case 0:return Icons.home;case 1:return Icons.face;case 2:return Icons.shopping_bag;case 3:return Icons.event;default:return Icons.arrow_forward;}
  }

  Widget _buildMobileBody() {
    return SafeArea(child: Scaffold(
      endDrawer: Drawer(
        child: Container(
          padding: EdgeInsets.all(20),
          color: Colors.white,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 40),
            ...List.generate(menuItems.length, (index) => ListTile(
              leading: Icon(_getMenuIcon(index), color: selectedIndex == index ? AppColors.pinkNude : AppColors.brown),
              title: Text(menuItems[index], style: TextStyle(color: selectedIndex == index ? AppColors.pinkNude : AppColors.brown, fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal)),
              onTap: () { Navigator.pop(context); _navigateTo(index); },
            )),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage())); },
              child: Text("Agendar", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
          ]),
        ),
      ),
      body: SingleChildScrollView(child: Column(children: [
      SizedBox(height: 20),
      HeroSection(),
      SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
      SpecialtySection(),
      SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
      GaleriaLoahSection(),
      SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
      LoahEssenciaSection(),
      SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
      NossosPilaresSection(),
      SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
      TestemunhosSection(),
      SizedBox(height: ResponsiveHelper.sectionSpacing(context)),
      ProntaBrilharSection(),
      SizedBox(height: 40),
      FooterSection(),
    ]))));
  }

  Widget _buildDesktopBody() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: 22, letterSpacing: 3, height: 1.2)),
            Row(children: [
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage())),
                child: Text("Agendar", style: TextStyle(color: Colors.white)),
              ),
            ]),
          ],
        ),
      ),
      body: SafeArea(child: SingleChildScrollView(child: Column(children: [
        SizedBox(height: 40),
        HeroSection(),
        SizedBox(height: 100),
        SpecialtySection(),
        SizedBox(height: 100),
        GaleriaLoahSection(),
        SizedBox(height: 100),
        LoahEssenciaSection(),
        SizedBox(height: 100),
        NossosPilaresSection(),
        SizedBox(height: 100),
        TestemunhosSection(),
        SizedBox(height: 100),
        ProntaBrilharSection(),
        SizedBox(height: 60),
        FooterSection(),
      ]))),
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
