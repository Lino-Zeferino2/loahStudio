import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';

class CalendarioSelector extends StatelessWidget {
  final List<DateTime> datasDisponiveis;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelect;
  final bool isMobile;

  const CalendarioSelector({
    super.key,
    required this.datasDisponiveis,
    required this.selectedDate,
    required this.onSelect,
    required this.isMobile,
  });

  String _dayName(int weekday) => const ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"][weekday - 1];
  String _monthName(int month) => const ["", "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"][month];

  String? _rotulo(DateTime data) {
    final hoje = DateTime.now();
    final d0 = DateTime(hoje.year, hoje.month, hoje.day);
    final diff = data.difference(d0).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: SizedBox(
        height: isMobile ? 84 : 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: datasDisponiveis.length,
          separatorBuilder: (_, __) => SizedBox(width: isMobile ? 8 : 12),
          itemBuilder: (context, index) {
            final data = datasDisponiveis[index];
            final isSelected = selectedDate != null &&
                selectedDate!.year == data.year &&
                selectedDate!.month == data.month &&
                selectedDate!.day == data.day;
            final rotulo = _rotulo(data);

            return GestureDetector(
              onTap: () => onSelect(data),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isMobile ? 56 : 72,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: [AppColors.pinkStrong, AppColors.pinkStrong.withValues(alpha: 0.75)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                  color: isSelected ? null : const Color(0xFFF7F4F2),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.pinkStrong.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (rotulo != null)
                      Text(rotulo, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : AppColors.pinkStrong))
                    else
                      Text(_dayName(data.weekday), style: TextStyle(fontSize: 11, color: isSelected ? Colors.white70 : const Color(0xFF7A6A62))),
                    const SizedBox(height: 4),
                    Text('${data.day}', style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF5A4A42))),
                    Text(_monthName(data.month), style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : const Color(0xFF7A6A62))),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}