import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/carrinho_item_model.dart';
import 'package:loahstudio/view/user_views/carrinho/widgets/confirmar_remocao_item.dart';

class CarrinhoItemCard extends StatelessWidget {
  final CarrinhoItem item;
  final bool isMobile;
  final VoidCallback onIncrementar;
  final VoidCallback onDecrementar;

  /// Chamado depois de a remoção já ter sido confirmada (pelo swipe ou
  /// pelo ícone de lixo) — só atualiza a lista, nunca remove sem perguntar.
  final VoidCallback onRemovido;

  const CarrinhoItemCard({
    super.key,
    required this.item,
    required this.isMobile,
    required this.onIncrementar,
    required this.onDecrementar,
    required this.onRemovido,
  });

  Future<void> _confirmarERemover(BuildContext context) async {
    final confirmado = await confirmarRemocaoItem(context, item.nome);
    if (confirmado) onRemovido();
  }

  Widget _imagem(double tamanho) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
      child: Image.network(
        item.imagemUrl,
        width: tamanho,
        height: tamanho,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: tamanho,
          height: tamanho,
          color: AppColors.creamBg,
          child: Icon(Icons.image, color: AppColors.grey, size: tamanho * 0.45),
        ),
      ),
    );
  }

  Widget _seletorQuantidade({required double iconSize, required double fontSize}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove, size: iconSize),
            color: const Color(0xFF5A4A42),
            padding: const EdgeInsets.all(3),
            constraints: const BoxConstraints(),
            onPressed: onDecrementar,
          ),
          Container(
            width: 22,
            alignment: Alignment.center,
            child: Text("${item.quantidade}", style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: const Color(0xFF5A4A42))),
          ),
          IconButton(
            icon: Icon(Icons.add, size: iconSize),
            color: const Color(0xFF5A4A42),
            padding: const EdgeInsets.all(3),
            constraints: const BoxConstraints(),
            onPressed: onIncrementar,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('${item.produtoId}_${item.nome}_${item.hashCode}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmarRemocaoItem(context, item.nome),
      onDismissed: (_) => onRemovido(),
      background: Container(
        margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(isMobile ? 10 : 16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: isMobile ? _cardMobile(context) : _cardDesktop(context),
    );
  }

  Widget _cardMobile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))]),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _imagem(40),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.marca, style: TextStyle(fontSize: 8, color: AppColors.pinkStrong, fontWeight: FontWeight.w600, letterSpacing: 1), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(item.nome, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text("€${item.preco.toStringAsFixed(2)}", style: const TextStyle(fontSize: 10, color: Color(0xFF7A6A62))),
                ],
              ),
            ),
            SizedBox(
              width: 56,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _seletorQuantidade(iconSize: 10, fontSize: 11),
                  const SizedBox(height: 4),
                  Text("€${item.subtotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                ],
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(onTap: () => _confirmarERemover(context), child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade400)),
          ],
        ),
      ),
    );
  }

  Widget _cardDesktop(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Row(
        children: [
          _imagem(56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.marca, style: TextStyle(fontSize: 11, color: AppColors.pinkStrong, fontWeight: FontWeight.w600, letterSpacing: 1), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(item.nome, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("€${item.preco.toStringAsFixed(2)} / unidade", style: const TextStyle(fontSize: 13, color: Color(0xFF7A6A62))),
              ],
            ),
          ),
          _seletorQuantidade(iconSize: 14, fontSize: 15),
          const SizedBox(width: 20),
          SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("€${item.subtotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _confirmarERemover(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, size: 14, color: Colors.red.shade400),
                      const SizedBox(width: 2),
                      Text("Remover", style: TextStyle(fontSize: 12, color: Colors.red.shade400)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}