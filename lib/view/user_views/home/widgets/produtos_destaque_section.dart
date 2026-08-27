import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/produto_model.dart';
import 'package:loahstudio/view/user_views/produtos/produtos_page.dart';

class ProdutosDestaqueSection extends StatelessWidget {
  final List<Produto> produtos;
  final bool isLoading;

  const ProdutosDestaqueSection({super.key, required this.produtos, required this.isLoading});

  void _navigateToProdutos(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProdutosPage()));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    // Se não houver produtos e não estiver a carregar, a secção não aparece
    // (evita mostrar uma "loja vazia" antes de o admin cadastrar produtos).
    if (!isLoading && produtos.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: isMobile ? 40 : 60),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Produtos em Destaque', style: TextStyle(fontSize: isMobile ? 24 : 36, fontWeight: FontWeight.bold, color: AppColors.brown)),
          SizedBox(height: 10),
          Text('Selecionados especialmente para si.', style: TextStyle(fontSize: isMobile ? 14 : 16, color: AppColors.grey)),
          SizedBox(height: isMobile ? 24 : 40),
          if (isLoading)
            SizedBox(height: isMobile ? 240 : 300, child: Center(child: CircularProgressIndicator(color: AppColors.pinkStrong)))
          else
            SizedBox(
              height: isMobile ? 240 : 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: produtos.length,
                itemBuilder: (context, index) => _produtoCard(context, produtos[index], isMobile),
              ),
            ),
          SizedBox(height: isMobile ? 24 : 30),
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.pinkStrong, width: 2),
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 30, vertical: isMobile ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () => _navigateToProdutos(context),
              icon: Icon(Icons.shopping_bag_outlined, color: AppColors.pinkStrong),
              label: Text('Ver todos os produtos', style: TextStyle(fontSize: isMobile ? 14 : 16, color: AppColors.pinkStrong, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _produtoCard(BuildContext context, Produto produto, bool isMobile) {
    final width = isMobile ? 160.0 : 200.0;
    final imgHeight = isMobile ? 130.0 : 160.0;
    return GestureDetector(
      onTap: () => _navigateToProdutos(context),
      child: Container(
        width: width,
        margin: EdgeInsets.only(right: isMobile ? 14 : 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15, offset: Offset(0, 8))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: produto.imagemUrl != null && produto.imagemUrl!.isNotEmpty
                      ? Image.network(produto.imagemUrl!, height: imgHeight, width: width, fit: BoxFit.cover, errorBuilder: (c, e, s) => _placeholderImg(width, imgHeight))
                      : _placeholderImg(width, imgHeight),
                ),
                if (produto.semEstoque)
                  Positioned(top: 8, left: 8, child: _badge('Esgotado', Colors.red))
                else if (produto.estoqueBaixo)
                  Positioned(top: 8, left: 8, child: _badge('Últimas unidades', Colors.orange)),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(produto.nome, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.brown), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 6),
                  Text('€${produto.preco.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String texto, Color cor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(20)),
      child: Text(texto, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _placeholderImg(double width, double height) {
    return Container(width: width, height: height, color: AppColors.grey.withValues(alpha: 0.1), child: Icon(Icons.shopping_bag_outlined, color: AppColors.grey.withValues(alpha: 0.4), size: 28));
  }
}