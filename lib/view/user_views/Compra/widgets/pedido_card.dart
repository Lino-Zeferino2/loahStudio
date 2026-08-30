import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/pedido_model.dart';
import 'package:loahstudio/view/user_views/Compra/widgets/pedido_status_stepper.dart';

class PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final bool isMobile;
  final VoidCallback? onCancelar;

  const PedidoCard({super.key, required this.pedido, required this.isMobile, this.onCancelar});

  String _formatarData(DateTime? d) {
    if (d == null) return '--';
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  String get _precoFormatado => "€${pedido.valorTotal.toStringAsFixed(2)}";

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pedido #${pedido.id?.substring(0, 6).toUpperCase() ?? '------'}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A4A42), fontSize: 14),
              ),
              Text(_formatarData(pedido.criadoEm), style: const TextStyle(color: Color(0xFF7A6A62), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          PedidoStatusStepper(status: pedido.status),
          const SizedBox(height: 16),
          ...pedido.itens.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item.imagemUrl.isEmpty
                          ? Container(
                              width: 40, height: 40, color: const Color(0xFFF7F4F2),
                              child: Icon(Icons.shopping_bag_outlined, size: 18, color: AppColors.pinkStrong))
                          : Image.network(
                              item.imagemUrl, width: 40, height: 40, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 40, height: 40, color: const Color(0xFFF7F4F2),
                                child: Icon(Icons.shopping_bag_outlined, size: 18, color: AppColors.pinkStrong)),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text("${item.nome} x${item.quantidade}",
                          style: const TextStyle(fontSize: 13, color: Color(0xFF5A4A42)), overflow: TextOverflow.ellipsis),
                    ),
                    Text("€${item.subtotal.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7A6A62))),
                  ],
                ),
              )),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total: $_precoFormatado", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pinkStrong, fontSize: 15)),
              if (pedido.podeCancelar && onCancelar != null)
                TextButton(
                  onPressed: onCancelar,
                  child: const Text("Cancelar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}