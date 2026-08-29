import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/produto_model.dart';

class ProdutoDetalhePage extends StatefulWidget {
  final Produto produto;
  final bool isInCart;
  final VoidCallback onToggleCart;

  const ProdutoDetalhePage({
    super.key,
    required this.produto,
    required this.isInCart,
    required this.onToggleCart,
  });

  @override
  State<ProdutoDetalhePage> createState() => _ProdutoDetalhePageState();
}

class _ProdutoDetalhePageState extends State<ProdutoDetalhePage> {
  late bool _isInCart;

  @override
  void initState() {
    super.initState();
    _isInCart = widget.isInCart;
  }

  void _toggle() {
    widget.onToggleCart();
    setState(() => _isInCart = !_isInCart);
  }

  @override
  Widget build(BuildContext context) {
    final produto = widget.produto;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDisponivel = produto.disponivel && !produto.semEstoque;
    final precoTexto = '€${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.brown),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60, vertical: 8),
                child: isMobile
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _imagemBloco(produto, double.infinity, 280),
                        const SizedBox(height: 20),
                        _infoBloco(produto, precoTexto, isDisponivel, isMobile),
                      ])
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 5, child: _imagemBloco(produto, double.infinity, 420)),
                        const SizedBox(width: 40),
                        Expanded(flex: 4, child: _infoBloco(produto, precoTexto, isDisponivel, isMobile)),
                      ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagemBloco(Produto produto, double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: produto.imagemUrl != null && produto.imagemUrl!.isNotEmpty
          ? Image.network(produto.imagemUrl!, width: width, height: height, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(width, height))
          : _placeholder(width, height),
    );
  }

  Widget _placeholder(double width, double height) => Container(
        width: width,
        height: height,
        color: AppColors.pinkNude.withValues(alpha: 0.3),
        child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.pinkStrong)),
      );

  Widget _infoBloco(Produto produto, String precoTexto, bool isDisponivel, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (produto.marca.isNotEmpty)
          Text(produto.marca.toUpperCase(), style: TextStyle(fontSize: 13, color: AppColors.pinkStrong, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Text(produto.nome, style: TextStyle(fontSize: isMobile ? 22 : 30, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
        const SizedBox(height: 12),
        Row(children: [
          Text(precoTexto, style: TextStyle(fontSize: isMobile ? 22 : 28, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
          const SizedBox(width: 12),
          if (produto.semEstoque)
            const _StatusChip(texto: 'Esgotado', cor: Colors.red)
          else if (produto.estoqueBaixo)
            const _StatusChip(texto: 'Restam poucas unidades', cor: Colors.orange)
          else
            const _StatusChip(texto: 'Em stock', cor: Colors.green),
        ]),
        const SizedBox(height: 24),
        Text('Descrição', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
        const SizedBox(height: 8),
        Text(produto.descricao, style: const TextStyle(fontSize: 14, color: Color(0xFF7A6A62), height: 1.6)),
        if (produto.categoria.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(children: [
            const Icon(Icons.category_outlined, size: 16, color: Color(0xFF7A6A62)),
            const SizedBox(width: 6),
            Text(produto.categoria, style: const TextStyle(fontSize: 13, color: Color(0xFF7A6A62))),
          ]),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isDisponivel ? _toggle : null,
            icon: Icon(_isInCart ? Icons.check : Icons.shopping_bag_outlined, color: Colors.white),
            label: Text(
              !isDisponivel ? 'Indisponível' : (_isInCart ? 'Adicionado ao carrinho' : 'Adicionar ao carrinho'),
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: !isDisponivel ? Colors.grey : (_isInCart ? Colors.green : AppColors.pinkStrong),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String texto;
  final Color cor;
  const _StatusChip({required this.texto, required this.cor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: cor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(texto, style: TextStyle(fontSize: 11, color: cor, fontWeight: FontWeight.w600)),
      );
}