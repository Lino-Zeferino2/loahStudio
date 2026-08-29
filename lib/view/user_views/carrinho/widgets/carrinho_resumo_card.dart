import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/carrinho_item_model.dart';

class CarrinhoResumoCard extends StatelessWidget {
  final List<CarrinhoItem> itens;
  final double total;
  final bool isMobile;
  final VoidCallback? onFinalizarCompra;

  const CarrinhoResumoCard({
    super.key,
    required this.itens,
    required this.total,
    required this.isMobile,
    required this.onFinalizarCompra,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                Text("€${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                onPressed: itens.isEmpty ? null : onFinalizarCompra,
                child: const Text("Finalizar compra", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    // Desktop: painel lateral fixo, como o resumo do pedido nos grandes sites de compras.
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Resumo do pedido", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          if (itens.isEmpty)
            const Text("Sem artigos no carrinho.", style: TextStyle(fontSize: 13, color: Color(0xFF7A6A62)))
          else
            ...itens.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text("${item.nome} x${item.quantidade}", style: const TextStyle(fontSize: 13, color: Color(0xFF7A6A62)), overflow: TextOverflow.ellipsis),
                      ),
                      Text("€${item.subtotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF5A4A42))),
                    ],
                  ),
                )),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
              Text("€${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 4),
              onPressed: itens.isEmpty ? null : onFinalizarCompra,
              child: const Text("Finalizar compra", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 16, color: Color(0xFF7A6A62)),
                const SizedBox(width: 8),
                const Text("Pagamento seguro", style: TextStyle(fontSize: 12, color: Color(0xFF7A6A62))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}