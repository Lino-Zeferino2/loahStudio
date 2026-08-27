import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/site_config_model.dart';
import 'package:loahstudio/view/user_views/home/widgets/home_defaults.dart';

class GaleriaSection extends StatelessWidget {
  final SiteConfigModel config;
  const GaleriaSection({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final titulo = HomeDefaults.valorOuPadrao(config.galeriaTitulo, HomeDefaults.galeriaTitulo);
    final subtitulo = HomeDefaults.valorOuPadrao(config.galeriaSubtitulo, HomeDefaults.galeriaSubtitulo);
    final imagens = config.galeriaImagens.isNotEmpty ? config.galeriaImagens : HomeDefaults.galeriaImagensFallback;

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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagens.length,
              itemBuilder: (context, index) => _galeriaCard(imagens[index], isMobile),
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
      margin: EdgeInsets.only(right: isMobile ? 12 : 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(isMobile ? 16 : 20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: isMobile ? 10 : 15, offset: Offset(0, isMobile ? 6 : 8))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: Image.network(imagem, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: AppColors.grey.withValues(alpha: 0.1), child: Icon(Icons.image_not_supported_outlined, color: AppColors.grey))),
      ),
    );
  }
}