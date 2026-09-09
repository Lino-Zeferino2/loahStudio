import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritoModel {
  final String id;
  final String usuarioId;
  final String itemId;
  final String tipo; // 'produto' ou 'servico'
  final String nome;
  final String? imagemUrl;
  final double? preco;
  final DateTime criadoEm;

  FavoritoModel({
    required this.id,
    required this.usuarioId,
    required this.itemId,
    required this.tipo,
    required this.nome,
    this.imagemUrl,
    this.preco,
    required this.criadoEm,
  });

  factory FavoritoModel.fromMap(Map<String, dynamic> map, String docId) =>
      FavoritoModel(
        id: docId,
        usuarioId: map['usuarioId'] ?? '',
        itemId: map['itemId'] ?? '',
        tipo: map['tipo'] ?? '',
        nome: map['nome'] ?? '',
        imagemUrl: map['imagemUrl'],
        preco: (map['preco'] as num?)?.toDouble(),
        criadoEm: (map['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'usuarioId': usuarioId,
        'itemId': itemId,
        'tipo': tipo,
        'nome': nome,
        'imagemUrl': imagemUrl,
        'preco': preco,
        'criadoEm': Timestamp.fromDate(criadoEm),
      };
}
