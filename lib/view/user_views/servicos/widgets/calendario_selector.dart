import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/site_config_model.dart';

class CalendarioSelector extends StatefulWidget {
  final HorarioFuncionamento horario;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelect;
  final bool isMobile;
  final int mesesVisiveis;

  const CalendarioSelector({
    super.key,
    required this.horario,
    required this.selectedDate,
    required this.onSelect,
    required this.isMobile,
    this.mesesVisiveis = 5,
  });

  @override
  State<CalendarioSelector> createState() => _CalendarioSelectorState();
}

class _CalendarioSelectorState extends State<CalendarioSelector> {
  static const _diasSemana = ['segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado', 'domingo'];
  static const _nomesMes = ["", "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];
  static const _nomesDiaCurto = ["S", "T", "Q", "Q", "S", "S", "D"];

  late DateTime _hoje;
  late DateTime _mesExibido;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _hoje = DateTime(agora.year, agora.month, agora.day);
    _mesExibido = DateTime(_hoje.year, _hoje.month, 1);
  }

  bool _disponivel(DateTime dia) {
    if (dia.isBefore(_hoje)) return false;
    final diaSemana = _diasSemana[dia.weekday - 1];
    return widget.horario.diasFuncionamento.contains(diaSemana);
  }

  bool get _podeVoltar => _mesExibido.isAfter(DateTime(_hoje.year, _hoje.month, 1));
  bool get _podeAvancar {
    final limite = DateTime(_hoje.year, _hoje.month + widget.mesesVisiveis - 1, 1);
    return _mesExibido.isBefore(limite);
  }

  void _mudarMes(int delta) => setState(() => _mesExibido = DateTime(_mesExibido.year, _mesExibido.month + delta, 1));

  @override
  Widget build(BuildContext context) {
    final primeiroDia = DateTime(_mesExibido.year, _mesExibido.month, 1);
    final diasNoMes = DateTime(_mesExibido.year, _mesExibido.month + 1, 0).day;
    final offset = primeiroDia.weekday - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _podeVoltar ? () => _mudarMes(-1) : null,
                icon: Icon(Icons.chevron_left, color: _podeVoltar ? AppColors.pinkStrong : Colors.grey.shade300),
              ),
              Text('${_nomesMes[_mesExibido.month]} ${_mesExibido.year}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A4A42), fontSize: 15)),
              IconButton(
                onPressed: _podeAvancar ? () => _mudarMes(1) : null,
                icon: Icon(Icons.chevron_right, color: _podeAvancar ? AppColors.pinkStrong : Colors.grey.shade300),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: _nomesDiaCurto.map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 11, color: Color(0xFF7A6A62), fontWeight: FontWeight.w600))))).toList()),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
            itemCount: offset + diasNoMes,
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox.shrink();
              final dia = DateTime(_mesExibido.year, _mesExibido.month, index - offset + 1);
              final disponivel = _disponivel(dia);
              final isSelected = widget.selectedDate != null &&
                  widget.selectedDate!.year == dia.year && widget.selectedDate!.month == dia.month && widget.selectedDate!.day == dia.day;

              return GestureDetector(
                onTap: disponivel ? () => widget.onSelect(dia) : null,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(colors: [AppColors.pinkStrong, AppColors.pinkStrong.withValues(alpha: 0.75)]) : null,
                      color: isSelected ? null : (disponivel ? const Color(0xFFF7F4F2) : Colors.transparent),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${dia.day}',
                      style: TextStyle(
                        fontSize: widget.isMobile ? 13 : 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : (disponivel ? const Color(0xFF5A4A42) : Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}