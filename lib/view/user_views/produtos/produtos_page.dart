// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/controller/home_controller.dart';
import 'package:loahstudio/controller/produtos_controller.dart';
import 'package:loahstudio/model/produto_model.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';
import 'package:loahstudio/view/user_views/agendamento/agendamento_page.dart';
import 'package:loahstudio/view/user_views/produtos/widgets/produtos_destaque_carousel.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';
import 'package:loahstudio/view/user_views/carrinho/carrinho_page.dart';
import 'package:loahstudio/view/user_views/produtos/widgets/produto_card_destaque.dart';
import 'package:loahstudio/view/user_views/produtos/widgets/produto_card_grid.dart';
import 'package:loahstudio/view/user_views/widgets/build_auth_menu_item.dart';
import 'package:loahstudio/view/user_views/widgets/footer_section.dart';
import 'package:loahstudio/view/user_views/produtos/produto_detalhe_page.dart';
class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  _ProdutosPageState createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final ProdutosController _controller = ProdutosController();
  // ignore: non_constant_identifier_names
  final HomeController _HomeController = HomeController();
  int selectedIndex = 2;
  int? hoverIndex;
  final List<String> menuItems = ["Início", "Serviços", "Produtos", "Agendamento", "Carrinho"];

  // Carrinho: cada item guarda id, nome e preço já formatado (compatível
  // com o formato que o CarrinhoPage já espera receber).
  final List<Map<String, dynamic>> _cart = [];

  bool _isInCart(String? produtoId) => produtoId != null && _cart.any((item) => item['id'] == produtoId);

  void _toggleCart(Produto produto) {
    if (produto.id == null) return;
    setState(() {
      if (_isInCart(produto.id)) {
        _cart.removeWhere((item) => item['id'] == produto.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${produto.nome} removido do carrinho!"), backgroundColor: Colors.grey, duration: const Duration(seconds: 1)),
        );
      } else {
        _cart.add({
          'id': produto.id,
          'nome': produto.nome,
          'marca': produto.marca,
          'preco': produto.preco,          // valor numérico puro, sem formatação
          'imagem': produto.imagemUrl ?? '',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${produto.nome} adicionado ao carrinho!"), backgroundColor: AppColors.pinkStrong, duration: const Duration(seconds: 1)),
        );
      }
    });
  }
  void _abrirDetalhes(Produto produto) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProdutoDetalhePage(
        produto: produto,
        isInCart: _isInCart(produto.id),
        onToggleCart: () => _toggleCart(produto),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      endDrawer: isMobile ? _buildMobileDrawer() : null,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: isMobile ? 16 : 22, letterSpacing: 3)),
            ),
            if (isMobile)
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarrinhoPage(existingCart: _cart))),
                child: Badge(label: Text("${_cart.length}"), isLabelVisible: _cart.isNotEmpty, child: Icon(Icons.shopping_cart, color: AppColors.brown, size: 24)),
              )
            else
              Row(children: [
                ...List.generate(menuItems.length, (index) {
                  final isSelected = selectedIndex == index;
                  final isHover = hoverIndex == index;
                  return MouseRegion(
                    onEnter: (_) => setState(() => hoverIndex = index),
                    onExit: (_) => setState(() => hoverIndex = null),
                    child: GestureDetector(
                      onTap: () => _handleMenuTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(border: isSelected ? Border(bottom: BorderSide(color: AppColors.pinkNude, width: 2)) : null),
                        child: index == 4
                            ? Badge(label: Text("${_cart.length}"), isLabelVisible: _cart.isNotEmpty, child: Icon(Icons.shopping_bag_outlined, color: isSelected || isHover ? AppColors.pinkNude : AppColors.brown, size: 22))
                            : Text(menuItems[index], style: TextStyle(color: isSelected || isHover ? AppColors.pinkNude : AppColors.brown, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 20),
                buildAuthMenuItem(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicosPage())),
                  child: const Text("Agendar", style: TextStyle(color: Colors.white)),
                ),
              ]),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Produto>>(
          stream: _controller.streamProdutosDisponiveis(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar produtos: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final produtos = snapshot.data!;
            final produtosDestaque = produtos.where((p) => p.destaque).toList();

            return SingleChildScrollView(
              child: Column(children: [
                SizedBox(height: isMobile ? 20 : 40),
                _introSection(),
                const SizedBox(height: 60),
                if (produtosDestaque.isNotEmpty) _produtosDestaqueSection(produtosDestaque),
                if (produtosDestaque.isNotEmpty) const SizedBox(height: 60),
                _todosProdutosSection(produtos),
                const SizedBox(height: 100),
                FooterSection(config: _HomeController.config),
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget _introSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final hPad = isMobile ? 16.0 : 60.0;
    final titSize = isMobile ? 24.0 : 48.0;
    final descSize = isMobile ? 13.0 : 18.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
      child: Column(children: [
        Text("Produtos Premium", style: TextStyle(fontSize: titSize, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42), height: 1.2)),
        SizedBox(height: isMobile ? 10 : 20),
        Text("Seleção exclusiva das melhores marcas de maquilhagem.\nQualidade profissional para o seu dia-a-dia.", style: TextStyle(fontSize: descSize, color: const Color(0xFF7A6A62), height: 1.5), textAlign: TextAlign.center),
      ]),
    );
  }

Widget _produtosDestaqueSection(List<Produto> produtosDestaque) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  final hPad = isMobile ? 12.0 : 60.0;
  final titSize = isMobile ? 16.0 : 24.0;

  return Container(
    padding: EdgeInsets.symmetric(horizontal: hPad),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.pinkStrong, borderRadius: BorderRadius.circular(12)),
            child: const Text("NOVO", style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(width: 8),
          Text("Em Destaque", style: TextStyle(fontSize: titSize, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
        ]),
        SizedBox(height: isMobile ? 12 : 24),
        if (isMobile)
          ProdutosDestaqueCarousel(
            produtos: produtosDestaque,
            isInCart: _isInCart,
            onToggleCart: _toggleCart,
            onOpenDetalhes: _abrirDetalhes,
          )
        else
          SizedBox(
            height: 380,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: produtosDestaque.length,
              itemBuilder: (context, index) {
                final produto = produtosDestaque[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: SizedBox(
                    width: 300,
                    child: ProdutoCardDestaque(
                      produto: produto,
                      isInCart: _isInCart(produto.id),
                      isMobile: false,
                      onToggleCart: () => _toggleCart(produto),
                      onOpenDetalhes: () => _abrirDetalhes(produto),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    ),
  );
}
  Widget _todosProdutosSection(List<Produto> produtos) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final hPad = isMobile ? 12.0 : 60.0;
    final titSize = isMobile ? 18.0 : 24.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Todos os Produtos", style: TextStyle(fontSize: titSize, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
          SizedBox(height: isMobile ? 12 : 24),
          if (produtos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Column(children: [
                  Icon(Icons.shopping_bag_outlined, size: 60, color: AppColors.grey.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('Ainda não há produtos disponíveis. Volta em breve!', style: TextStyle(color: AppColors.grey)),
                ]),
              ),
            )
          else if (isMobile)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return ProdutoCardGrid(
  produto: produto,
  isInCart: _isInCart(produto.id),
  isCompact: true, // ou false no desktop
  onToggleCart: () => _toggleCart(produto),
  onOpenDetalhes: () => _abrirDetalhes(produto),
  width: MediaQuery.of(context).size.width / 2 - 20, // só no mobile
);
              },
            )
          else
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: produtos.map((produto) => ProdutoCardGrid(
                produto: produto,
                isInCart: _isInCart(produto.id),
                isCompact: false,
                onToggleCart: () => _toggleCart(produto),  onOpenDetalhes: () => _abrirDetalhes(produto),
              )).toList(),
            ),
        ],
      ),
    );
  }

  void _handleMenuTap(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage()), (route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ServicosPage()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendamentoPage()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => CarrinhoPage(existingCart: _cart)));
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
              Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 2)),
              Row(children: [
                if (_cart.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.pinkStrong, borderRadius: BorderRadius.circular(12)),
                    child: Text("${_cart.length} itens", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(width: 8),
                GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.close, color: AppColors.brown)),
              ]),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          ...List.generate(menuItems.length, (index) {
            final isSelected = selectedIndex == index;
            return ListTile(
              leading: index == 4
                  ? Badge(label: Text("${_cart.length}"), isLabelVisible: _cart.isNotEmpty, child: Icon(Icons.shopping_cart, color: isSelected ? AppColors.pinkStrong : AppColors.brown))
                  : Icon(index == 0 ? Icons.home_outlined : index == 1 ? Icons.spa_outlined : index == 2 ? Icons.shopping_bag_outlined : Icons.calendar_today_outlined, color: isSelected ? AppColors.pinkStrong : AppColors.brown),
              title: Text(menuItems[index], style: TextStyle(color: isSelected ? AppColors.pinkStrong : AppColors.brown, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _handleMenuTap(index);
              },
            );
          }),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicosPage()));
              },
              child: const Text("Agendar", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

}