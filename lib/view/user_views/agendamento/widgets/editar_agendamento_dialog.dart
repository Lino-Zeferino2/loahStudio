import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/controller/agendamento_controller.dart';
import 'package:loahstudio/model/agendamento_model.dart';
import 'package:loahstudio/model/servico_model.dart';

class EditarAgendamentoDialog extends StatefulWidget {
  final Agendamento agendamento;
  final Map<String, Servico> servicosMap;
  final VoidCallback? onConfirmado;

  const EditarAgendamentoDialog({
    super.key,
    required this.agendamento,
    required this.servicosMap,
    this.onConfirmado,
  });

  @override
  State<EditarAgendamentoDialog> createState() => _EditarAgendamentoDialogState();
}

class _EditarAgendamentoDialogState extends State<EditarAgendamentoDialog> {
  late DateTime _data;
  late String _horaInicio;
  late String _horaFim;
  late String _servicoNome;
  bool _carregando = false;
  final AgendamentoController _controller = AgendamentoController();

  @override
  void initState() {
    super.initState();
    _data = widget.agendamento.data;
    _horaInicio = widget.agendamento.horaInicio;
    _horaFim = widget.agendamento.horaFim;
    _servicoNome = widget.agendamento.servicoNome;
  }

  Future<void> _salvar() async {
    setState(() => _carregando = true);

    bool ok = await _controller.editarAgendamento(
      widget.agendamento.id!,
      novaData: _data,
      novaHoraInicio: _horaInicio,
      novaHoraFim: _horaFim,
    );

    if (mounted) {
      setState(() => _carregando = false);
      if (ok) {
        Navigator.pop(context, true);
        widget.onConfirmado?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento atualizado!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar. Tente novamente.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Agendamento', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.brown)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${widget.agendamento.clienteNome}', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: AppColors.pinkStrong),
              title: const Text('Data'),
              subtitle: Text('${_data.day}/${_data.month}/${_data.year}'),
              onTap: () async {
                final selecionada = await showDatePicker(
                  context: context,
                  initialDate: _data,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selecionada != null) setState(() => _data = selecionada);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: AppColors.pinkStrong),
              title: const Text('Horário Início'),
              subtitle: Text(_horaInicio),
              onTap: () async {
                final hora = await _selecionarHora(_horaInicio);
                if (hora != null) setState(() => _horaInicio = hora);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time_filled, color: AppColors.pinkStrong),
              title: const Text('Horário Fim'),
              subtitle: Text(_horaFim),
              onTap: () async {
                final hora = await _selecionarHora(_horaFim);
                if (hora != null) setState(() => _horaFim = hora);
              },
            ),
            const Divider(),
            Text('Serviço: ${widget.agendamento.servicoNome}', style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('Duracao: ${widget.agendamento.servicoDuracaoMinutos} min', style: const TextStyle(color: AppColors.grey)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _carregando ? null : _salvar,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong),
          child: _carregando
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Future<String?> _selecionarHora(String atual) async {
    final partes = atual.split(':');
    final h = int.tryParse(partes[0]) ?? 9;
    final m = int.tryParse(partes[1]) ?? 0;
    final horaSelecionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: h, minute: m),
    );
    if (horaSelecionada != null) {
      return '${horaSelecionada.hour.toString().padLeft(2, '0')}:${horaSelecionada.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }
}
