import 'package:flutter/material.dart';

/// Embrulha o filho com uma leve animação de flutuação vertical contínua
/// (sobe e desce um pouco, em loop) — usado para dar vida a botões
/// flutuantes como o do WhatsApp, sem alterar o widget do botão em si.
class FloatingBob extends StatefulWidget {
  final Widget child;
  final double distancia;
  final Duration duracao;

  const FloatingBob({
    super.key,
    required this.child,
    this.distancia = 8,
    this.duracao = const Duration(milliseconds: 1600),
  });

  @override
  State<FloatingBob> createState() => _FloatingBobState();
}

class _FloatingBobState extends State<FloatingBob> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duracao)..repeat(reverse: true);
    _offset = Tween<double>(begin: 0, end: -widget.distancia).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) => Transform.translate(offset: Offset(0, _offset.value), child: child),
      child: widget.child,
    );
  }
}