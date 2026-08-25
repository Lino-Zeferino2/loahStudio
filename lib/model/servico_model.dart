import 'package:cloud_firestore/cloud_firestore.dart';

class Servico {
  final String? id;
  final String nome;
  final String descricao;
  final String categoria;
  final int duracaoMinutos;
  final double preco;
  final bool disponivel;
  final int totalVendas;
  final double notaMedia;
  final String? imagemUrl;
  final DateTime? criadoEm;

  Servico({
    this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.duracaoMinutos,
    required this.preco,
    this.disponivel = true,
    this.totalVendas = 0,
    this.notaMedia = 0.0,
    this.imagemUrl,
    this.criadoEm,
  });

  factory Servico.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Servico(
      id: doc.id,
      nome: data['nome'] as String? ?? '',
      descricao: data['descricao'] as String? ?? '',
      categoria: data['categoria'] as String? ?? '',
      duracaoMinutos: data['duracaoMinutos'] as int? ?? 0,
      preco: (data['preco'] as num?)?.toDouble() ?? 0.0,
      disponivel: data['disponivel'] as bool? ?? true,
      totalVendas: data['totalVendas'] as int? ?? 0,
      notaMedia: (data['notaMedia'] as num?)?.toDouble() ?? 0.0,
      imagemUrl: data['imagemUrl'] as String?,
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'duracaoMinutos': duracaoMinutos,
      'preco': preco,
      'disponivel': disponivel,
      'totalVendas': totalVendas,
      'notaMedia': notaMedia,
      'imagemUrl': imagemUrl,
      'criadoEm': criadoEm != null ? Timestamp.fromDate(criadoEm!) : Timestamp.now(),
    };
  }

  Servico copyWith({
    String? nome,
    String? descricao,
    String? categoria,
    int? duracaoMinutos,
    double? preco,
    bool? disponivel,
    String? imagemUrl,
  }) {
    return Servico(
      id: id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      duracaoMinutos: duracaoMinutos ?? this.duracaoMinutos,
      preco: preco ?? this.preco,
      disponivel: disponivel ?? this.disponivel,
      totalVendas: totalVendas,
      notaMedia: notaMedia,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      criadoEm: criadoEm,
    );
  }
}