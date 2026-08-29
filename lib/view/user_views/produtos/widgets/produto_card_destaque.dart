import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/produto_model.dart';

class ProdutoCardDestaque extends StatelessWidget {
  final Produto produto;
  final bool isInCart;
  final VoidCallback onToggleCart;

  const ProdutoCardDestaque({
    super.key,
    required this.produto,
    required this.isInCart,
    required this.onToggleCart,
  });

  String get _precoTexto => '€${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}';

  Widget _statusLabel() {
    if (produto.semEstoque) {
      return _badge('Esgotado', Colors.red);
    }
    if (produto.estoqueBaixo) {
      return _badge('Últimas unidades', Colors.orange);
    }
    return const SizedBox.shrink();
  }

  Widget _badge(String texto, Color cor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(20)),
        child: Text(texto, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    final isDisponivel = produto.disponivel && !produto.semEstoque;

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                _imagem(200, 300),
                Positioned(top: 12, right: 12, child: _cartButton(isDisponivel)),
                if (!isDisponivel) Positioned(top: 12, left: 12, child: _statusLabel()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (produto.marca.isNotEmpty)
                  Text(produto.marca, style: TextStyle(fontSize: 12, color: AppColors.pinkStrong, fontWeight: FontWeight.w600, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(produto.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(produto.descricao, style: const TextStyle(fontSize: 14, color: Color(0xFF7A6A62), height: 1.4), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_precoTexto, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                    if (isDisponivel && produto.estoqueBaixo)
                      Text('Restam poucas unidades', style: TextStyle(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.w500))
                    else if (!isDisponivel)
                      const Text('Esgotado', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 40, color: AppColors.pinkStrong)),
      );

  Widget _cartButton(bool isDisponivel) {
    return GestureDetector(
      onTap: isDisponivel ? onToggleCart : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isInCart ? AppColors.pinkStrong : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Icon(isInCart ? Icons.check : Icons.shopping_bag_outlined, color: isInCart ? Colors.white : (isDisponivel ? AppColors.pinkStrong : Colors.grey), size: 20),
      ),
    );
  }
}