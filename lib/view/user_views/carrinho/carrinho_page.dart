import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';
import 'package:loahstudio/view/user_views/produtos/produtos_page.dart';
import 'package:loahstudio/view/user_views/agendamento/agendamento_page.dart';

class CarrinhoPage extends StatefulWidget {
  final List<Map<String, dynamic>> existingCart;
  CarrinhoPage({this.existingCart = const []});
  @override
  _CarrinhoPageState createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  int selectedIndex = -1;
  int? hoverIndex;

  // Controladores para o formulário
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final moradaController = TextEditingController();
  final cpController = TextEditingController();
  final cidadeController = TextEditingController();
  // Controladores condicionais para pagamento
  final mbwayNumeroController = TextEditingController();
  final cartaoNumeroController = TextEditingController();
  final cartaoValidadeController = TextEditingController();
  final cartaoCvvController = TextEditingController();
  final cartaoNomeController = TextEditingController();
  String pagamentoSelecionado = 'mbway';

  final List<String> menuItems = [
    "Início",
    "Serviços",
    "Produtos",
    "Agendamento",
    "Carrinho",
  ];

  // Lista de itens do carrinho com quantidade
  late List<Map<String, dynamic>> cartItems;

  @override
  void initState() {
    super.initState();
    // Copiar os itens existentes do carrinho
    cartItems = List.from(widget.existingCart);
    // Garantir que cada item tem quantidade
    for (var item in cartItems) {
      if (item['quantidade'] == null) {
        item['quantidade'] = 1;
      }
    }
  }

  // Produtos disponíveis (em produção viria de API/base de dados)
  final List<Map<String, String>> produtos = [
    {
      "nome": "Palette Ultimate Glow",
      "marca": "Charlotte Tilbury",
      "descricao": "Paleta de sombras com acabamento brilhante, 12 cores premium.",
      "preco": "89.00",
      "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
    },
    {
      "nome": "Lipstick Matte Revolution",
      "marca": "Dior",
      "descricao": "Batom de longa duração com acabamento mate luxuoso.",
      "preco": "45.00",
      "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
    },
    {
      "nome": "Foundation Pro Glow",
      "marca": "NARS",
      "descricao": "Base de cobertura média com efeito radiante natural.",
      "preco": "65.00",
      "imagem":  "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
    },
    {
      "nome": "Highlighter Liquid Gold",
      "marca": "Fenty Beauty",
      "descricao": "Highlighter líquido com partículas douradas luminosas.",
      "preco": "38.00",
      "imagem":  "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
    },
    {
      "nome": "Máscara Volume Extra",
      "marca": "YSL",
      "descricao": "Máscara de cilios com volume extremo e curl.",
      "preco": "36.00",
      "imagem":  "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
    },
    {
      "nome": "Brush Set Premium",
      "marca": "Morphe",
      "descricao": "Conjunto de 12 pincéis profissional de fibra sintética.",
      "preco": "125.00",
      "imagem":  "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
    },
    {
      "nome": "Spray Fixador Eternal",
      "marca": "Urban Decay",
      "descricao": "Spray fixador de longa duração para maquiagem perfeita.",
      "preco": "42.00",
      "imagem":  "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
    },
  ];

