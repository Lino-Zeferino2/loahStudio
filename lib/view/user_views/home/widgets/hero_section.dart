import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/site_config_model.dart';
import 'package:loahstudio/view/user_views/home/widgets/home_defaults.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';

class HeroSection extends StatelessWidget {
  final SiteConfigModel config;
  const HeroSection({super.key, required this.config});

  void _navigateToServicos(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final titulo = HomeDefaults.valorOuPadrao(config.heroTitulo, HomeDefaults.heroTitulo);
    final subtitulo = HomeDefaults.valorOuPadrao(config.heroSubtitulo, HomeDefaults.heroSubtitulo);
    final imagemUrl = config.heroImagemUrl;

    return isMobile
        ? _buildMobile(context, titulo, subtitulo, imagemUrl)
        : _buildDesktop(context, titulo, subtitulo, imagemUrl);
  }

  Widget _buildImagem(String? url, {required double height}) {
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: height,
            color: AppColors.grey.withValues(alpha: 0.1),
            child: Center(child: CircularProgressIndicator(color: AppColors.pinkStrong)),
          );
        },
        errorBuilder: (context, error, stack) => Image.asset(
          "assets/images/loahcapa.png",
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset("assets/images/loahcapa.png", height: height, width: double.infinity, fit: BoxFit.cover);
  }

  Widget _buildMobile(BuildContext context, String titulo, String subtitulo, String? imagemUrl) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(16), child: _buildImagem(imagemUrl, height: 320)),
              Positioned(bottom: -25, left: 16, child: _buildQuoteCard(fontSize: 12, width: 180)),
            ],
          ),
          SizedBox(height: 36),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(titulo, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.brown, height: 1.2), textAlign: TextAlign.center),
              SizedBox(height: 12),
              Text(subtitulo, style: TextStyle(fontSize: 14, color: AppColors.grey, height: 1.5), textAlign: TextAlign.center),
              SizedBox(height: 20),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pinkStrong,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () => _navigateToServicos(context),
                    child: Text("Agendar", style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _navigateToServicos(context),
                    child: Text("Conhecer espaço", style: TextStyle(fontSize: 14, color: AppColors.brown, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context, String titulo, String subtitulo, String? imagemUrl) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: AppColors.brown, height: 1.2)),
                SizedBox(height: 20),
                Text(subtitulo, style: TextStyle(fontSize: 18, color: AppColors.grey, height: 1.5)),
                SizedBox(height: 30),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pinkStrong,
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => _navigateToServicos(context),
                      child: Text("Agendar", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    SizedBox(width: 20),
                    TextButton(
                      onPressed: () => _navigateToServicos(context),
                      child: Text("Conhecer espaço", style: TextStyle(fontSize: 16, color: AppColors.brown, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 40),
          Expanded(
            flex: 4,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(20), child: _buildImagem(imagemUrl, height: 600)),
                Positioned(bottom: -40, left: 30, child: _buildQuoteCard(fontSize: 16, width: 260)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard({required double fontSize, required double width}) {
    return Container(
      width: width,
      padding: EdgeInsets.all(width < 200 ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width < 200 ? 12 : 16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: RichText(
        text: TextSpan(
          text: '"A verdadeira ',
          style: TextStyle(color: AppColors.brown, fontSize: fontSize),
          children: [
            TextSpan(text: 'beleza', style: TextStyle(color: Color(0xFFC87F6A), fontWeight: FontWeight.bold)),
            TextSpan(text: ' nasce de dentro"'),
          ],
        ),
      ),
    );
  }
}