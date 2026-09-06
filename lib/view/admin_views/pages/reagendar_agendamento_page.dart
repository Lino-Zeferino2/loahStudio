import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/agendamento_controller.dart';
import 'package:loahstudio/model/agendamento_model.dart';
import 'package:loahstudio/model/site_config_model.dart';

/// Tela onde o admin escolhe uma nova data e hora para um agendamento já
/// existente. Ao confirmar: liberta o horário antigo, reserva o novo, e
/// atualiza o documento (o que deve disparar o teu trigger de email de
/// "agendamento atualizado" no backend).
class ReagendarAgendamentoPage extends StatefulWidget {
  final Agendamento agendamento;

  const ReagendarAgendamentoPage({super.key, required this.agendamento});

  @override
  State<ReagendarAgendamentoPage> createState() => _ReagendarAgendamentoPageState();
}

class _ReagendarAgendamentoPageState extends State<ReagendarAgendamentoPage> {
  final AgendamentoController _controller = AgendamentoController();

  bool _carregandoHorario = true;
  bool _carregandoSlots = false;
  bool _salvando = false;

  HorarioFuncionamento _horarioFuncionamento = const HorarioFuncionamento();
  List<DateTime> _datasDisponiveis = [];
  DateTime? _dataSelecionada;
  HorariosAgrupados _horariosAgrupados = const HorariosAgrupados();
  String? _horaSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarHorarioFuncionamento();
  }

  Future<void> _carregarHorarioFuncionamento() async {
    final horario = await _controller.fetchHorarioFuncionamento();
    if (!mounted) return;
    setState(() {
      _horarioFuncionamento = horario;
      _datasDisponiveis = _controller.gerarDatasDisponiveis(horario, dias: 60, limite: 30);
      _carregandoHorario = false;
    });
  }

  Future<void> _selecionarData(DateTime data) async {
    setState(() {
      _dataSelecionada = data;
      _horaSelecionada = null;
      _carregandoSlots = true;
      _horariosAgrupados = const HorariosAgrupados();
    });
    final ocupados = await _controller.fetchHorariosOcupadosPorData(data);
    if (!mounted) return;
    final agrupados = _controller.gerarHorariosAgrupados(
      horario: _horarioFuncionamento,
      duracaoMinutos: widget.agendamento.servicoDuracaoMinutos,
      data: data,
      horariosOcupados: ocupados,
    );
    setState(() {
      _horariosAgrupados = agrupados;
      _carregandoSlots = false;
    });
  }

  Future<void> _confirmarReagendamento() async {
    final data = _dataSelecionada;
    final horaInicio = _horaSelecionada;
    if (data == null || horaInicio == null) return;

    setState(() => _salvando = true);

    final inicioMin = AgendamentoController.parseHora(horaInicio);
    final horaFim = AgendamentoController.formatHora(inicioMin + widget.agendamento.servicoDuracaoMinutos);

    final sucesso = await _controller.editarAgendamento(
      widget.agendamento.id!,
      novaData: data,
      novaHoraInicio: horaInicio,
      novaHoraFim: horaFim,
    );

    if (!mounted) return;
    setState(() => _salvando = false);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agendamento reagendado! O cliente foi notificado por email.')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível reagendar. Tente novamente.'), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final agendamento = widget.agendamento;

    return Scaffold(
      backgroundColor: AppColors.lightCreamBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.brown,
        elevation: 0,
        title: const Text('Reagendar Agendamento'),
      ),
      body: _carregandoHorario
          ? const Center(child: CircularProgressIndicator(color: AppColors.pinkStrong))
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResumoAtual(agendamento),
                  const SizedBox(height: 24),
                  const Text('Escolha a nova data', style: TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildSeletorDatas(),
                  const SizedBox(height: 24),
                  if (_dataSelecionada != null) ...[
                    const Text('Escolha o novo horário', style: TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildSeletorHorarios(),
                    const SizedBox(height: 24),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_dataSelecionada != null && _horaSelecionada != null && !_salvando) ? _confirmarReagendamento : null,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, foregroundColor: AppColors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: _salvando
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                          : const Text('Confirmar novo horário'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildResumoAtual(Agendamento agendamento) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(agendamento.clienteNome, style: const TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(agendamento.servicoNome, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            'Atual: ${agendamento.data.day}/${agendamento.data.month}/${agendamento.data.year} às ${agendamento.horaInicio}',
            style: const TextStyle(color: AppColors.pinkStrong, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSeletorDatas() {
    if (_datasDisponiveis.isEmpty) {
      return const Text('Nenhuma data disponível.', style: TextStyle(color: AppColors.grey));
    }
    const meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _datasDisponiveis.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final data = _datasDisponiveis[index];
          final selecionada = _dataSelecionada != null &&
              data.year == _dataSelecionada!.year &&
              data.month == _dataSelecionada!.month &&
              data.day == _dataSelecionada!.day;
          return GestureDetector(
            onTap: () => _selecionarData(data),
            child: Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selecionada ? AppColors.pinkStrong : AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selecionada ? AppColors.pinkStrong : AppColors.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${data.day}', style: TextStyle(color: selecionada ? AppColors.white : AppColors.brown, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(meses[data.month - 1], style: TextStyle(color: selecionada ? AppColors.white : AppColors.grey, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeletorHorarios() {
    if (_carregandoSlots) {
      return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.pinkStrong)));
    }
    if (_horariosAgrupados.isEmpty) {
      return const Text('Não há horários disponíveis nesta data para a duração deste serviço.', style: TextStyle(color: AppColors.grey));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_horariosAgrupados.manha.isNotEmpty) _buildGrupoHorarios('Manhã', _horariosAgrupados.manha),
        if (_horariosAgrupados.tarde.isNotEmpty) _buildGrupoHorarios('Tarde', _horariosAgrupados.tarde),
        if (_horariosAgrupados.noite.isNotEmpty) _buildGrupoHorarios('Noite', _horariosAgrupados.noite),
      ],
    );
  }

  Widget _buildGrupoHorarios(String titulo, List<String> horarios) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: horarios.map((hora) {
              final selecionada = _horaSelecionada == hora;
              return GestureDetector(
                onTap: () => setState(() => _horaSelecionada = hora),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selecionada ? AppColors.pinkStrong : AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: selecionada ? AppColors.pinkStrong : AppColors.grey.withValues(alpha: 0.3)),
                  ),
                  child: Text(hora, style: TextStyle(color: selecionada ? AppColors.white : AppColors.brown, fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}