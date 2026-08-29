/// Representa um item dentro do carrinho de compras: um produto já
/// selecionado (vindo da BD, via ProdutosPage) mais a quantidade escolhida.
///
/// Mantém-se independente do modelo `Produto` para não obrigar a mexer em
/// ProdutosPage: a conversão a partir do Map que já é passado hoje
/// (`existingCart`) é feita em [CarrinhoItem.fromMap]. Se no futuro
/// ProdutosPage passar a expor um modelo `Produto` tipado, basta criar
/// um `CarrinhoItem.fromProduto(produto)` equivalente.
class CarrinhoItem {
  final String? produtoId;
  final String nome;
  final String marca;
  final double preco;
  final String imagemUrl;
  final int quantidade;

  const CarrinhoItem({
    this.produtoId,
    required this.nome,
    required this.marca,
    required this.preco,
    required this.imagemUrl,
    this.quantidade = 1,
  });

  /// Valor real deste item: preço unitário (vindo da BD) x quantidade.
  double get subtotal => preco * quantidade;

  factory CarrinhoItem.fromMap(Map<String, dynamic> map) {
    return CarrinhoItem(
      produtoId: map['id'] as String?,
      nome: map['nome']?.toString() ?? '',
      marca: map['marca']?.toString() ?? '',
      preco: double.tryParse(map['preco'].toString()) ?? 0.0,
      imagemUrl: map['imagem']?.toString() ?? map['imagemUrl']?.toString() ?? '',
      quantidade: map['quantidade'] is int
          ? map['quantidade'] as int
          : int.tryParse(map['quantidade']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': produtoId,
        'nome': nome,
        'marca': marca,
        'preco': preco,
        'imagem': imagemUrl,
        'quantidade': quantidade,
      };

  CarrinhoItem copyWith({int? quantidade}) {
    return CarrinhoItem(
      produtoId: produtoId,
      nome: nome,
      marca: marca,
      preco: preco,
      imagemUrl: imagemUrl,
      quantidade: quantidade ?? this.quantidade,
    );
  }
}