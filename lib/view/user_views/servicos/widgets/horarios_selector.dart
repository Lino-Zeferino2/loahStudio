import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/controller/agendamento_controller.dart';

class HorariosSelector extends StatelessWidget {
  final HorariosAgrupados horarios;
  final String? selectedTime;
  final ValueChanged<String> onSelect;
  final bool isMobile;

  const HorariosSelector({
    super.key,
    required this.horarios,
    required this.selectedTime,
    required this.onSelect,
    required this.isMobile,
  });

  Widget _grupo(String titulo, IconData icon, List<String> horas) {
    if (horas.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: AppColors.pinkStrong),
            const SizedBox(width: 6),
            Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7A6A62), letterSpacing: 0.5)),
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: isMobile ? 8 : 12,
            runSpacing: isMobile ? 8 : 12,
            children: horas.map((time) {
              final isSelected = selectedTime == time;
              return GestureDetector(
                onTap: () => onSelect(time),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 18, vertical: isMobile ? 8 : 12),
                  decoration: BoxDecoration(color: isSelected ? Colors.red : const Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(10)),
                  child: Text(time, style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF5A4A42))),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (horarios.isEmpty) {
      return Text(
        'Não há horários disponíveis nesta data para este serviço. Escolhe outra data.',
        style: TextStyle(color: Colors.red[400], fontSize: 13),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _grupo('MANHÃ', Icons.wb_sunny_outlined, horarios.manha),
        _grupo('TARDE', Icons.wb_cloudy_outlined, horarios.tarde),
        _grupo('NOITE', Icons.nightlight_outlined, horarios.noite),
      ],
    );
  }
}