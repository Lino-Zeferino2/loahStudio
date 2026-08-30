import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';

Future<void> mostrarConfirmacaoPedido(
  BuildContext context, {
  required String email,
  required String metodoPagamento,
  required VoidCallback onContinuar,
}) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  final iconSize = isMobile ? 60.0 : 80.0;
  final titleSize = isMobile ? 20.0 : 24.0;
  final textSize = isMobile ? 14.0 : 16.0;

  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: iconSize),
          SizedBox(height: isMobile ? 16 : 20),
          Text("Pedido registado!", style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
          const SizedBox(height: 8),
          Text(
            "Vais receber uma confirmação no email:\n$email",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: textSize, color: const Color(0xFF7A6A62)),
          ),
          SizedBox(height: isMobile ? 12.0 : 20.0),
          Container(
            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
            decoration: BoxDecoration(color: const Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text("Falta um passo", style: TextStyle(fontWeight: FontWeight.w600, fontSize: textSize)),
                const SizedBox(height: 8),
                Text(
                  "Depois de efetuares o pagamento, envia o comprovativo pelo WhatsApp "
                  "ou carrega-o na página \"As minhas Compras\" — o teu pedido só avança depois disso.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isMobile ? 12 : 14, color: const Color(0xFF7A6A62)),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinkStrong,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 40, vertical: isMobile ? 12 : 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              onContinuar();
            },
            child: Text("Continuar a compras", style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16)),
          ),
        ],
      ),
    ),
  );
}