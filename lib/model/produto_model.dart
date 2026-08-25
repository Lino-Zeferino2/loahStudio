import 'package:cloud_firestore/cloud_firestore.dart';

class Produto {
  final String? id;
  final String nome;
  final String descricao;
  final String categoria;
  final double preco;
  final int estoque;
  final int estoqueMinimo;
  final bool disponivel;
  final String? imagemUrl;
  final DateTime? criadoEm;

  Produto({
    this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.preco,
    required this.estoque,
    this.estoqueMinimo = 5,
    this.disponivel = true,
    this.imagemUrl,
    this.criadoEm,
  });

  bool get semEstoque => estoque == 0;
  bool get estoqueBaixo => estoque <= estoqueMinimo && estoque > 0;

  factory Produto.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Produto(
      id: doc.id,
      nome: data['nome'] as String? ?? '',
      descricao: data['descricao'] as String? ?? '',
      categoria: data['categoria'] as String? ?? '',
      preco: (data['preco'] as num?)?.toDouble() ?? 0.0,
      estoque: data['estoque'] as int? ?? 0,
      estoqueMinimo: data['estoqueMinimo'] as int? ?? 5,
      disponivel: data['disponivel'] as bool? ?? true,
      imagemUrl: data['imagemUrl'] as String?,
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'preco': preco,
      'estoque': estoque,
      'estoqueMinimo': estoqueMinimo,
      'disponivel': disponivel,
      'imagemUrl': imagemUrl,
      'criadoEm': criadoEm != null ? Timestamp.fromDate(criadoEm!) : Timestamp.now(),
    };
  }
}