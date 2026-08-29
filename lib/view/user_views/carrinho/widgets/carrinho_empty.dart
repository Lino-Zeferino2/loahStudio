import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';

/// IMPORTANTE: usa mainAxisSize.min (em vez de Center + mainAxisAlignment
/// .center dentro de um Column sem altura limitada) — foi essa combinação
/// que causava o RenderFlex overflow quando o carrinho estava vazio.
class CarrinhoEmptyState extends StatelessWidget {
  final VoidCallback onVerProdutos;

  const CarrinhoEmptyState({super.key, required this.onVerProdutos});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text(
            "O seu carrinho está vazio",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42)),
          ),
          const SizedBox(height: 12),
          const Text(
            "Adicione produtos para continuar",
            style: TextStyle(fontSize: 16, color: Color(0xFF7A6A62)),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinkStrong,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            onPressed: onVerProdutos,
            child: const Text("Ver produtos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}