import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/controller/notificacao_controller.dart';
import 'package:loahstudio/view/notificacoes/notificacao_page.dart';

/// Ícone de notificações com badge de não lidas — usado tanto na Home
/// pública (utilizador autenticado) como no AdminLayout.
class NotificacaoIconButton extends StatelessWidget {
  final Color? cor;
  const NotificacaoIconButton({super.key, this.cor});

  @override
  Widget build(BuildContext context) {
    final corIcone = cor ?? AppColors.brown;
    return StreamBuilder<int>(
      stream: NotificacaoController().streamContagemNaoLidas(),
      builder: (context, snapshot) {
        final naoLidas = snapshot.data ?? 0;
        return IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificacaoPage())),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined, color: corIcone, size: 28),
              if (naoLidas > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(color: AppColors.pinkStrong, shape: BoxShape.circle),
                    child: Text(
                      naoLidas > 9 ? '9+' : '$naoLidas',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}