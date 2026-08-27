import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/site_config_model.dart';
import 'package:loahstudio/view/user_views/home/widgets/home_defaults.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';

class ProntaBrilharSection extends StatelessWidget {
  final SiteConfigModel config;
  const ProntaBrilharSection({super.key, required this.config});

  void _navigateToServicos(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final titulo = HomeDefaults.valorOuPadrao(config.prontaBrilharTitulo, HomeDefaults.prontaBrilharTitulo);
    final descricao = HomeDefaults.valorOuPadrao(config.prontaBrilharDescricao, HomeDefaults.prontaBrilharDescricao);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: isMobile ? 50 : 80),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.brown, Color(0xFF3D3230)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Column(
        children: [
          Text(titulo, style: TextStyle(fontSize: isMobile ? 28 : 48, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2), textAlign: TextAlign.center),
          SizedBox(height: isMobile ? 16 : 20),
          Text(descricao, style: TextStyle(fontSize: isMobile ? 14 : 18, color: Colors.white.withValues(alpha: 0.9), height: 1.5), textAlign: TextAlign.center),
          SizedBox(height: isMobile ? 30 : 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(horizontal: isMobile ? 30 : 40, vertical: isMobile ? 16 : 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: isMobile ? 6 : 8),
            onPressed: () => _navigateToServicos(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Agendar agora", style: TextStyle(fontSize: isMobile ? 16 : 18, color: Colors.white)),
                SizedBox(width: isMobile ? 8 : 10),
                Icon(Icons.arrow_forward, color: Colors.white, size: isMobile ? 18 : 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}