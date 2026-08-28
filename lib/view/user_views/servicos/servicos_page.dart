// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/agendamento_controller.dart';
import 'package:loahstudio/controller/home_controller.dart';
import 'package:loahstudio/model/agendamento_model.dart';
import 'package:loahstudio/model/servico_model.dart';
import 'package:loahstudio/model/site_config_model.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';
import 'package:loahstudio/view/user_views/agendamento/agendamento_page.dart';
import 'package:loahstudio/view/user_views/produtos/produtos_page.dart';
import 'package:loahstudio/view/user_views/servicos/widgets/servico_card.dart';
import 'package:loahstudio/view/user_views/servicos/widgets/calendario_selector.dart';
import 'package:loahstudio/view/user_views/servicos/widgets/horarios_selector.dart';
import 'package:loahstudio/view/user_views/servicos/widgets/dados_pessoais_section.dart';
import 'package:loahstudio/view/user_views/widgets/footer_section.dart';
import 'package:loahstudio/view/user_views/widgets/app_drawer.dart';

class ServicosPage extends StatefulWidget {
  const ServicosPage({super.key});

  @override
  _ServicosPageState createState() => _ServicosPageState();
}

class _ServicosPageState extends State<ServicosPage> {
  final AgendamentoController _controller = AgendamentoController();
  final HomeController _homeController = HomeController();
  final GlobalKey<DadosPessoaisSectionState> _dadosKey = GlobalKey();

  int selectedIndex = 1;
  int? hoverIndex;

  Servico? selectedServico;
  DateTime? selectedDate;
  String? selectedTime;
  bool aceitouTermos = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final observacaoController = TextEditingController();

  HorarioFuncionamento? _horario;
  bool _isLoadingHorario = true;

  bool _isLoadingHorarios = false;
  HorariosAgrupados _horariosAgrupados = const HorariosAgrupados();

  bool _isSubmitting = false;

  final List<String> menuItems = ["Início", "Serviços", "Produtos", "Agendamento"];

