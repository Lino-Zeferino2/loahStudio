import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/controller/pedido_controller.dart';
import 'package:loahstudio/model/pedido_model.dart';
import 'package:loahstudio/view/user_views/Compra/widgets/pedido_status_stepper.dart';

class PedidoCard extends StatefulWidget {
  final Pedido pedido;
  final bool isMobile;
  final VoidCallback? onCancelar;

  const PedidoCard({super.key, required this.pedido, required this.isMobile, this.onCancelar});

  @override
  State<PedidoCard> createState() => _PedidoCardState();
}

class _PedidoCardState extends State<PedidoCard> {
  final PedidoController _controller = PedidoController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  String _formatarData(DateTime? d) {
    if (d == null) return '--';
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  String get _precoFormatado => "€${widget.pedido.valorTotal.toStringAsFixed(2)}";

  bool get _temComprovativo => (widget.pedido.comprovativoUrl ?? '').isNotEmpty;
  bool get _podeCarregarComprovativo => widget.pedido.status == 'pendente';

  Future<void> _selecionarComprovativo() async {
    if (widget.pedido.id == null) return;

    final XFile? imagem = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (imagem == null) return;

    setState(() => _isUploading = true);

    final Uint8List bytes = await imagem.readAsBytes();
    final ok = await _controller.enviarComprovativo(widget.pedido.id!, bytes);

    if (!mounted) return;
    setState(() => _isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Comprovativo enviado com sucesso!" : "Não foi possível enviar o comprovativo. Tenta novamente."),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(widget.isMobile ? 16 : 24),
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
                "Pedido #${widget.pedido.id?.substring(0, 6).toUpperCase() ?? '------'}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A4A42), fontSize: 14),
              ),
              Text(_formatarData(widget.pedido.criadoEm), style: const TextStyle(color: Color(0xFF7A6A62), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          PedidoStatusStepper(status: widget.pedido.status),
          const SizedBox(height: 16),
          ...widget.pedido.itens.map((item) => Padding(
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
              if (widget.pedido.podeCancelar && widget.onCancelar != null)
                TextButton(
                  onPressed: widget.onCancelar,
                  child: const Text("Cancelar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          if (_podeCarregarComprovativo) ...[
            const Divider(height: 24),
            _buildComprovativoSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildComprovativoSection() {
    if (_temComprovativo) {
      // Já existe comprovativo — desativa o carregamento e explica como
      // proceder caso o cliente precise de o substituir.
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Comprovativo enviado",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Para alterar o comprovativo, contacta-nos via WhatsApp.",
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Ainda não há comprovativo — mostra o botão de carregamento.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Comprovativo de pagamento",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isUploading ? null : _selecionarComprovativo,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.pinkStrong,
              side: BorderSide(color: AppColors.pinkStrong),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isUploading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.upload_file, size: 18),
            label: Text(_isUploading ? "A enviar..." : "Carregar comprovativo"),
          ),
        ),
      ],
    );
  }
}