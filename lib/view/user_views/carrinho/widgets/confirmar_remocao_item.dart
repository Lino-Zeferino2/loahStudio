import 'package:flutter/material.dart';

/// Mostra sempre uma confirmação antes de remover um item do carrinho
/// (usado tanto pelo swipe lateral como pelo ícone de lixo). Segue o
/// padrão do projeto de usar bottom sheet em vez de AlertDialog.
Future<bool> confirmarRemocaoItem(BuildContext context, String nomeItem) async {
  final resultado = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.delete_outline, color: Colors.red.shade400),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text("Remover item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Tem a certeza que deseja remover "$nomeItem" do carrinho?',
              style: const TextStyle(color: Color(0xFF7A6A62), fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text("Cancelar", style: TextStyle(color: Color(0xFF7A6A62), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text("Remover", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  return resultado ?? false;
}