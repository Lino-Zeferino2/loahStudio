import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/servico_model.dart';
import 'package:loahstudio/view/user_views/home/widgets/home_defaults.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';

class ServicosDestaqueSection extends StatelessWidget {
  final String tituloConfig;
  final String descricaoConfig;
  final List<Servico> servicos;
  final bool isLoading;

  const ServicosDestaqueSection({
    super.key,
    required this.tituloConfig,
    required this.descricaoConfig,
    required this.servicos,
    required this.isLoading,
  });

  void _navigateToServicos(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final titulo = HomeDefaults.valorOuPadrao(tituloConfig, HomeDefaults.specialtyTitulo);
    final descricao = HomeDefaults.valorOuPadrao(descricaoConfig, HomeDefaults.specialtyDescricao);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: isMobile ? 40 : 60),
      color: AppColors.creamBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontSize: isMobile ? 24 : 36, fontWeight: FontWeight.bold, color: AppColors.brown)),
          SizedBox(height: 10),
          Text(descricao, style: TextStyle(fontSize: isMobile ? 14 : 16, color: AppColors.grey)),
          SizedBox(height: isMobile ? 24 : 40),
          if (isLoading)
            SizedBox(height: isMobile ? 280 : 340, child: Center(child: CircularProgressIndicator(color: AppColors.pinkStrong)))
          else if (servicos.isEmpty)
            _buildEmptyState()
          else
            SizedBox(
              height: isMobile ? 280 : 340,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: servicos.length,
                itemBuilder: (context, index) => _servicoCard(context, servicos[index], isMobile),
              ),
            ),
          SizedBox(height: isMobile ? 24 : 30),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkStrong,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 30 : 40, vertical: isMobile ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 4,
              ),
              onPressed: () => _navigateToServicos(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Ver todos os serviços", style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: isMobile ? 16 : 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey.withValues(alpha: 0.2))),
      child: Column(
        children: [
          Icon(Icons.face_retouching_natural, color: AppColors.grey.withValues(alpha: 0.5), size: 40),
          SizedBox(height: 12),
          Text('Em breve novos serviços por aqui.', style: TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _servicoCard(BuildContext context, Servico servico, bool isMobile) {
    final width = isMobile ? 200.0 : 260.0;
    final imgHeight = isMobile ? 120.0 : 160.0;
    return GestureDetector(
      onTap: () => _navigateToServicos(context),
      child: Container(
        width: width,
        margin: EdgeInsets.only(right: isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: isMobile ? 15 : 20, offset: Offset(0, isMobile ? 8 : 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(isMobile ? 16 : 20)),
              child: servico.imagemUrl != null && servico.imagemUrl!.isNotEmpty
                  ? Image.network(servico.imagemUrl!, height: imgHeight, width: width, fit: BoxFit.cover, errorBuilder: (c, e, s) => _placeholderImg(width, imgHeight))
                  : _placeholderImg(width, imgHeight),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(servico.nome, style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold, color: AppColors.brown)),
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(servico.descricao, style: TextStyle(fontSize: isMobile ? 12 : 13, color: AppColors.grey, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: isMobile ? 8 : 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('A partir de €${servico.preco.toStringAsFixed(0)}', style: TextStyle(fontSize: isMobile ? 13 : 15, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
                      Container(
                        padding: EdgeInsets.all(isMobile ? 6 : 8),
                        decoration: BoxDecoration(color: AppColors.pinkStrong, borderRadius: BorderRadius.circular(isMobile ? 16 : 20)),
                        child: Icon(Icons.arrow_forward, color: Colors.white, size: isMobile ? 14 : 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImg(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: AppColors.grey.withValues(alpha: 0.1),
      child: Icon(Icons.spa_outlined, color: AppColors.grey.withValues(alpha: 0.4), size: 32),
    );
  }
}