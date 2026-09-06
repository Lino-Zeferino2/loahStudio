import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/agendamento_model.dart';

class AgendamentoCard extends StatelessWidget {
  final Agendamento agendamento;
  final bool isMobile;
  final VoidCallback onCancelar;
  final VoidCallback? onEditar;
  final String? imagemUrl;

  const AgendamentoCard({
    super.key,
    required this.agendamento,
    required this.isMobile,
    required this.onCancelar,
    this.onEditar,
    this.imagemUrl,
  });

  Color get _corStatus {
    switch (agendamento.status) {
      case 'pendente':
        return const Color(0xFFFF9800);
      case 'confirmado':
        return const Color(0xFF4CAF50);
      case 'concluido':
        return const Color(0xFF2196F3);
      case 'cancelado':
        return const Color(0xFFE53935);
      default:
        return AppColors.grey;
    }
  }

  String get _statusLabel {
    switch (agendamento.status) {
      case 'pendente':
        return 'Pendente';
      case 'confirmado':
        return 'Confirmado';
      case 'concluido':
        return 'Concluído';
      case 'cancelado':
        return 'Cancelado';
      default:
        return agendamento.status;
    }
  }

  bool get _podeCancelar =>
      agendamento.status == 'pendente' || agendamento.status == 'confirmado';

  bool get _podeEditar =>
      agendamento.status == 'pendente' || agendamento.status == 'confirmado';

  String _formatarData(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imagemUrl != null && imagemUrl!.isNotEmpty
                    ? Image.network(
                        imagemUrl!,
                        width: isMobile ? 70 : 90,
                        height: isMobile ? 70 : 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: isMobile ? 70 : 90,
                          height: isMobile ? 70 : 90,
                          color: AppColors.lightCreamBg,
                          child: const Icon(Icons.image_not_supported, color: AppColors.grey),
                        ),
                      )
                    : Container(
                        width: isMobile ? 70 : 90,
                        height: isMobile ? 70 : 90,
                        color: AppColors.lightCreamBg,
                        child: const Icon(Icons.spa, color: AppColors.pinkNude),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agendamento.servicoNome,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatarData(agendamento.data)} • ${agendamento.horaInicio}',
                      style: TextStyle(fontSize: 13, color: const Color(0xFF7A6A62)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'R\$ ${agendamento.servicoPreco.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.pinkStrong),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: _corStatus, borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            _statusLabel,
                            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_podeEditar || _podeCancelar) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_podeEditar && onEditar != null)
                  TextButton.icon(
                    onPressed: onEditar,
                    icon: const Icon(Icons.edit_calendar, size: 18),
                    label: const Text('Editar'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.pinkStrong),
                  ),
                if (_podeCancelar)
                  TextButton.icon(
                    onPressed: onCancelar,
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancelar'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
