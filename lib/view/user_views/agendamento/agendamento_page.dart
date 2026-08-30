// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/agendamento_controller.dart';
import 'package:loahstudio/controller/home_controller.dart';
import 'package:loahstudio/model/agendamento_model.dart';
import 'package:loahstudio/model/servico_model.dart';
import 'package:loahstudio/view/auth/auth_page.dart' show AuthPage;
import 'package:loahstudio/view/user_views/home/home_page.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';
import 'package:loahstudio/view/user_views/produtos/produtos_page.dart';
import 'package:loahstudio/view/user_views/agendamento/widgets/agendamento_card.dart';
import 'package:loahstudio/view/user_views/agendamento/widgets/agendamento_empty_state.dart';
import 'package:loahstudio/view/user_views/widgets/footer_section.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({super.key});

  @override
  _AgendamentoPageState createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  final _controller = AgendamentoController();
  int? hoverIndex;

  late final Stream<User?> _authStream;
  Stream<List<Agendamento>>? _agendamentosStream;
  String? _uidAtual;

  Map<String, Servico> _servicosMap = {};
  bool _carregandoServicos = true;

  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Este menu já não inclui "Agendamento" — a página passou a ser acedida
  // a partir do Perfil, não da navegação principal do site.
  final List<String> menuItems = ["Início", "Serviços", "Produtos"];
  final HomeController homeContoller = HomeController();

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
    _carregarServicos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarServicos() async {
    final mapa = await _controller.fetchServicosMap();
    if (!mounted) return;
    setState(() {
      _servicosMap = mapa;
      _carregandoServicos = false;
    });
  }

  Future<void> _cancelar(Agendamento agendamento) async {
    final confirmar = await _showCancelDialog(agendamento);
    if (confirmar != true) return;

    bool ok = false;
    try {
      ok = await _controller.cancelarAgendamento(agendamento.id!);
    } catch (_) {
      ok = false;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Agendamento cancelado com sucesso!" : "Não foi possível cancelar. Tente novamente."),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  Future<bool?> _showCancelDialog(Agendamento agendamento) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cancelar Agendamento?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Serviço: ${agendamento.servicoNome}"),
            const SizedBox(height: 8),
            Text("Data: ${_formatarData(agendamento.data)} às ${agendamento.horaInicio}"),
            const SizedBox(height: 16),
            const Text("Tem a certeza que deseja cancelar este agendamento?",
                style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Não", style: TextStyle(color: Color(0xFF7A6A62))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sim, cancelar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final headerTitleSize = ResponsiveHelper.headerTitleSize(context);

    return Scaffold(
      endDrawer: isMobile ? _buildMobileDrawer() : null,
      appBar: _buildAppBar(isMobile, headerTitleSize),
      body: StreamBuilder<User?>(
        stream: _authStream,
        builder: (context, authSnap) {
          final user = authSnap.data;
          final logado = user != null;

          if (logado && _uidAtual != user.uid) {
            _uidAtual = user.uid;
            _agendamentosStream = _controller.streamMeusAgendamentos();
          } else if (!logado && _uidAtual != null) {
            _uidAtual = null;
            _agendamentosStream = null;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: isMobile ? 20.0 : 40.0),
                _introSection(isMobile, logado),
                SizedBox(height: isMobile ? 30.0 : 60.0),
                if (logado) ...[
                  _buildSearchBar(isMobile),
                  SizedBox(height: isMobile ? 16.0 : 24.0),
                  _buildListaReativa(isMobile),
                ] else
                  _buildLoginPrompt(isMobile),
                SizedBox(height: isMobile ? 50.0 : 100.0),
                FooterSection(config: homeContoller.config),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.trim()),
        decoration: InputDecoration(
          hintText: "Pesquisar por serviço...",
          hintStyle: const TextStyle(color: Color(0xFF7A6A62)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF7A6A62)),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF7A6A62)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.pinkStrong, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Icon(Icons.lock_outline, size: isMobile ? 40.0 : 56.0, color: const Color(0xFF7A6A62)),
            const SizedBox(height: 16),
            const Text(
              "Precisas de iniciar sessão",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Para consultares e gerires os teus agendamentos, entra na tua conta.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF7A6A62)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkStrong,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage())),
              child: const Text("Entrar / Criar Conta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaReativa(bool isMobile) {
    if (_agendamentosStream == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return StreamBuilder<List<Agendamento>>(
      stream: _agendamentosStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _carregandoServicos) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: const Text(
                "Não foi possível carregar os agendamentos. Tente novamente mais tarde.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF7A6A62)),
              ),
            ),
          );
        }

        final todos = snapshot.data ?? [];
        final ativos = todos.where((a) => a.status != 'concluido').toList();

        if (ativos.isEmpty) return const AgendamentoEmptyState();

        final filtrados = _searchQuery.isEmpty
            ? ativos
            : ativos
                .where((a) => a.servicoNome.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

        if (filtrados.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Text(
                "Nenhum agendamento encontrado para \"$_searchQuery\".",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF7A6A62)),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Histórico de Agendamentos",
                style: TextStyle(
                  fontSize: isMobile ? 18.0 : 20.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5A4A42),
                ),
              ),
              SizedBox(height: isMobile ? 12.0 : 20.0),
              ...filtrados.map((a) => AgendamentoCard(
                    agendamento: a,
                    isMobile: isMobile,
                    onCancelar: () => _cancelar(a),
                    imagemUrl: _servicosMap[a.servicoId]?.imagemUrl,
                  )),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isMobile, double headerTitleSize) {
    return AppBar(
      // Esta página deixou de estar no menu principal — passa a abrir-se
      // sempre por navegação (a partir do Perfil), por isso mostra a seta
      // de voltar normal em vez de esconder o leading.
      automaticallyImplyLeading: true,
      iconTheme: IconThemeData(color: AppColors.brown),
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Agendamentos",
                style: TextStyle(
                  color: AppColors.brown,
                  fontWeight: FontWeight.w600,
                  fontSize: headerTitleSize,
                  letterSpacing: 1,
                ),
              ),
              if (!isCompact)
                Row(
                  children: [
                    ...List.generate(menuItems.length, (index) {
                      final isHover = hoverIndex == index;
                      return MouseRegion(
                        onEnter: (_) => setState(() => hoverIndex = index),
                        onExit: (_) => setState(() => hoverIndex = null),
                        child: GestureDetector(
                          onTap: () => _navegar(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 12.0),
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              menuItems[index],
                              style: TextStyle(
                                color: isHover ? AppColors.pinkNude : AppColors.brown,
                                fontSize: isMobile ? 14.0 : 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(width: isMobile ? 10.0 : 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pinkStrong,
                        padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 14.0 : 20.0, vertical: isMobile ? 8.0 : 12.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage())),
                      child: Text("Agendar", style: TextStyle(color: Colors.white, fontSize: isMobile ? 13.0 : 14.0)),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  void _navegar(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage()), (route) => false);
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProdutosPage()));
    }
  }

  Widget _buildMobileDrawer() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("LOAH STÚDIO",
                  style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 2)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: AppColors.brown),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          ...List.generate(menuItems.length, (index) {
            return ListTile(
              leading: Icon(
                index == 0
                    ? Icons.home_outlined
                    : index == 1
                        ? Icons.spa_outlined
                        : Icons.shopping_bag_outlined,
                color: AppColors.brown,
              ),
              title: Text(menuItems[index], style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _navegar(index);
              },
            );
          }),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinkStrong,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
              },
              child: const Text("Agendar", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _introSection(bool isMobile, bool logado) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.0 : 60.0),
      child: Column(
        children: [
          Text(
            "Os meus Agendamentos",
            style: TextStyle(
              fontSize: isMobile ? 28.0 : 48.0,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5A4A42),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 12.0 : 20.0),
          Text(
            logado
                ? "Consulte o histórico dos seus agendamentos."
                : "Inicia sessão para consultar o histórico dos teus agendamentos.",
            style: TextStyle(fontSize: isMobile ? 14.0 : 18.0, color: const Color(0xFF7A6A62), height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}