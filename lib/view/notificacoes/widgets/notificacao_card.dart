import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/notificacao_model.dart';

class NotificacaoCard extends StatelessWidget {
  final Notificacao notificacao;
  final bool isMobile;
  final VoidCallback onTap;

  const NotificacaoCard({super.key, required this.notificacao, required this.isMobile, required this.onTap});

  IconData get _icone {
    switch (notificacao.tipo) {
      case NotificacaoTipo.agendamentoCriado:
      case NotificacaoTipo.pedidoCriado:
        return Icons.add_circle_outline;
      case NotificacaoTipo.agendamentoConfirmado:
      case NotificacaoTipo.pedidoConfirmado:
        return Icons.check_circle_outline;
      case NotificacaoTipo.agendamentoCancelado:
      case NotificacaoTipo.pedidoCancelado:
        return Icons.cancel_outlined;
      case NotificacaoTipo.agendamentoReagendado:
        return Icons.update;
      case NotificacaoTipo.agendamentoConcluido:
        return Icons.star_outline;
      case NotificacaoTipo.agendamentoLembrete24h:
      case NotificacaoTipo.agendamentoLembrete1h:
        return Icons.alarm;
      case NotificacaoTipo.pedidoPreparando:
        return Icons.inventory_2_outlined;
      case NotificacaoTipo.pedidoEntregue:
        return Icons.local_shipping_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _tempoRelativo() {
    final criadoEm = notificacao.criadoEm;
    if (criadoEm == null) return '';
    final diff = DateTime.now().difference(criadoEm);
    if (diff.inMinutes < 1) return 'agora mesmo';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays < 7) return 'há ${diff.inDays}d';
    return '${criadoEm.day.toString().padLeft(2, '0')}/${criadoEm.month.toString().padLeft(2, '0')}/${criadoEm.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: notificacao.lida ? Colors.white : AppColors.pinkStrong.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: notificacao.lida ? null : Border.all(color: AppColors.pinkStrong.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.pinkStrong.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(_icone, color: AppColors.pinkStrong, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notificacao.titulo,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 15,
                                fontWeight: notificacao.lida ? FontWeight.w500 : FontWeight.bold,
                                color: const Color(0xFF5A4A42),
                              ),
                            ),
                          ),
                          if (!notificacao.lida)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8, top: 4),
                              decoration: const BoxDecoration(color: AppColors.pinkStrong, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notificacao.corpo,
                        style: TextStyle(fontSize: isMobile ? 12 : 13, color: const Color(0xFF7A6A62), height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      Text(_tempoRelativo(), style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}