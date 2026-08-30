// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/pedido_controller.dart';
import 'package:loahstudio/model/pedido_model.dart';
import 'package:loahstudio/view/auth/auth_page.dart';
import 'package:loahstudio/view/user_views/Compra/widgets/pedido_card.dart';

class ComprasPage extends StatefulWidget {
  const ComprasPage({super.key});

  @override
  _ComprasPageState createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  final _controller = PedidoController();
  late final Stream<User?> _authStream;
  Stream<List<Pedido>>? _pedidosStream;
  String? _uidAtual;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
  }

  Future<void> _cancelar(Pedido pedido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cancelar pedido?"),
        content: const Text("Esta ação não pode ser desfeita."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Não")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sim, cancelar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final ok = await _controller.cancelarPedido(pedido);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Pedido cancelado." : "Não foi possível cancelar."),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.brown),
        title: Text("As minhas Compras", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<User?>(
        stream: _authStream,
        builder: (context, authSnap) {
          final user = authSnap.data;
          final logado = user != null;

          if (logado && _uidAtual != user.uid) {
            _uidAtual = user.uid;
            _pedidosStream = _controller.streamMeusPedidos();
          } else if (!logado && _uidAtual != null) {
            _uidAtual = null;
            _pedidosStream = null;
          }

          if (!logado) return _buildLoginPrompt(isMobile);

          return _buildLista(isMobile);
        },
      ),
    );
  }

  Widget _buildLoginPrompt(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: const Color(0xFF7A6A62)),
            const SizedBox(height: 16),
            const Text("Precisas de iniciar sessão", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
            const SizedBox(height: 8),
            const Text("Para veres o histórico das tuas compras, entra na tua conta.",
                textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF7A6A62))),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkStrong,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage())),
              child: const Text("Entrar / Criar Conta", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(bool isMobile) {
    if (_pedidosStream == null) return const Center(child: CircularProgressIndicator());

    return StreamBuilder<List<Pedido>>(
      stream: _pedidosStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Não foi possível carregar as tuas compras."));
        }

        final todos = snapshot.data ?? [];
        if (todos.isEmpty) return _buildEmptyState();

        final emAndamento = todos.where((p) => !p.isFinalizado).toList();
        final historico = todos.where((p) => p.isFinalizado).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (emAndamento.isNotEmpty) ...[
                  const Text("Em andamento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                  const SizedBox(height: 12),
                  ...emAndamento.map((p) => PedidoCard(pedido: p, isMobile: isMobile, onCancelar: () => _cancelar(p))),
                  const SizedBox(height: 24),
                ],
                if (historico.isNotEmpty) ...[
                  const Text("Histórico", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                  const SizedBox(height: 12),
                  // Sem onCancelar: entregues/cancelados são só para ver.
                  ...historico.map((p) => PedidoCard(pedido: p, isMobile: isMobile)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 56, color: AppColors.grey.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text("Ainda não fizeste nenhuma compra.", style: TextStyle(color: Color(0xFF7A6A62))),
        ],
      ),
    );
  }
}