// ignore_for_file: library_private_types_in_public_api
import 'package:loahstudio/model/carrinho_item_model.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/controller/carrinho_controller.dart';
import 'package:loahstudio/view/user_views/carrinho/widgets/carrinho_empty.dart';
import 'package:loahstudio/view/user_views/carrinho/widgets/confirmar_remocao_item.dart';
import 'package:loahstudio/view/user_views/carrinho/widgets/mostrar_confirmacao_pedido.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';
import 'package:loahstudio/view/user_views/produtos/produtos_page.dart';
import 'package:loahstudio/view/user_views/agendamento/agendamento_page.dart';
import 'package:loahstudio/view/user_views/carrinho/widgets/carrinho_item_card.dart';
import 'package:loahstudio/view/user_views/carrinho/widgets/carrinho_resumo_card.dart';
import 'package:loahstudio/view/user_views/carrinho/widgets/checkout_dialog.dart';

class CarrinhoPage extends StatefulWidget {
  final List<Map<String, dynamic>> existingCart;
  const CarrinhoPage({super.key, this.existingCart = const []});
  @override
  _CarrinhoPageState createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  final CarrinhoController _controller = CarrinhoController();

  int selectedIndex = -1;
  int? hoverIndex;
  late List<CarrinhoItem> cartItems;
 

  final List<String> menuItems = ["Início", "Serviços", "Produtos", "Agendamento", "Carrinho"];

  @override
  void initState() {
    super.initState();
    // Converte o que vem de fora (ex.: ProdutosPage) para o modelo tipado
    // do carrinho — a partir daqui toda a tela trabalha só com CarrinhoItem.
    cartItems = widget.existingCart.map((m) => CarrinhoItem.fromMap(m)).toList();
  }

  double get totalValue => _controller.calcularTotal(cartItems.cast<CarrinhoItem>());

  void _incrementar(int index) {
    setState(() => cartItems[index] = cartItems[index].copyWith(quantidade: cartItems[index].quantidade + 1));
  }

  Future<void> _decrementar(int index) async {
    final item = cartItems[index];
    if (item.quantidade > 1) {
      setState(() => cartItems[index] = item.copyWith(quantidade: item.quantidade - 1));
      return;
    }
    // Reduzir a quantidade a 0 equivale a remover o item — pede sempre confirmação.
    final confirmado = await confirmarRemocaoItem(context, item.nome);
    if (confirmado) setState(() => cartItems.removeAt(index));
  }

  void _removerItem(int index) {
    setState(() => cartItems.removeAt(index));
  }

