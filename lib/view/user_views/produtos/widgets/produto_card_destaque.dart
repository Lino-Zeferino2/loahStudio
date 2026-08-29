import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/produto_model.dart';

class ProdutoCardDestaque extends StatelessWidget {
  final Produto produto;
  final bool isInCart;
  final bool isMobile;
  final VoidCallback onToggleCart;
  final VoidCallback onOpenDetalhes;

  const ProdutoCardDestaque({
    super.key,
    required this.produto,
    required this.isInCart,
    required this.isMobile,
    required this.onToggleCart,
    required this.onOpenDetalhes,
  });

  String get _precoTexto => '€${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final isDisponivel = produto.disponivel && !produto.semEstoque;
    final imgHeight = isMobile ? 160.0 : 200.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onOpenDetalhes,
        child: Container(
          width: double.infinity,
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
                    _imagem(imgHeight),
                    Positioned(top: 12, right: 12, child: _cartButton(isDisponivel)),
                    if (produto.semEstoque)
                      const Positioned(top: 12, left: 12, child: _StatusBadge(texto: 'Esgotado', cor: Colors.red))
                    else if (produto.estoqueBaixo)
                      const Positioned(top: 12, left: 12, child: _StatusBadge(texto: 'Últimas unidades', cor: Colors.orange)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 14 : 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (produto.marca.isNotEmpty)
                        Text(produto.marca, style: TextStyle(fontSize: isMobile ? 11 : 12, color: AppColors.pinkStrong, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(produto.nome, style: TextStyle(fontSize: isMobile ? 15 : 18, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (!isMobile) ...[
                        const SizedBox(height: 8),
                        Text(produto.descricao, style: const TextStyle(fontSize: 14, color: Color(0xFF7A6A62), height: 1.4), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                      const Spacer(),
                      Text(_precoTexto, style: TextStyle(fontSize: isMobile ? 17 : 20, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagem(double height) {
    if (produto.imagemUrl != null && produto.imagemUrl!.isNotEmpty) {
      return Image.network(produto.imagemUrl!, height: height, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(height));
    }
    return _placeholder(height);
  }

  Widget _placeholder(double height) => Container(
        height: height,
        width: double.infinity,
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

class _StatusBadge extends StatelessWidget {
  final String texto;
  final Color cor;
  const _StatusBadge({required this.texto, required this.cor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(20)),
        child: Text(texto, style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
      );
}