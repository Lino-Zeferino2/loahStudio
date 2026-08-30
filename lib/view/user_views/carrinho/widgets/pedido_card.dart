import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loahstudio/controller/pedido_controller.dart';
import 'package:loahstudio/model/pedido_model.dart';

class PedidoCard extends StatefulWidget { // nota: passa a StatefulWidget
  final Pedido pedido;
  final bool isMobile;
  final VoidCallback? onCancelar;

  const PedidoCard({super.key, required this.pedido, required this.isMobile, this.onCancelar});

  @override
  State<PedidoCard> createState() => _PedidoCardState();
}

class _PedidoCardState extends State<PedidoCard> {
  final _pedidoController = PedidoController();
  bool _enviando = false;

  Future<void> _enviarComprovativo() async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (imagem == null) return;

    setState(() => _enviando = true);
    final Uint8List bytes = await imagem.readAsBytes();
    final ok = await _pedidoController.enviarComprovativo(widget.pedido.id!, bytes);

    if (!mounted) return;
    setState(() => _enviando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Comprovativo enviado! Aguarda a confirmação." : "Não foi possível enviar. Tenta novamente."),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  // ...dentro do build(), na secção final onde já mostras "Total" + botão Cancelar,
  // adiciona este bloco condicional (usa widget.pedido em vez de pedido nas
  // referências que já tinhas, já que agora é StatefulWidget):

  Widget _buildComprovativoBloco() {
    if (!widget.pedido.aguardaComprovativo) {
      if (widget.pedido.comprovativoUrl != null && widget.pedido.status == 'pendente') {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(children: [
            const Icon(Icons.check_circle, size: 14, color: Colors.green),
            const SizedBox(width: 6),
            const Text("Comprovativo enviado — aguardando confirmação", style: TextStyle(fontSize: 12, color: Colors.green)),
          ]),
        );
      }
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _enviando ? null : _enviarComprovativo,
          icon: _enviando
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.upload_file, size: 16),
          label: Text(_enviando ? "A enviar..." : "Enviar comprovativo de pagamento"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}