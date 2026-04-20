import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';
import 'package:loahstudio/view/user_views/agendamento/agendamento_page.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';
import 'package:loahstudio/view/user_views/carrinho/carrinho_page.dart';

class ProdutosPage extends StatefulWidget {
  @override
  _ProdutosPageState createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  int selectedIndex = 2;
  int? hoverIndex;
  final List<String> menuItems = [
    "Início",
    "Serviços",
    "Produtos",
    "Agendamento",
    "Carrinho",
  ];

  // Carrinho de compras
  final List<Map<String, dynamic>> _cart = [];
  int _selectedProductIndex = -1;

  late final List<Map<String, String>> produtos;
  late final List<Map<String, String>> produtosDestaque;

  @override
  void initState() {
    super.initState();
    produtos = [
      {
        "nome": "Palette Ultimate Glow",
        "marca": "Charlotte Tilbury",
        "descricao": "Paleta de sombras com acabamento brilhante, 12 cores premium.",
        "preco": "€89,00",
        "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
        "destaque": "false",
        "status": "disponivel",
        "quantidade": "15",
      },
      {
        "nome": "Lipstick Matte Revolution",
        "marca": "Dior",
        "descricao": "Batom de longa duração com acabamento mate luxuoso.",
        "preco": "€45,00",
        "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
        "destaque": "false",
        "status": "disponivel",
        "quantidade": "23",
      },
      {
        "nome": "Foundation Pro Glow",
        "marca": "NARS",
        "descricao": "Base de cobertura média com efeito radiante natural.",
        "preco": "€65,00",
        "imagem":"https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
        "destaque": "false",
        "status": "disponivel",
        "quantidade": "8",
      },
      {
        "nome": "Highlighter Liquid Gold",
        "marca": "Fenty Beauty",
        "descricao": "Highlighter líquido com partículas douradas luminosas.",
        "preco": "€38,00",
        "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
        "destaque": "true",
        "status": "disponivel",
        "quantidade": "12",
      },
      {
        "nome": "Máscara Volume Extra",
        "marca": "YSL",
        "descricao": "Máscara de cilios com volume extremo e curl.",
        "preco": "€36,00",
        "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
        "destaque": "false",
        "status": "disponivel",
        "quantidade": "5",
      },
      {
        "nome": "Concealer Perfeito",
        "marca": "Tarte",
        "descricao": "Corretor de alta cobertura com fórmula cremosa.",
        "preco": "€34,00",
        "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
        "destaque": "true",
        "status": "indisponivel",
        "quantidade": "0",
      },
      {
        "nome": "Brush Set Premium",
        "marca": "Morphe",
        "descricao": "Conjunto de 12 pincéis profissional de fibra sintética.",
        "preco": "€125,00",
        "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
        "destaque": "false",
        "status": "disponivel",
        "quantidade": "3",
      },
      {
        "nome": "Spray Fixador Eternal",
        "marca": "Urban Decay",
        "descricao": "Spray fixador de longa duração para maquiagem perfeita.",
        "preco": "€42,00",
        "imagem": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600",
        "destaque": "false",
        "status": "disponivel",
        "quantidade": "18",
      },
    ];

    produtosDestaque = produtos.where((p) => p["destaque"] == "true").toList();
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
              child: Text(
                "LOAH STÚDIO",
                style: TextStyle(
                  color: AppColors.brown,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  letterSpacing: 3,
                ),
              ),
            ),
            Row(
              children: [
                ...List.generate(menuItems.length, (index) {
                  final isSelected = selectedIndex == index;
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
                        } else if (index == 3) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AgendamentoPage()));
                        } else if (index == 4) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarrinhoPage(existingCart: _cart),
                            ),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border(bottom: BorderSide(color: AppColors.pinkNude, width: 2))
                              : null,
                        ),
                        child: index == 4
                            ? Badge(
                                label: Text("${_cart.length}"),
                                isLabelVisible: _cart.isNotEmpty,
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: isSelected || isHover ? AppColors.pinkNude : AppColors.brown,
                                  size: 22,
                                ),
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
                SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinkStrong,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage())),
                  child: Text("Agendar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            SizedBox(height: 40),
            _introSection(),
            SizedBox(height: 60),
            _produtosDestaqueSection(),
            SizedBox(height: 60),
            _todosProdutosSection(),
            SizedBox(height: 100),
            _footerSection(),
          ],
        ),
      ),
    ));
  }

  Widget _introSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          Text(
            "Produtos Premium",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A4A42),
              height: 1.2,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Seleção exclusiva das melhores marcas de maquiagem.\nQualidade profissional para o seu dia-a-dia.",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF7A6A62),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _produtosDestaqueSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pinkStrong,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "NOVO",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Em Destaque",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A4A42),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 450,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: produtosDestaque.length,
              itemBuilder: (context, index) {
                final produto = produtosDestaque[index];
                final actualIndex = produtos.indexOf(produto);
                return _produtoCardDestaque(
                  produto["nome"]!,
                  produto["marca"]!,
                  produto["descricao"]!,
                  produto["preco"]!,
                  produto["imagem"]!,
                  produto["status"]!,
                  produto["quantidade"]!,
                  produtoIndex: actualIndex,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _todosProdutosSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Todos os Produtos",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A4A42),
            ),
          ),
          SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: produtos.asMap().entries.map((entry) {
              final index = entry.key;
              final produto = entry.value;
              return _produtoCard(
                produto["nome"]!,
                produto["marca"]!,
                produto["descricao"]!,
                produto["preco"]!,
                produto["imagem"]!,
                produto["status"]!,
                produto["quantidade"]!,
                produtoIndex: index,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _produtoCardDestaque(String nome, String marca, String descricao, String preco, String imagem, String status, String quantidade, {int? produtoIndex}) {
    final isDisponivel = status == "disponivel";

    return Container(
      width: 300,
      margin: EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.network(
                  imagem,
                  height: 200,
                  width: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _addToCartButton(isDisponivel, nome: nome, preco: preco, produtoIndex: produtoIndex),
                ),
                if (!isDisponivel)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "INDISPONÍVEL",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A4A42),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  descricao,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A6A62),
                    height: 1.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preco,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A4A42),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          isDisponivel ? "$quantidade unidades" : "Esgotado",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDisponivel ? Color(0xFF4CAF50) : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _produtoCard(String nome, String marca, String descricao, String preco, String imagem, String status, String quantidade, {int? produtoIndex}) {
    final isDisponivel = status == "disponivel";

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.network(
                  imagem,
                  height: 180,
                  width: 260,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _addToCartButton(isDisponivel, nome: nome, preco: preco, produtoIndex: produtoIndex),
                ),
                if (!isDisponivel)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "ESGOTADO",
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  marca,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.pinkStrong,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  nome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A4A42),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preco,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A4A42),
                          ),
                        ),
                        Text(
                          isDisponivel ? "$quantidade unid." : "Esgotado",
                          style: TextStyle(
                            fontSize: 11,
                            color: isDisponivel ? Color(0xFF4CAF50) : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addToCartButton(bool isDisponivel, {String? nome, String? preco, int? produtoIndex}) {
    // Verificar se este produto já está no carrinho
    final isInCart = produtoIndex != null && _cart.any((item) => item['index'] == produtoIndex);

    return GestureDetector(
      onTap: isDisponivel
          ? () {
              setState(() {
                if (isInCart) {
                  // Remover do carrinho
                  _cart.removeWhere((item) => item['index'] == produtoIndex);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("$nome removido do carrinho!"),
                      backgroundColor: Colors.grey,
                      duration: Duration(seconds: 1),
                    ),
                  );
                } else {
                  // Adicionar ao carrinho
                  _selectedProductIndex = produtoIndex ?? -1;
                  _cart.add({
                    'index': produtoIndex,
                    'nome': nome,
                    'preco': preco,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("$nome adicionado ao carrinho!"),
                      backgroundColor: AppColors.pinkStrong,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              });
            }
          : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isInCart ? AppColors.pinkStrong : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isInCart ? Icons.check : Icons.shopping_bag_outlined,
          color: isInCart ? Colors.white : (isDisponivel ? AppColors.pinkStrong : Colors.grey),
          size: 20,
        ),
      ),
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Carrinho de Compras", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: _cart.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey[300]),
                    SizedBox(height: 16),
                    Text("Carrinho vazio", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _cart.length,
                  itemBuilder: (context, index) {
                    final item = _cart[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.pinkStrong,
                        child: Text("${index + 1}", style: TextStyle(color: Colors.white)),
                      ),
                      title: Text(item['nome'] ?? ''),
                      subtitle: Text(item['preco'] ?? ''),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _cart.removeAt(index);
                          });
                          Navigator.pop(context);
                          _showCartDialog();
                        },
                      ),
                    );
                  },
                ),
              ),
        
        actions: _cart.isNotEmpty
            ? [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _cart.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Limpar Carrinho", style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Encomenda realizada com sucesso!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Text("Finalizar Encomenda", style: TextStyle(color: Colors.white)),
                ),
              ]
            : null,
      ),);
    
  }

  Widget _footerSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      color: Color(0xFFF5F5F5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LOAH STÚDIO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                SizedBox(height: 12),
                Text("© 2026 Loah Stúdio.\nTodos os direitos reservados.", style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62), height: 1.5)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Redes Sociais", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
                SizedBox(height: 12),
                Row(children: [
                  _socialIcon(Icons.camera_alt_outlined),
                  SizedBox(width: 12),
                  _socialIcon(Icons.facebook_outlined),
                  SizedBox(width: 12),
                  _socialIcon(Icons.alternate_email),
                ]),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Horário", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
                SizedBox(height: 12),
                Text(
                  "Seg - Sex: 9h às 19h\nSábado: 9h às 14h\nDomingo: Encerrado",
                  style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62), height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(color: Color(0xFFE8E4E2), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: Color(0xFF5A4A42), size: 20),
    );
  }
}