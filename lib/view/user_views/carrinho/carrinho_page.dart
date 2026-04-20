import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
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
      "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
    },
    {
      "nome": "Highlighter Liquid Gold",
      "marca": "Fenty Beauty",
      "descricao": "Highlighter líquido com partículas douradas luminosas.",
      "preco": "38.00",
      "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
    },
    {
      "nome": "Máscara Volume Extra",
      "marca": "YSL",
      "descricao": "Máscara de cilios com volume extremo e curl.",
      "preco": "36.00",
      "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
    },
    {
      "nome": "Brush Set Premium",
      "marca": "Morphe",
      "descricao": "Conjunto de 12 pincéis profissional de fibra sintética.",
      "preco": "125.00",
      "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
    },
    {
      "nome": "Spray Fixador Eternal",
      "marca": "Urban Decay",
      "descricao": "Spray fixador de longa duração para maquiagem perfeita.",
      "preco": "42.00",
      "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: AppColors.brown, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "VOLTAR",
                    style: TextStyle(
                      color: AppColors.brown,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
                fontSize: 20,
                letterSpacing: 3,
              ),
            ),
            SizedBox(width: 80),
          ],
        ),
      ),
      body: Column(
        children: [
          // Menu
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
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lista de produtos
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "O seu carrinho",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A4A42),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${cartItems.length} artigo${cartItems.length == 1 ? '' : 's'}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7A6A62),
                          ),
                        ),
                        SizedBox(height: 30),
                        if (cartItems.isEmpty)
                          _emptyCart()
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                return _cartItemCard(
                                  cartItems[index]['nome'] ?? '',
                                  cartItems[index]['marca'] ?? '',
                                  cartItems[index]['preco'] ?? '0',
                                  cartItems[index]['imagem'] ?? '',
                                  cartItems[index]['quantidade'] ?? 1,
                                  index,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 40),
                  // Resumo do pedido
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Resumo do pedido",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A4A42),
                            ),
                          ),
                          SizedBox(height: 24),
                          Divider(color: Colors.grey.shade200),
                          SizedBox(height: 20),
                          ...cartItems.map((item) => _resumoItem(
                            item['nome'] ?? '',
                            item['quantidade'] ?? 1,
                            double.tryParse(item['preco'].toString()) ?? 0,
                          )),
                          SizedBox(height: 20),
                          Divider(color: Colors.grey.shade200),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5A4A42),
                                ),
                              ),
                              Text(
                                "€${totalValue.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pinkStrong,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.pinkStrong,
                                padding: EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 4,
                              ),
                              onPressed: cartItems.isEmpty
                                  ? null
                                  : () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Encomenda realizada com sucesso!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      setState(() {
                                        cartItems.clear();
                                      });
                                    },
                              child: Text(
                                "Finalizar compra",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock, size: 16, color: Color(0xFF7A6A62)),
                                SizedBox(width: 8),
                                Text(
                                  "Pagamento seguro",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF7A6A62),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
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
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imagem,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  marca,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.pinkStrong,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  nome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A4A42),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "€${price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7A6A62),
                  ),
                ),
              ],
            ),
          ),
          // Quantidade
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF7F4F2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, size: 18),
                  color: Color(0xFF5A4A42),
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
                  width: 40,
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
                  icon: Icon(Icons.add, size: 18),
                  color: Color(0xFF5A4A42),
                  onPressed: () {
                    setState(() {
                      cartItems[index]['quantidade'] = quantidade + 1;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 20),
          // Total + Remover
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "€${total.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A4A42),
                ),
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: () => _removeItem(index),
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                    SizedBox(width: 4),
                    Text(
                      "Remover",
                      style: TextStyle(
                        fontSize: 14,
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
                fontSize: 14,
                color: Color(0xFF7A6A62),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "€${(preco * quantidade).toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5A4A42),
            ),
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }
}