import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';

class NotificacaoEmptyState extends StatelessWidget {
  const NotificacaoEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 56, color: AppColors.grey.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text('Sem notificações por aqui', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
            const SizedBox(height: 8),
            const Text(
              'Quando houver novidades sobre os teus agendamentos ou compras, aparecem aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7A6A62)),
            ),
          ],
        ),
      ),
    );
  }
}