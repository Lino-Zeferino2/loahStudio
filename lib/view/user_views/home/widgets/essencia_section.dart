import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/site_config_model.dart';
import 'package:loahstudio/view/user_views/home/widgets/home_defaults.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';

class EssenciaSection extends StatelessWidget {
  final SiteConfigModel config;
  const EssenciaSection({super.key, required this.config});

  void _navigateToServicos(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final titulo = HomeDefaults.valorOuPadrao(config.essenciaTitulo, HomeDefaults.essenciaTitulo);
    final descricao = HomeDefaults.valorOuPadrao(config.essenciaDescricao, HomeDefaults.essenciaDescricao);
    return isMobile ? _buildMobile(context, titulo, descricao) : _buildDesktop(context, titulo, descricao);
  }

  Widget _buildMobile(BuildContext context, String titulo, String descricao) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: Offset(0, 10))]),
            child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset("assets/images/logo.png", fit: BoxFit.cover)),
          ),
          SizedBox(height: 24),
          Text(titulo, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.brown, height: 1.1)),
          SizedBox(height: 12),
          Text(descricao, style: TextStyle(fontSize: 14, color: AppColors.grey, height: 1.5)),
          SizedBox(height: 24),
          _essenceItem("01", "Serum Iluminador Aura", "Ilumina e revitaliza a pele com extratos naturais.", isMobile: true),
          SizedBox(height: 10),
          _essenceItem("02", "Elixir de Harmonia", "Equilibra energias internas com óleos essenciais puros.", isMobile: true),
          SizedBox(height: 10),
          _essenceItem("03", "Néctar Regenerador", "Restaura e nutre profundamente a pele cansada.", isMobile: true),
          SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 4),
            onPressed: () => _navigateToServicos(context),
            icon: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            label: Text("Explorar coleção completa", style: TextStyle(fontSize: 14, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context, String titulo, String descricao) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              height: 500,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30, offset: Offset(0, 15))]),
              child: ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.asset("assets/images/logo.png", fit: BoxFit.cover)),
            ),
          ),
          SizedBox(width: 40),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.brown, height: 1.1)),
                SizedBox(height: 16),
                Text(descricao, style: TextStyle(fontSize: 18, color: AppColors.grey, height: 1.5)),
                SizedBox(height: 32),
                _essenceItem("01", "Serum Iluminador Aura", "Ilumina e revitaliza a pele com extratos naturais.", isMobile: false),
                SizedBox(height: 12),
                _essenceItem("02", "Elixir de Harmonia", "Equilibra energias internas com óleos essenciais puros.", isMobile: false),
                SizedBox(height: 12),
                _essenceItem("03", "Néctar Regenerador", "Restaura e nutre profundamente a pele cansada.", isMobile: false),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 4),
                  onPressed: () => _navigateToServicos(context),
                  icon: Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  label: Text("Explorar coleção completa", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _essenceItem(String number, String title, String desc, {required bool isMobile}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isMobile ? 28 : 36,
          height: isMobile ? 28 : 36,
          decoration: BoxDecoration(color: Color(0xFFC87F6A), borderRadius: BorderRadius.circular(isMobile ? 8 : 12)),
          child: Center(child: Text(number, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 14))),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w600, color: AppColors.brown)),
              SizedBox(height: isMobile ? 2 : 4),
              Text(desc, style: TextStyle(fontSize: isMobile ? 12 : 14, color: AppColors.grey, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}