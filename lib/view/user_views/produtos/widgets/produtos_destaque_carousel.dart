import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/produto_model.dart';
import 'package:loahstudio/view/user_views/produtos/widgets/produto_card_destaque.dart';

class ProdutosDestaqueCarousel extends StatefulWidget {
  final List<Produto> produtos;
  final bool Function(String? id) isInCart;
  final void Function(Produto) onToggleCart;
  final void Function(Produto) onOpenDetalhes;

  const ProdutosDestaqueCarousel({
    super.key,
    required this.produtos,
    required this.isInCart,
    required this.onToggleCart,
    required this.onOpenDetalhes,
  });

  @override
  State<ProdutosDestaqueCarousel> createState() => _ProdutosDestaqueCarouselState();
}

class _ProdutosDestaqueCarouselState extends State<ProdutosDestaqueCarousel> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  Timer? _resumeTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _iniciarAutoPlay();
  }

  void _iniciarAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.produtos.length <= 1) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final proxima = (_currentPage + 1) % widget.produtos.length;
      _pageController.animateToPage(proxima, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  void _pausarTemporariamente() {
    _autoPlayTimer?.cancel();
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) _iniciarAutoPlay();
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _resumeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.produtos.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 340,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Só pausa quando é um gesto real do utilizador (dragDetails
              // != null); a animação automática também dispara notificações
              // de scroll, e sem esta checagem o timer pausar-se-ia a si próprio.
              if (notification is ScrollStartNotification && notification.dragDetails != null) {
                _pausarTemporariamente();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.produtos.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final produto = widget.produtos[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ProdutoCardDestaque(
                    produto: produto,
                    isInCart: widget.isInCart(produto.id),
                    isMobile: true,
                    onToggleCart: () => widget.onToggleCart(produto),
                    onOpenDetalhes: () => widget.onOpenDetalhes(produto),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.produtos.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.produtos.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.pinkStrong : AppColors.pinkStrong.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}