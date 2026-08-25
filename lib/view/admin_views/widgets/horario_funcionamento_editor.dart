import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/site_config_model.dart';

class HorarioFuncionamentoEditor extends StatelessWidget {
  final HorarioFuncionamento horario;
  final ValueChanged<HorarioFuncionamento> onChanged;

  const HorarioFuncionamentoEditor({
    super.key,
    required this.horario,
    required this.onChanged,
  });

  static const List<Map<String, String>> _dias = [
    {'key': 'segunda', 'label': 'Segunda'},
    {'key': 'terca', 'label': 'Terça'},
    {'key': 'quarta', 'label': 'Quarta'},
    {'key': 'quinta', 'label': 'Quinta'},
    {'key': 'sexta', 'label': 'Sexta'},
    {'key': 'sabado', 'label': 'Sábado'},
    {'key': 'domingo', 'label': 'Domingo'},
  ];

  void _toggleDia(String dia) {
    final dias = List<String>.from(horario.diasFuncionamento);
    if (dias.contains(dia)) {
      dias.remove(dia);
    } else {
      dias.add(dia);
    }
    onChanged(horario.copyWith(diasFuncionamento: dias));
  }

  Future<void> _selecionarHora(
    BuildContext context, {
    required Turno turno,
    required bool isInicio,
    required ValueChanged<Turno> onTurnoChanged,
  }) async {
    final horaAtual = isInicio ? turno.horaInicio : turno.horaFim;
    final partes = horaAtual.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 9,
      minute: int.tryParse(partes.length > 1 ? partes[1] : '0') ?? 0,
    );

    final resultado = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: AppColors.pinkStrong,
                ),
          ),
          child: child!,
        );
      },
    );

    if (resultado != null) {
      final horaFormatada =
          '${resultado.hour.toString().padLeft(2, '0')}:${resultado.minute.toString().padLeft(2, '0')}';
      if (isInicio) {
        onTurnoChanged(turno.copyWith(horaInicio: horaFormatada));
      } else {
        onTurnoChanged(turno.copyWith(horaFim: horaFormatada));
      }
    }
  }

  Widget _buildTurnoRow(
    BuildContext context, {
    required String nome,
    required IconData icon,
    required Turno turno,
    required ValueChanged<Turno> onTurnoChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: turno.ativo
            ? AppColors.pinkStrong.withValues(alpha: 0.06)
            : AppColors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: turno.ativo
              ? AppColors.pinkStrong.withValues(alpha: 0.3)
              : AppColors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: turno.ativo ? AppColors.pinkStrong : AppColors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Text(nome,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.brown)),
              ),
              Switch(
                value: turno.ativo,
                activeColor: AppColors.pinkStrong,
                onChanged: (valor) =>
                    onTurnoChanged(turno.copyWith(ativo: valor)),
              ),
            ],
          ),
          if (turno.ativo) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildHoraButton(
                    label: 'Início',
                    hora: turno.horaInicio,
                    onTap: () => _selecionarHora(context,
                        turno: turno,
                        isInicio: true,
                        onTurnoChanged: onTurnoChanged),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildHoraButton(
                    label: 'Fim',
                    hora: turno.horaFim,
                    onTap: () => _selecionarHora(context,
                        turno: turno,
                        isInicio: false,
                        onTurnoChanged: onTurnoChanged),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHoraButton({
    required String label,
    required String hora,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: AppColors.grey)),
            Row(
              children: [
                Text(hora,
                    style: TextStyle(
                        color: AppColors.brown, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.access_time, size: 16, color: AppColors.pinkStrong),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dias de funcionamento',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.brown,
                fontSize: 14)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dias.map((dia) {
            final ativo = horario.diasFuncionamento.contains(dia['key']);
            return FilterChip(
              label: Text(dia['label']!),
              selected: ativo,
              onSelected: (_) => _toggleDia(dia['key']!),
              selectedColor: AppColors.pinkStrong.withValues(alpha: 0.2),
              checkmarkColor: AppColors.pinkStrong,
              labelStyle: TextStyle(
                color: ativo ? AppColors.pinkStrong : AppColors.brown,
                fontWeight: ativo ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: ativo
                    ? AppColors.pinkStrong
                    : AppColors.grey.withValues(alpha: 0.4),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20),
        Text('Turnos de atendimento',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.brown,
                fontSize: 14)),
        SizedBox(height: 8),
        _buildTurnoRow(context,
            nome: 'Manhã',
            icon: Icons.wb_sunny_outlined,
            turno: horario.manha,
            onTurnoChanged: (t) => onChanged(horario.copyWith(manha: t))),
        _buildTurnoRow(context,
            nome: 'Tarde',
            icon: Icons.wb_cloudy_outlined,
            turno: horario.tarde,
            onTurnoChanged: (t) => onChanged(horario.copyWith(tarde: t))),
        _buildTurnoRow(context,
            nome: 'Noite',
            icon: Icons.nights_stay_outlined,
            turno: horario.noite,
            onTurnoChanged: (t) => onChanged(horario.copyWith(noite: t))),
      ],
    );
  }
}