  @override
  void initState() {
    super.initState();
    _carregarHorarioFuncionamento();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarHorarioFuncionamento() async {
    final horario = await _controller.fetchHorarioFuncionamento();
    if (!mounted) return;
    setState(() {
      _horario = horario;
      _isLoadingHorario = false;
    });
  }

  Future<void> _atualizarHorarios() async {
    if (selectedServico == null || selectedDate == null || _horario == null) {
      setState(() => _horariosAgrupados = const HorariosAgrupados());
      return;
    }
    setState(() => _isLoadingHorarios = true);

    final existentes = await _controller.fetchAgendamentosPorData(selectedDate!);
    final agrupados = _controller.gerarHorariosAgrupados(
      horario: _horario!,
      duracaoMinutos: selectedServico!.duracaoMinutos,
      data: selectedDate!,
      agendamentosExistentes: existentes,
    );

    if (!mounted) return;
    setState(() {
      _horariosAgrupados = agrupados;
      _isLoadingHorarios = false;
      final todos = [...agrupados.manha, ...agrupados.tarde, ...agrupados.noite];
      if (selectedTime != null && !todos.contains(selectedTime)) selectedTime = null;
    });
  }

  void _selecionarServico(Servico servico) {
    setState(() { selectedServico = servico; selectedTime = null; });
    _atualizarHorarios();
  }

  void _selecionarData(DateTime data) {
    setState(() { selectedDate = data; selectedTime = null; });
    _atualizarHorarios();
  }

  Future<void> _confirmarAgendamento() async {
    if (selectedServico == null || selectedDate == null || selectedTime == null ||
        nameController.text.trim().isEmpty || emailController.text.trim().isEmpty ||
        telefoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos e selecione um serviço, data e horário'), backgroundColor: Colors.red),
      );
      return;
    }

    final estaLogado = _dadosKey.currentState?.isLoggedIn ?? false;
    if (!estaLogado && !aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tens de aceitar os termos e condições para continuar'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final inicioMin = AgendamentoController.parseHora(selectedTime!);
    final fimMin = inicioMin + selectedServico!.duracaoMinutos;
    final horaFim = AgendamentoController.formatHora(fimMin);

    final agendamento = Agendamento(
      clienteNome: nameController.text.trim(),
      clienteEmail: emailController.text.trim(),
      clienteTelefone: telefoneController.text.trim(),
      observacao: observacaoController.text.trim().isEmpty ? null : observacaoController.text.trim(),
      servicoId: selectedServico!.id!,
      servicoNome: selectedServico!.nome,
      servicoPreco: selectedServico!.preco,
      servicoDuracaoMinutos: selectedServico!.duracaoMinutos,
      data: selectedDate!,
      horaInicio: selectedTime!,
      horaFim: horaFim,
    );

    final sucesso = await _controller.criarAgendamento(agendamento);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (sucesso) {
      _showConfirmationDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este horário acabou de ser reservado por outra pessoa. Escolhe outro.'), backgroundColor: Colors.red),
      );
      _atualizarHorarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final headerTitleSize = ResponsiveHelper.headerTitleSize(context);

    return Scaffold(
      endDrawer: isMobile
          ? AppDrawer(selectedIndex: selectedIndex, menuItems: menuItems, onNavigate: _navegarMenu)
          : null,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: headerTitleSize, letterSpacing: 3)),
                ),
                if (!isCompact)
                  Row(children: [
                    ...List.generate(menuItems.length, (index) {
                      final isSelected = selectedIndex == index;
                      final isHover = hoverIndex == index;
                      return MouseRegion(
                        onEnter: (_) => setState(() => hoverIndex = index),
                        onExit: (_) => setState(() => hoverIndex = null),
                        child: GestureDetector(
                          onTap: () => _navegarMenu(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 12.0),
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(border: isSelected ? Border(bottom: BorderSide(color: AppColors.pinkNude, width: 2)) : null),
                            child: Text(menuItems[index], style: TextStyle(color: isSelected || isHover ? AppColors.pinkNude : AppColors.brown, fontSize: isMobile ? 14.0 : 16.0, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                          ),
                        ),
                      );
                    }),
                    SizedBox(width: isMobile ? 10.0 : 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(horizontal: isMobile ? 14.0 : 20.0, vertical: isMobile ? 8.0 : 12.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendamentoPage())),
                      child: Text("Agendar", style: TextStyle(color: Colors.white, fontSize: isMobile ? 13.0 : 14.0)),
                    ),
                  ]),
              ],
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: isMobile ? 20.0 : 40.0),
          _introSection(isMobile),
          SizedBox(height: isMobile ? 30.0 : 60.0),
          _servicosList(isMobile),
          SizedBox(height: isMobile ? 30.0 : 60.0),
          _calendarSection(isMobile),
          SizedBox(height: isMobile ? 30.0 : 60.0),
          _formSection(isMobile),
          SizedBox(height: isMobile ? 50.0 : 100.0),
          FooterSection(config: _homeController.config),
        ]),
      ),
    );
  }

  void _navegarMenu(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage()), (route) => route.isFirst);
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProdutosPage()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendamentoPage()));
    } else {
      setState(() => selectedIndex = index);
    }
  }

  Widget _introSection(bool isMobile) {
    // Idêntico ao original desta tela (imagem/logo + texto de introdução) —
    // não tinha sido alterado nas respostas anteriores, cola aqui o teu
    // método original.
    return Container();
  }

  Widget _servicosList(bool isMobile) {
    final double horizontalPad = isMobile ? 16.0 : 60.0;
    final double titleSize = isMobile ? 20.0 : 28.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Escolha o seu serviço", style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
          SizedBox(height: isMobile ? 16.0 : 30.0),
          StreamBuilder<List<Servico>>(
            stream: _controller.streamServicosDisponiveis(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Erro ao carregar serviços: ${snapshot.error}', style: const TextStyle(color: Colors.red));
              if (!snapshot.hasData) return const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()));
              final servicos = snapshot.data!;
              if (servicos.isEmpty) {
                return Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('Ainda não há serviços disponíveis. Volta em breve!', style: TextStyle(color: AppColors.grey))));
              }
              return Column(
                children: servicos.map((s) => ServicoCard(
                  servico: s,
                  isSelected: selectedServico?.id == s.id,
                  isMobile: isMobile,
                  onTap: () => _selecionarServico(s),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _calendarSection(bool isMobile) {
    final double horizontalPad = isMobile ? 16.0 : 60.0;

    if (_isLoadingHorario) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()));
    }
    if (_horario == null || _horario!.diasFuncionamento.isEmpty) {
      return Padding(padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 20), child: Text('De momento não há dias de funcionamento configurados.', style: TextStyle(color: AppColors.grey)));
    }

    final dataSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Selecione a Data", style: TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
        SizedBox(height: isMobile ? 12 : 20),
        CalendarioSelector(horario: _horario!, selectedDate: selectedDate, onSelect: _selecionarData, isMobile: isMobile),
      ],
    );

    final horaSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Selecione o Horário", style: TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
        SizedBox(height: isMobile ? 12 : 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 5))]),
          child: _buildHorariosContent(isMobile),
        ),
      ],
    );

    if (isMobile) {
      return Container(padding: EdgeInsets.symmetric(horizontal: horizontalPad), child: Column(children: [dataSection, const SizedBox(height: 20), horaSection]));
    }
    return Container(padding: EdgeInsets.symmetric(horizontal: horizontalPad), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: dataSection), const SizedBox(width: 40), Expanded(child: horaSection)]));
  }

  Widget _buildHorariosContent(bool isMobile) {
    if (selectedServico == null) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('Escolhe um serviço acima para ver os horários disponíveis.', style: TextStyle(color: AppColors.grey, fontSize: 13)));
    }
    if (selectedDate == null) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('Escolhe uma data para ver os horários disponíveis.', style: TextStyle(color: AppColors.grey, fontSize: 13)));
    }
    if (_isLoadingHorarios) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()));
    }
    return HorariosSelector(horarios: _horariosAgrupados, selectedTime: selectedTime, onSelect: (t) => setState(() => selectedTime = t), isMobile: isMobile);
  }

  Widget _formSection(bool isMobile) {
    final horizontalPad = isMobile ? 16.0 : 60.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Dados Pessoais", style: TextStyle(fontSize: isMobile ? 18.0 : 20.0, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
          SizedBox(height: isMobile ? 12.0 : 20.0),
          Container(
            padding: EdgeInsets.all(isMobile ? 16.0 : 30.0),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 5))]),
            child: Column(
              children: [
                if (selectedServico != null) _buildResumoSelecao(),
                if (selectedServico != null) SizedBox(height: isMobile ? 16 : 24),
                DadosPessoaisSection(
                  key: _dadosKey,
                  nomeController: nameController,
                  emailController: emailController,
                  telefoneController: telefoneController,
                  observacaoController: observacaoController,
                  isMobile: isMobile,
                  aceitouTermos: aceitouTermos,
                  onAceitouTermosChanged: (v) => setState(() => aceitouTermos = v),
                ),
                SizedBox(height: isMobile ? 20.0 : 30.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(vertical: isMobile ? 14.0 : 18.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)), elevation: 4),
                    onPressed: _isSubmitting ? null : _confirmarAgendamento,
                    child: _isSubmitting
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                        : Text("Confirmar Agendamento", style: TextStyle(fontSize: isMobile ? 14.0 : 18.0, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoSelecao() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(selectedServico!.nome, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A4A42), fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            selectedDate != null && selectedTime != null
                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} às $selectedTime · €${selectedServico!.preco.toStringAsFixed(0)}'
                : 'Escolhe a data e o horário abaixo',
            style: const TextStyle(color: Color(0xFF7A6A62), fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Agendamento Confirmado!", style: TextStyle(color: Color(0xFF5A4A42))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Serviço: ${selectedServico?.nome}"),
            const SizedBox(height: 8),
            Text("Data: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
            const SizedBox(height: 8),
            Text("Hora: $selectedTime"),
            const SizedBox(height: 8),
            Text("Nome: ${nameController.text}"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: Text("OK", style: TextStyle(color: AppColors.pinkStrong)))],
      ),
    );
  }
}