  // Calcular total
  double get totalValue {
    double total = 0;
    for (var item in cartItems) {
      double price = double.tryParse(item['preco'].toString()) ?? 0;
      int qty = item['quantidade'] ?? 1;
      total += price * qty;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final headerTitleSize = ResponsiveHelper.headerTitleSize(context);

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
                      SizedBox(width: 8),
                      Text(
                        "VOLTAR",
                        style: TextStyle(
                          color: AppColors.brown,
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 11 : 14,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "LOAH STÚDIO",
                  style: TextStyle(
                    color: AppColors.brown,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 16 : 20,
                    letterSpacing: 3,
                  ),
                ),
                if (!isCompact)
                  SizedBox(width: 80)
                else
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    child: Stack(
                      children: [
                        Icon(Icons.shopping_cart, color: AppColors.brown, size: 24),
                        if (cartItems.isNotEmpty)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(color: AppColors.pinkStrong, shape: BoxShape.circle),
                              child: Text("${cartItems.length}", style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                  ),
               
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Menu - só desktop
          if (!isMobile)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(menuItems.length, (index) {
                  final isSelected = selectedIndex == index || (index == 4 && selectedIndex == -1);
                  final isHover = hoverIndex == index;
                  return MouseRegion(
                    onEnter: (_) => setState(() => hoverIndex = index),
                    onExit: (_) => setState(() => hoverIndex = null),
                    child: GestureDetector(
                      onTap: () {
                        if (index == 0) {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage()), (route) => route.isFirst);
                        } else if (index == 1) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ServicosPage()));
                        } else if (index == 2) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProdutosPage()));
                        } else if (index == 3) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AgendamentoPage()));
                        } else if (index == 4) {
                          // Ya estamos en el carrito
                        } else {
                          setState(() => selectedIndex = index);
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border(bottom: BorderSide(color: AppColors.pinkNude, width: 2))
                              : null,
                        ),
                        child: index == 4
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.shopping_bag,
                                    color: AppColors.pinkNude,
                                    size: 20,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    menuItems[index],
                                    style: TextStyle(
                                      color: AppColors.pinkNude,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                menuItems[index],
                                style: TextStyle(
                                  color: isSelected || isHover ? AppColors.pinkNude : AppColors.brown,
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0, vertical: isMobile ? 20.0 : 40),
              child: isMobile
                  ? _buildMobileLayout()
                  : _buildDesktopLayout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 24),
          Text(
            "O seu carrinho está vazio",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5A4A42),
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Adicione produtos para continuar",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7A6A62),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinkStrong,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ProdutosPage()),
            ),
            child: Text(
              "Ver produtos",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItemCard(String nome, String marca, String preco, String imagem, int quantidade, int index) {
    double price = double.tryParse(preco) ?? 0;
    double total = price * quantidade;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagem
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imagem,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.creamBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:  Icon(Icons.image, color: AppColors.grey, size: 20),
              ),
              loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                  ? child
                  : Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.creamBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.image, color: AppColors.grey, size: 20),
                    ),
            ),
          ),
          SizedBox(width: 6),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  marca,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.pinkStrong,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  nome,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A4A42),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  "€${price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A6A62),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2),
          // Quantidade
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF7F4F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, size: 12),
                  color: Color(0xFF5A4A42),
                  padding: EdgeInsets.all(3),
                  constraints: BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      if (quantidade > 1) {
                        cartItems[index]['quantidade'] = quantidade - 1;
                      } else {
                        _removeItem(index);
                      }
                    });
                  },
                ),
                Container(
                  width: 24,
                  alignment: Alignment.center,
                  child: Text(
                    "$quantidade",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5A4A42),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 12),
                  color: Color(0xFF5A4A42),
                  padding: EdgeInsets.all(3),
                  constraints: BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      cartItems[index]['quantidade'] = quantidade + 1;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 2),
          // Total + Remover
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "€${total.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A4A42),
                ),
              ),
              SizedBox(height: 2),
              GestureDetector(
                onTap: () => _removeItem(index),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, size: 12, color: Colors.red.shade400),
                    SizedBox(width: 2),
                    Text(
                      "Remover",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resumoItem(String nome, int quantidade, double preco) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "$nome x$quantidade",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7A6A62),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "€${(preco * quantidade).toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5A4A42),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = isMobile ? screenWidth * 0.95 : 500.0;
    final horizontalPad = isMobile ? 16.0 : 30.0;
    final titleSize = isMobile ? 20.0 : 24.0;
    final subtitleSize = isMobile ? 14.0 : 16.0;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          padding: EdgeInsets.all(horizontalPad),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Finalizar compra",
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A4A42),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 16 : 24),

                // Dados de faturação
                Text(
                  "Dados de faturação",
                  style: TextStyle(
                    fontSize: subtitleSize,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A4A42),
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 16),
                _textField(nomeController, "Nome completo", Icons.person_outline, isMobile: isMobile),
                SizedBox(height: isMobile ? 8 : 12),
                _textField(emailController, "Email", Icons.email_outlined, keyboardType: TextInputType.emailAddress, isMobile: isMobile),
                SizedBox(height: isMobile ? 8 : 12),
                _textField(telefoneController, "Telemóvel", Icons.phone_outlined, keyboardType: TextInputType.phone, isMobile: isMobile),
                SizedBox(height: isMobile ? 16 : 24),

                // Morada
                Text(
                  "Morada de entrega",
                  style: TextStyle(
                    fontSize: subtitleSize,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A4A42),
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 16),
                _textField(moradaController, "Morada", Icons.location_on_outlined, isMobile: isMobile),
                SizedBox(height: isMobile ? 8 : 12),
                // Campos CP e Cidade lado a lado no desktop, empilhados no mobile
                if (isMobile) ...[
                  _textField(cpController, "Código Postal", Icons.markunread_outlined, isMobile: isMobile),
                  SizedBox(height: 8),
                  _textField(cidadeController, "Cidade", Icons.location_city_outlined, isMobile: isMobile),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _textField(cpController, "Código Postal", Icons.markunread_outlined, width: 150, isMobile: isMobile),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _textField(cidadeController, "Cidade", Icons.location_city_outlined, isMobile: isMobile),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: isMobile ? 16 : 24),

                // Campos condicionais conforme método - com StatefulBuilder para atualizar em tempo real
                StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Método de pagamento com atualização em tempo real
                        Text(
                          "Método de pagamento",
                          style: TextStyle(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5A4A42),
                          ),
                        ),
                        SizedBox(height: isMobile ? 10 : 16),
                        _metodoPagamento("MB Way", "mbway", "assets/icons/mbway.png", pagamentoSelecionado, () {
                          setState(() {
                            pagamentoSelecionado = 'mbway';
                          });
                          setStateDialog(() {});
                        }, isMobile),
                        SizedBox(height: isMobile ? 8 : 12),
                        _metodoPagamento("Multibanco", "multibanco", "assets/icons/multibanco.png", pagamentoSelecionado, () {
                          setState(() {
                            pagamentoSelecionado = 'multibanco';
                          });
                          setStateDialog(() {});
                        }, isMobile),
                        SizedBox(height: isMobile ? 8 : 12),
                        _metodoPagamento("Cartão de Crédito", "cartao", "assets/icons/cartao.png", pagamentoSelecionado, () {
                          setState(() {
                            pagamentoSelecionado = 'cartao';
                          });
                         setStateDialog(() {});
                        }, isMobile),
                        SizedBox(height: isMobile ? 16 : 24),

                        if (pagamentoSelecionado == 'mbway') ...[
                          Text(
                            "Número MB Way",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5A4A42),
                            ),
                          ),
                          SizedBox(height: 8),
                          _textField(mbwayNumeroController, "9xxxxxxxxx", Icons.phone_android, keyboardType: TextInputType.phone, isMobile: isMobile),
                        ],

                        if (pagamentoSelecionado == 'cartao') ...[
                          Text(
                            "Dados do cartão",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5A4A42),
                            ),
                          ),
                          SizedBox(height: 8),
                          _textField(cartaoNomeController, "Nome no cartão", Icons.person_outline, isMobile: isMobile),
                          SizedBox(height: isMobile ? 8 : 12),
                          _textField(cartaoNumeroController, "Número do cartão", Icons.credit_card, keyboardType: TextInputType.number, isMobile: isMobile),
                          SizedBox(height: isMobile ? 8 : 12),
                          if (isMobile) ...[
                            _textField(cartaoValidadeController, "MM/AA", Icons.calendar_today, width: double.infinity, isMobile: isMobile),
                            SizedBox(height: 8),
                            _textField(cartaoCvvController, "CVV", Icons.lock_outline, width: double.infinity, isMobile: isMobile),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _textField(cartaoValidadeController, "MM/AA", Icons.calendar_today, width: 120, isMobile: isMobile),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _textField(cartaoCvvController, "CVV", Icons.lock_outline, width: 100, isMobile: isMobile),
                                ),
                              ],
                            ),
                          ],
                        ],

                        if (pagamentoSelecionado == 'multibanco') ...[
                          Container(
                            padding: EdgeInsets.all(isMobile ? 12 : 16),
                            decoration: BoxDecoration(
                              color: Color(0xFFF7F4F2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Dados para Transferência",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF5A4A42),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Entidade: 12345",
                                  style: TextStyle(fontSize: isMobile ? 12 : 14, color: Color(0xFF7A6A62)),
                                ),
                                Text(
                                  "Referência: 999 999 999",
                                  style: TextStyle(fontSize: isMobile ? 12 : 14, color: Color(0xFF7A6A62)),
                                ),
                                Text(
                                  "IBAN: PT50 0000 0000 0000 0000 00",
                                  style: TextStyle(fontSize: isMobile ? 12 : 14, color: Color(0xFF7A6A62)),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Após transferência, envie o comprovativo para o nosso email.",
                                  style: TextStyle(
                                    fontSize: isMobile ? 10 : 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                SizedBox(height: isMobile ? 16 : 24),

                // Total e botão
                Divider(),
                SizedBox(height: isMobile ? 12 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total a pagar",
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A4A42),
                      ),
                    ),
                    Text(
                      "€${totalValue.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pinkStrong,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 16 : 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pinkStrong,
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // Validação básica
                      if (nomeController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          telefoneController.text.isEmpty ||
                          moradaController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Por favor, preencha todos os campos necessários."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Validação condicional conforme método de pagamento
                      if (pagamentoSelecionado == 'mbway' && mbwayNumeroController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Por favor, insira o número MB Way."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (pagamentoSelecionado == 'cartao' &&
                          (cartaoNumeroController.text.isEmpty ||
                           cartaoValidadeController.text.isEmpty ||
                           cartaoCvvController.text.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Por favor, preencha os dados do cartão."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(dialogContext);
                      _showConfirmacaoDialog();
                    },
                    child: Text(
                      "Confirmar compra",
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, double? width, bool isMobile = false}) {
    return Container(
      width: width ?? double.infinity,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: isMobile ? 14 : 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
          prefixIcon: Icon(icon, size: isMobile ? 18 : 20),
          contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.pinkStrong),
          ),
        ),
      ),
    );
  }

  Widget _metodoPagamento(String titulo, String valor, String iconPath, String pagamentoSelecionado, [VoidCallback? onTapCallback, bool isMobile = false]) {
    final isSelected = pagamentoSelecionado == valor;
    final fontSize = isMobile ? 14.0 : 16.0;
    final iconSize = isMobile ? 20.0 : 24.0;
    final padding = isMobile ? 12.0 : 16.0;
    return GestureDetector(
      onTap: () {
        onTapCallback?.call();
      },
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.pinkStrong : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.pinkStrong.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: isMobile ? 20 : 24,
              height: isMobile ? 20 : 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.pinkStrong : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: isMobile ? 10 : 12,
                        height: isMobile ? 10 : 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.pinkStrong,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Icon(
              valor == 'mbway' ? Icons.phone_android
                  : valor == 'multibanco' ? Icons.account_balance
                  : Icons.credit_card,
              size: iconSize,
              color: isSelected ? AppColors.pinkStrong : Color(0xFF5A4A42),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Flexible(
              child: Text(
                titulo,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.pinkStrong : Color(0xFF5A4A42),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmacaoDialog() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final iconSize = isMobile ? 60.0 : 80.0;
    final titleSize = isMobile ? 20.0 : 24.0;
    final textSize = isMobile ? 14.0 : 16.0;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: iconSize,
            ),
            SizedBox(height: isMobile ? 16 : 20),
            Text(
              "Encomenda confirmada!",
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A4A42),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "receberá uma confirmação no email:\n${emailController.text}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textSize,
                color: Color(0xFF7A6A62),
              ),
            ),
            if (pagamentoSelecionado == 'mbway') ...[
              SizedBox(height: isMobile ? 12.0 : 20.0),
              Container(
                padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFF7F4F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "Pagamento via MB Way",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: textSize),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Enviará um pedido de pagamento\npara o seu número.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: isMobile ? 12 : 14, color: Color(0xFF7A6A62)),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: isMobile ? 16 : 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkStrong,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 40, vertical: isMobile ? 12 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  cartItems.clear();
                  nomeController.clear();
                  emailController.clear();
                  telefoneController.clear();
                  moradaController.clear();
                  cpController.clear();
                  cidadeController.clear();
                  mbwayNumeroController.clear();
                  cartaoNumeroController.clear();
                  cartaoValidadeController.clear();
                  cartaoCvvController.clear();
                  cartaoNomeController.clear();
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => ProdutosPage()),
                );
              },
              child: Text("Continuar a compras", style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(int index) {
    String itemName = cartItems[index]['nome'] ?? 'este item';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Confirmar remoção", style: TextStyle(color: Color(0xFF5A4A42), fontWeight: FontWeight.bold)),
        content: Text("Tem a certeza que deseja remover \"$itemName\" do carrinho?", style: TextStyle(color: Color(0xFF7A6A62))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Color(0xFF7A6A62))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                cartItems.removeAt(index);
              });
            },
            child: Text("Remover", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Container(
      width: 280,
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 2)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: AppColors.brown),
              ),
            ],
          ),
          SizedBox(height: 30),
          Divider(),
          SizedBox(height: 20),
          ...List.generate(menuItems.length, (index) {
            final isSelected = selectedIndex == index || (index == 4 && selectedIndex == -1);
            return ListTile(
              leading: Stack(
                children: [
                  Icon(index == 0 ? Icons.home_outlined : index == 1 ? Icons.spa_outlined : index == 2 ? Icons.shopping_bag_outlined : index == 3 ? Icons.calendar_today_outlined : Icons.shopping_bag, color: isSelected ? AppColors.pinkStrong : AppColors.brown),
                  if (index == 4 && cartItems.isNotEmpty)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppColors.pinkStrong, shape: BoxShape.circle),
                        child: Text("${cartItems.length}", style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              title: Row(
                children: [
                  Text(menuItems[index], style: TextStyle(color: isSelected ? AppColors.pinkStrong : AppColors.brown, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                  if (index == 4 && cartItems.isNotEmpty) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.pinkStrong, borderRadius: BorderRadius.circular(10)),
                      child: Text("${cartItems.length}", style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                if (index == 0) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage()), (route) => route.isFirst);
                } else if (index == 1) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ServicosPage()));
                } else if (index == 2) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProdutosPage()));
                } else if (index == 3) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AgendamentoPage()));
                } else if (index == 4) {
                  // Ya estamos en el carrito
                }
              },
            );
          }),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "O seu carrinho",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42)),
        ),
        SizedBox(height: 4),
        Text(
          "${cartItems.length} artigo${cartItems.length == 1 ? '' : 's'}",
          style: TextStyle(fontSize: 12, color: Color(0xFF7A6A62)),
        ),
        SizedBox(height: 16),
        if (cartItems.isEmpty)
          _emptyCart()
        else
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) => _cartItemCardMobile(
                cartItems[index]['nome'] ?? '',
                cartItems[index]['marca'] ?? '',
                cartItems[index]['preco'] ?? '0',
                cartItems[index]['imagem'] ?? '',
                cartItems[index]['quantidade'] ?? 1,
                index,
              ),
            ),
          ),
        if (cartItems.isNotEmpty) ...[
          SizedBox(height: 16),
          // Resumo mobile
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                    Text("€${totalValue.toStringAsFixed(2)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
                  ],
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                    onPressed: () => _showCheckoutDialog(),
                    child: Text("Finalizar compra", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 20),
        // Footer mobile
        //_footerMobile(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("O seu carrinho", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
        SizedBox(height: 8),
        Text("${cartItems.length} artigo${cartItems.length == 1 ? '' : 's'}", style: TextStyle(fontSize: 16, color: Color(0xFF7A6A62))),
        SizedBox(height: 30),
        if (cartItems.isEmpty)
          _emptyCart()
        else
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => _cartItemCard(
                cartItems[index]['nome'] ?? '',
                cartItems[index]['marca'] ?? '',
                cartItems[index]['preco'] ?? '0',
                cartItems[index]['imagem'] ?? '',
                cartItems[index]['quantidade'] ?? 1,
                index,
              ),
            ),
          ),
        SizedBox(height: 40),
        _resumoDesktop(),
      ],
    );
  }

  Widget _resumoDesktop() {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Resumo do pedido", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
          SizedBox(height: 24),
          Divider(color: Colors.grey.shade200),
          SizedBox(height: 20),
          ...cartItems.map((item) => _resumoItem(item['nome'] ?? '', item['quantidade'] ?? 1, double.tryParse(item['preco'].toString()) ?? 0)),
          SizedBox(height: 20),
          Divider(color: Colors.grey.shade200),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
              Text("€${totalValue.toStringAsFixed(2)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
            ],
          ),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 4),
              onPressed: cartItems.isEmpty ? null : () => _showCheckoutDialog(),
              child: Text("Finalizar compra", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
          SizedBox(height: 16),
          Center(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.lock, size: 16, color: Color(0xFF7A6A62)), SizedBox(width: 8), Text("Pagamento seguro", style: TextStyle(fontSize: 12, color: Color(0xFF7A6A62)))])),
        ],
      ),
    );
  }

  Widget _cartItemCardMobile(String nome, String marca, String preco, String imagem, int quantidade, int index) {
    double price = double.tryParse(preco) ?? 0;
    double total = price * quantidade;
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: Offset(0, 2))]),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem
            SizedBox(
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  imagem,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 40,
                    height: 40,
                    color: AppColors.creamBg,
                    child: Icon(Icons.image, color: AppColors.grey, size: 18),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(marca, style: TextStyle(fontSize: 8, color: AppColors.pinkStrong, fontWeight: FontWeight.w600, letterSpacing: 1), overflow: TextOverflow.ellipsis, maxLines: 1),
                  Text(nome, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text("€${price.toStringAsFixed(2)}", style: TextStyle(fontSize: 10, color: Color(0xFF7A6A62))),
                ],
              ),
            ),
            // Quantidade
            SizedBox(
              width: 50,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() { if (quantidade > 1) cartItems[index]['quantidade'] = quantidade - 1; else _removeItem(index); }),
                        child: Container(padding: EdgeInsets.all(3), decoration: BoxDecoration(color: Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(4)), child: Icon(Icons.remove, size: 10, color: Color(0xFF5A4A42))),
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("$quantidade", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42)))),
                      GestureDetector(
                        onTap: () => setState(() => cartItems[index]['quantidade'] = quantidade + 1),
                        child: Container(padding: EdgeInsets.all(3), decoration: BoxDecoration(color: Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(4)), child: Icon(Icons.add, size: 10, color: Color(0xFF5A4A42))),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text("€${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                ],
              ),
            ),
            SizedBox(width: 4),
            // Delete
            GestureDetector(onTap: () => _removeItem(index), child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade400)),
          ],
        ),
      ),
    );
  }


} 