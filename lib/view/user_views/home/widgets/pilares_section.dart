import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/site_config_model.dart';
import 'package:loahstudio/view/user_views/home/widgets/home_defaults.dart';

class PilaresSection extends StatelessWidget {
  final SiteConfigModel config;
  const PilaresSection({super.key, required this.config});

  static const List<IconData> _iconesCiclo = [Icons.stars, Icons.favorite, Icons.verified, Icons.schedule, Icons.spa, Icons.diamond_outlined];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final titulo = HomeDefaults.valorOuPadrao(config.pilaresTitulo, HomeDefaults.pilaresTitulo);
    final pilares = config.pilares.isNotEmpty
        ? config.pilares.map((p) => {'titulo': p.titulo, 'descricao': p.descricao}).toList()
        : HomeDefaults.pilaresFallback;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: isMobile ? 40 : 60),
      color: AppColors.creamBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontSize: isMobile ? 24 : 36, fontWeight: FontWeight.bold, color: AppColors.brown)),
          SizedBox(height: 10),
          Text('Os fundamentos que guiam o nosso trabalho e garantem a sua satisfação.', style: TextStyle(fontSize: isMobile ? 14 : 16, color: AppColors.grey)),
          SizedBox(height: isMobile ? 24 : 40),
          Wrap(
            spacing: isMobile ? 12 : 24,
            runSpacing: isMobile ? 12 : 24,
            children: List.generate(pilares.length, (index) {
              final pilar = pilares[index];
              final icone = _iconesCiclo[index % _iconesCiclo.length];
              return isMobile
                  ? _pilarCardMobile(context, icone, pilar['titulo']!, pilar['descricao']!)
                  : _pilarCard(icone, pilar['titulo']!, pilar['descricao']!);
            }),
          ),
        ],
      ),
    );
  }

  Widget _pilarCard(IconData icone, String titulo, String descricao) {
    return Container(
      width: 260,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: Offset(0, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.pinkStrong.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icone, color: AppColors.pinkStrong, size: 26)),
          SizedBox(height: 16),
          Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brown)),
          SizedBox(height: 8),
          Text(descricao, style: TextStyle(fontSize: 14, color: AppColors.grey, height: 1.5)),
        ],
      ),
    );
  }

  Widget _pilarCardMobile(BuildContext context, IconData icone, String titulo, String descricao) {
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: Offset(0, 6))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.pinkStrong.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icone, color: AppColors.pinkStrong, size: 22)),
          SizedBox(height: 12),
          Text(titulo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.brown)),
          SizedBox(height: 6),
          Text(descricao, style: TextStyle(fontSize: 12, color: AppColors.grey, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}