  void _abrirCheckout() {
    CheckoutDialog.show(
      context,
      total: totalValue,
      onConfirmar: ({required String metodoPagamento, required String email}) {
        mostrarConfirmacaoPedido(
          context,
          email: email,
          metodoPagamento: metodoPagamento,
          onContinuar: () {
            setState(() => cartItems.clear());
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProdutosPage()));
          },
        );
      },
    );
  }

  void _navegarMenu(int index) {
    if (index == selectedIndex || (index == 4 && selectedIndex == -1)) return;
    if (index == 0) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage()), (route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ServicosPage()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProdutosPage()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendamentoPage()));
    }
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
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, color: AppColors.brown, size: isMobile ? 16 : 20),
                      const SizedBox(width: 8),
                      Text("VOLTAR", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: isMobile ? 11 : 14, letterSpacing: 2)),
                    ],
                  ),
                ),
                Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: isMobile ? 16 : 20, letterSpacing: 3)),
                if (!isCompact)
                  const SizedBox(width: 80)
                else
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openEndDrawer(),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.shopping_cart, color: AppColors.brown, size: 24),
                          if (cartItems.isNotEmpty)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: AppColors.pinkStrong, shape: BoxShape.circle),
                                child: Text("${cartItems.length}", style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          if (!isMobile) _buildDesktopMenu(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0, vertical: isMobile ? 20.0 : 40),
              child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(menuItems.length, (index) {
          final isSelected = selectedIndex == index || (index == 4 && selectedIndex == -1);
          final isHover = hoverIndex == index;
          final isCarrinho = index == 4;
          return MouseRegion(
            onEnter: (_) => setState(() => hoverIndex = index),
            onExit: (_) => setState(() => hoverIndex = null),
            child: GestureDetector(
              onTap: () => _navegarMenu(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(border: isSelected ? Border(bottom: BorderSide(color: AppColors.pinkNude, width: 2)) : null),
                child: isCarrinho
                    ? Row(children: [
                        Icon(Icons.shopping_bag, color: AppColors.pinkNude, size: 20),
                        const SizedBox(width: 6),
                        Text(menuItems[index], style: TextStyle(color: AppColors.pinkNude, fontSize: 16, fontWeight: FontWeight.bold)),
                      ])
                    : Text(menuItems[index], style: TextStyle(color: isSelected || isHover ? AppColors.pinkNude : AppColors.brown, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMobileDrawer() {
    // Drawer(...) em vez de um Container "solto": é o que dá o Material
    // ancestor que o ListTile precisa para os efeitos de toque/ink;
    // sem isto é o que causava o aviso "ink splashes may be invisible".
    return Drawer(
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 2)),
                  GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.close, color: AppColors.brown)),
                ],
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              ...List.generate(menuItems.length, (index) {
                final isSelected = selectedIndex == index || (index == 4 && selectedIndex == -1);
                return ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        index == 0
                            ? Icons.home_outlined
                            : index == 1
                                ? Icons.spa_outlined
                                : index == 2
                                    ? Icons.shopping_bag_outlined
                                    : index == 3
                                        ? Icons.calendar_today_outlined
                                        : Icons.shopping_bag,
                        color: isSelected ? AppColors.pinkStrong : AppColors.brown,
                      ),
                      if (index == 4 && cartItems.isNotEmpty)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: AppColors.pinkStrong, shape: BoxShape.circle),
                            child: Text("${cartItems.length}", style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                  title: Text(menuItems[index], style: TextStyle(color: isSelected ? AppColors.pinkStrong : AppColors.brown, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _navegarMenu(index);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    // Tudo dentro de um único SingleChildScrollView: nada de altura fixa
    // em percentagem do ecrã (era isso que estourava quando o carrinho
    // estava vazio ou tinha poucos itens).
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("O seu carrinho", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
          const SizedBox(height: 4),
          Text("${cartItems.length} artigo${cartItems.length == 1 ? '' : 's'}", style: const TextStyle(fontSize: 12, color: Color(0xFF7A6A62))),
          const SizedBox(height: 16),
          if (cartItems.isEmpty)
            CarrinhoEmptyState(onVerProdutos: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProdutosPage())))
          else ...[
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartItems.length,
                itemBuilder: (context, index) => CarrinhoItemCard(
                item: cartItems[index],
                isMobile: true,
                onIncrementar: () => _incrementar(index),
                onDecrementar: () => _decrementar(index),
                onRemovido: () => _removerItem(index),
              ),
            ),
            const SizedBox(height: 16),
            CarrinhoResumoCard(itens: cartItems, total: totalValue, isMobile: true, onFinalizarCompra: _abrirCheckout),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("O seu carrinho", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
        const SizedBox(height: 8),
        Text("${cartItems.length} artigo${cartItems.length == 1 ? '' : 's'}", style: const TextStyle(fontSize: 16, color: Color(0xFF7A6A62))),
        const SizedBox(height: 30),
        if (cartItems.isEmpty)
          CarrinhoEmptyState(onVerProdutos: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProdutosPage())))
        else
          // Lista + resumo lado a lado, como nos grandes sites de compras
          // (ex.: Amazon/Shopify) — o resumo fica fixo à direita.
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        cartItems.length,
                        (index) => CarrinhoItemCard(
                          item: cartItems[index],
                          isMobile: false,
                          onIncrementar: () => _incrementar(index),
                          onDecrementar: () => _decrementar(index),
                          onRemovido: () => _removerItem(index),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                SizedBox(
                  width: 380,
                  child: CarrinhoResumoCard(itens: cartItems, total: totalValue, isMobile: false, onFinalizarCompra: _abrirCheckout),
                ),
              ],
            ),
          ),
      ],
    );
  }
}