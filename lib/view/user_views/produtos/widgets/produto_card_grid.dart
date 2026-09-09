import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/produto_model.dart';
import 'package:loahstudio/controller/favoritos_controller.dart';
import 'package:loahstudio/model/favorito_model.dart';

class ProdutoCardGrid extends StatelessWidget {
  final Produto produto;
  final bool isInCart;
  final bool isCompact;
  final VoidCallback onToggleCart;
  final VoidCallback onOpenDetalhes;
  final double width;
  final bool isFavorited;
  final VoidCallback? onToggleFavorito;

  const ProdutoCardGrid({
    super.key,
    required this.produto,
    required this.isInCart,
    required this.isCompact,
    required this.onToggleCart,
    required this.onOpenDetalhes,
    this.width = 260,
    this.isFavorited = false,
    this.onToggleFavorito,
  });

  String get _precoTexto => '€${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final isDisponivel = produto.disponivel && !produto.semEstoque;
    final imgHeight = isCompact ? 90.0 : 180.0;

    return GestureDetector(
      onTap: onOpenDetalhes,
      child: Container(
        width: isCompact ? width : 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: isCompact ? 8 : 15, offset: Offset(0, isCompact ? 4 : 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(isCompact ? 16 : 20)),
              child: Stack(
                children: [
                  _imagem(imgHeight, isCompact ? width : 260),
                  if (!isDisponivel)
                    Positioned(top: 8, left: 8, child: _miniBadge('ESGOTADO', Colors.red, isCompact))
                  else if (produto.estoqueBaixo)
                    Positioned(top: 8, left: 8, child: _miniBadge('POUCAS UNID.', Colors.orange, isCompact)),
                  Positioned(top: 8, right: 8, child: _cartButton(isDisponivel)),
                  Positioned(top: 8, right: 48, child: _favButton()),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isCompact ? 8 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (produto.marca.isNotEmpty)
                    Text(produto.marca, style: TextStyle(fontSize: isCompact ? 9 : 11, color: AppColors.pinkStrong, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  SizedBox(height: isCompact ? 4 : 6),
                  Text(produto.nome, style: TextStyle(fontSize: isCompact ? 12 : 16, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: isCompact ? 4 : 12),
                  Text(_precoTexto, style: TextStyle(fontSize: isCompact ? 14 : 18, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagem(double height, double width) {
    if (produto.imagemUrl != null && produto.imagemUrl!.isNotEmpty) {
      return Image.network(produto.imagemUrl!, height: height, width: width, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(height, width));
    }
    return _placeholder(height, width);
  }

  Widget _placeholder(double height, double width) => Container(
        height: height,
        width: width,
        color: AppColors.pinkNude.withValues(alpha: 0.3),
        child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 32, color: AppColors.pinkStrong)),
      );

  Widget _miniBadge(String texto, Color cor, bool isCompact) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(10)),
        child: Text(texto, style: TextStyle(fontSize: isCompact ? 7 : 9, color: Colors.white, fontWeight: FontWeight.bold)),
      );

  Widget _cartButton(bool isDisponivel) {
    return GestureDetector(
      onTap: isDisponivel ? onToggleCart : null,
      child: Container(
        width: isCompact ? 28 : 40,
        height: isCompact ? 28 : 40,
        decoration: BoxDecoration(
          color: isInCart ? AppColors.pinkStrong : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Icon(isInCart ? Icons.check : Icons.add_shopping_cart, color: isInCart ? Colors.white : (isDisponivel ? AppColors.pinkStrong : Colors.grey), size: isCompact ? 14 : 20),
      ),
    );
  }

  Widget _favButton() => GestureDetector(
    onTap: onToggleFavorito,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: Colors.white, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Icon(isFavorited ? Icons.favorite : Icons.favorite_border, color: isFavorited ? Colors.red : Colors.grey[600], size: 18),
    ),
  );
}