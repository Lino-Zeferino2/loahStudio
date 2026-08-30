import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';

class PedidoStatusStepper extends StatelessWidget {
  final String status;

  const PedidoStatusStepper({super.key, required this.status});

  static const _etapas = ['pendente', 'confirmado', 'preparando', 'enviado', 'entregue'];
  static const _labels = ['Pendente', 'Confirmado', 'Preparando', 'Enviado', 'Entregue'];

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelado') {
      return Row(
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 18),
          const SizedBox(width: 6),
          Text('Pedido cancelado', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      );
    }

    final indiceAtual = _etapas.indexOf(status);

    return Row(
      children: List.generate(_etapas.length, (i) {
        final concluido = i <= indiceAtual;
        final isLast = i == _etapas.length - 1;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      color: i == 0 ? Colors.transparent : (concluido ? AppColors.pinkStrong : const Color(0xFFE8E4E2)),
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: concluido ? AppColors.pinkStrong : const Color(0xFFE8E4E2),
                    ),
                    child: concluido ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 4,
                        color: i < indiceAtual ? AppColors.pinkStrong : const Color(0xFFE8E4E2),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: concluido ? const Color(0xFF5A4A42) : const Color(0xFF9E9E9E),
                  fontWeight: concluido ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}