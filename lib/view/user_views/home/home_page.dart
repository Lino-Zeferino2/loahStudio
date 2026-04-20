import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
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
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "LOAH STÚDIO",
              style: TextStyle(
                color: AppColors.brown,
                fontWeight: FontWeight.w600,
                fontSize: 22,
                letterSpacing: 3,
                height: 1.2,
              ),
            ),
            Row(
              children: [
                ...List.generate(menuItems.length, (index) {
                  final isSelected = selectedIndex == index;
                  final isHover = hoverIndex == index;
                  return MouseRegion(
                    onEnter: (_) => setState(() => hoverIndex = index),
                    onExit: (_) => setState(() => hoverIndex = null),
                    child: GestureDetector(
                      onTap: () {
                        if (index == 1) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
                        } else if (index == 2) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProdutosPage()));
                        } else if (index == 3) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AgendamentoPage()));
                        } else {
                          setState(() => selectedIndex = index);
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border(bottom: BorderSide(color: AppColors.pinkNude, width: 2))
                              : null,
                        ),
                        child: Text(
                          menuItems[index],
                          style: TextStyle(
                            color: isSelected || isHover ? AppColors.pinkNude : AppColors.brown,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinkStrong,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage())),
                  child: Text("Agendar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
          ],
        ),
      ),
    );
  }
}
