import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/agendamento_model.dart';

class AgendamentoCard extends StatelessWidget {
  final Agendamento agendamento;
  final bool isMobile;
  final VoidCallback onCancelar;
  final String? imagemUrl;

  const AgendamentoCard({
    super.key,
    required this.agendamento,
    required this.isMobile,
    required this.onCancelar,
    this.imagemUrl,
  });

  Color get _corStatus {
    switch (agendamento.status) {
      case 'pendente':
        return const Color(0xFFFF9800);
      case 'confirmado':
        return const Color(0xFF4CAF50);
      case 'cancelado':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String get _statusLabel {
    switch (agendamento.status) {
      case 'pendente':
        return 'Pendente';
      case 'confirmado':
        return 'Confirmado';
      case 'cancelado':
        return 'Cancelado';
      case 'concluido':
        return 'Concluído';
      default:
        return agendamento.status;
    }
  }

  bool get _podeCancelar => agendamento.status == 'pendente' || agendamento.status == 'confirmado';

  String get _dataFormatada {
    final d = agendamento.data;
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  String get _precoFormatado => "€${agendamento.servicoPreco.toStringAsFixed(2)}";

  Widget _buildImagem(double size) {
    final borderRadius = BorderRadius.circular(size >= 60 ? 16 : 12);

    if (imagemUrl == null || imagemUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: const Color(0xFFF7F4F2), borderRadius: borderRadius),
        child: Icon(Icons.face, size: size * 0.5, color: AppColors.pinkStrong),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        imagemUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: size,
            height: size,
            color: const Color(0xFFF7F4F2),
            child: const Center(
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        },
        // Fallback silencioso: se a imagem falhar (CORS, URL quebrado,
        // etc.), cai no mesmo ícone do estado sem imagem — nunca mostra
        // um ícone de "imagem quebrada" feio.
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: const Color(0xFFF7F4F2), borderRadius: borderRadius),
          child: Icon(Icons.face, size: size * 0.5, color: AppColors.pinkStrong),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isMobile ? _buildMobile() : _buildDesktop();
  }

  Widget _buildMobile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildImagem(44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agendamento.servicoNome,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: Color(0xFF7A6A62)),
                        const SizedBox(width: 4),
                        Text(_dataFormatada, style: const TextStyle(fontSize: 12, color: Color(0xFF7A6A62))),
                        const SizedBox(width: 8),
                        const Icon(Icons.access_time, size: 12, color: Color(0xFF7A6A62)),
                        const SizedBox(width: 4),
                        Text(agendamento.horaInicio, style: const TextStyle(fontSize: 12, color: Color(0xFF7A6A62))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(_precoFormatado,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: _corStatus, borderRadius: BorderRadius.circular(12)),
                    child: Text(_statusLabel,
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              if (_podeCancelar)
                GestureDetector(
                  onTap: onCancelar,
                  child: const Text("Cancelar",
                      style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          _buildImagem(60),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(agendamento.servicoNome,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFF7A6A62)),
                    const SizedBox(width: 6),
                    Text(_dataFormatada, style: const TextStyle(fontSize: 14, color: Color(0xFF7A6A62))),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: Color(0xFF7A6A62)),
                    const SizedBox(width: 6),
                    Text(agendamento.horaInicio, style: const TextStyle(fontSize: 14, color: Color(0xFF7A6A62))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(_precoFormatado,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: _corStatus, borderRadius: BorderRadius.circular(20)),
                      child: Text(_statusLabel,
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_podeCancelar)
            TextButton(
              onPressed: onCancelar,
              child: const Text("Cancelar",
                  style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}