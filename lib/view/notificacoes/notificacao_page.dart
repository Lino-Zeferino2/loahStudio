import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/auth_controller.dart';
import 'package:loahstudio/controller/notificacao_controller.dart';
import 'package:loahstudio/model/notificacao_model.dart';
import 'package:loahstudio/view/admin_views/admin_layout.dart';
import 'package:loahstudio/view/notificacoes/widgets/notificacao_card.dart';
import 'package:loahstudio/view/notificacoes/widgets/notificacao_empty_state.dart';
import 'package:loahstudio/view/user_views/Compra/compra_page.dart';
import 'package:loahstudio/view/user_views/agendamento/agendamento_page.dart';

enum _FiltroLeitura { todas, naoLidas }
enum _FiltroTipo { todos, agendamentos, encomendas }

class NotificacaoPage extends StatefulWidget {
  const NotificacaoPage({super.key});

  @override
  State<NotificacaoPage> createState() => _NotificacaoPageState();
}

class _NotificacaoPageState extends State<NotificacaoPage> {
  final _controller = NotificacaoController();
  final _authController = AuthController();

  _FiltroLeitura _filtroLeitura = _FiltroLeitura.todas;
  _FiltroTipo _filtroTipo = _FiltroTipo.todos;
  bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    _verificarRole();
  }

  Future<void> _verificarRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final role = await _authController.getUserRole(uid);
    if (mounted) setState(() => _isAdmin = role == 'admin');
  }

  List<Notificacao> _aplicarFiltros(List<Notificacao> todas) {
    var lista = todas;
    if (_filtroLeitura == _FiltroLeitura.naoLidas) {
      lista = lista.where((n) => !n.lida).toList();
    }
    switch (_filtroTipo) {
      case _FiltroTipo.agendamentos:
        lista = lista.where((n) => n.isAgendamento).toList();
        break;
      case _FiltroTipo.encomendas:
        lista = lista.where((n) => n.isPedido).toList();
        break;
      case _FiltroTipo.todos:
        break;
    }
    return lista;
  }

  Future<void> _abrirNotificacao(Notificacao n) async {
    if (!n.lida) await _controller.marcarComoLida(n.id);
    if (!mounted) return;

    if (n.isAgendamento) {
      if (_isAdmin == true) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AdminLayout(initialIndex: 1)), (r) => false);
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendamentoPage()));
      }
    } else if (n.isPedido) {
      if (_isAdmin == true) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AdminLayout(initialIndex: 2)), (r) => false);
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ComprasPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.lightCreamBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brown),
        title: const Text('Notificações', style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600)),
        actions: [
          StreamBuilder<List<Notificacao>>(
            stream: _controller.streamMinhasNotificacoes(),
            builder: (context, snapshot) {
              final todas = snapshot.data ?? [];
              final naoLidas = todas.where((n) => !n.lida).toList();
              if (naoLidas.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _controller.marcarTodasComoLidas(naoLidas.map((n) => n.id).toList()),
                child: const Text('Marcar todas como lidas', style: TextStyle(color: AppColors.pinkStrong, fontSize: 13)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todas'),
                      selected: _filtroLeitura == _FiltroLeitura.todas,
                      onSelected: (_) => setState(() => _filtroLeitura = _FiltroLeitura.todas),
                      selectedColor: AppColors.pinkStrong,
                      labelStyle: TextStyle(color: _filtroLeitura == _FiltroLeitura.todas ? Colors.white : AppColors.brown),
                    ),
                    ChoiceChip(
                      label: const Text('Não lidas'),
                      selected: _filtroLeitura == _FiltroLeitura.naoLidas,
                      onSelected: (_) => setState(() => _filtroLeitura = _FiltroLeitura.naoLidas),
                      selectedColor: AppColors.pinkStrong,
                      labelStyle: TextStyle(color: _filtroLeitura == _FiltroLeitura.naoLidas ? Colors.white : AppColors.brown),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Todos'),
                      selected: _filtroTipo == _FiltroTipo.todos,
                      onSelected: (_) => setState(() => _filtroTipo = _FiltroTipo.todos),
                    ),
                    FilterChip(
                      label: const Text('Agendamentos'),
                      selected: _filtroTipo == _FiltroTipo.agendamentos,
                      onSelected: (_) => setState(() => _filtroTipo = _FiltroTipo.agendamentos),
                    ),
                    FilterChip(
                      label: const Text('Encomendas'),
                      selected: _filtroTipo == _FiltroTipo.encomendas,
                      onSelected: (_) => setState(() => _filtroTipo = _FiltroTipo.encomendas),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Notificacao>>(
              stream: _controller.streamMinhasNotificacoes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Não foi possível carregar as notificações.', style: TextStyle(color: AppColors.grey)));
                }

                final filtradas = _aplicarFiltros(snapshot.data ?? []);
                if (filtradas.isEmpty) return const NotificacaoEmptyState();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 32, vertical: 12),
                  itemCount: filtradas.length,
                  itemBuilder: (context, index) {
                    final n = filtradas[index];
                    return Dismissible(
                      key: ValueKey(n.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      onDismissed: (_) => _controller.eliminarNotificacao(n.id),
                      child: NotificacaoCard(
                        notificacao: n,
                        isMobile: isMobile,
                        onTap: () => _abrirNotificacao(n),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}