import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/produto_model.dart';

class ProdutoCardGrid extends StatelessWidget {
  final Produto produto;
  final bool isInCart;
  final bool isCompact; // versão mobile mais pequena
  final VoidCallback onToggleCart;
  final double width;

  const ProdutoCardGrid({
    super.key,
    required this.produto,
    required this.isInCart,
    required this.isCompact,
    required this.onToggleCart,
    this.width = 260,
  });

  String get _precoTexto => '€${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final isDisponivel = produto.disponivel && !produto.semEstoque;
    final imgHeight = isCompact ? 90.0 : 180.0;

    return GestureDetector(
      onTap: isDisponivel ? onToggleCart : null,
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
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                        child: Text('ESGOTADO', style: TextStyle(fontSize: isCompact ? 7 : 9, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  else if (produto.estoqueBaixo)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
                        child: Text('POUCAS UNID.', style: TextStyle(fontSize: isCompact ? 7 : 9, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (isInCart)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.pinkStrong, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 12),
                      ),
                    ),
                  if (!isCompact && isDisponivel)
                    Positioned(top: 12, right: 12, child: _cartButtonDesktop()),
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

  Widget _cartButtonDesktop() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isInCart ? AppColors.pinkStrong : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Icon(isInCart ? Icons.check : Icons.shopping_bag_outlined, color: isInCart ? Colors.white : AppColors.pinkStrong, size: 20),
    );
  }
}