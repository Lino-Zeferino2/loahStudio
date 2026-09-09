import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:loahstudio/model/favorito_model.dart';

class FavoritosController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _ref => _firestore.collection('favoritos');

  /// ID determinístico por utilizador + tipo + item — evita que dois
  /// utilizadores diferentes a favoritar o mesmo produto/serviço se
  /// sobreponham no mesmo documento.
  String _favoritoId(String usuarioId, String tipo, String itemId) =>
      '${usuarioId}_${tipo}_$itemId';

  /// Lista de favoritos do utilizador atual. Ordenação feita no cliente
  /// para não depender de um índice composto do Firestore.
  Stream<List<FavoritoModel>> streamFavoritos() {
    if (uid == null) return Stream.value([]);
    return _ref.where('usuarioId', isEqualTo: uid).snapshots().map((snap) {
      final lista = snap.docs
          .map((d) => FavoritoModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
      lista.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
      return lista;
    });
  }

  /// Apenas os IDs dos itens favoritados de um tipo ('produto' ou
  /// 'servico') — alimenta o ícone de coração dos cards em tempo real.
  Stream<Set<String>> streamFavoritoIds(String tipo) {
    return streamFavoritos().map(
      (favs) => favs.where((f) => f.tipo == tipo).map((f) => f.itemId).toSet(),
    );
  }

  /// Alterna o estado de favorito de um item.
  ///
  /// [isFavoritoAtual] tem de vir de quem chama (normalmente do
  /// `_favoritoIds` já mantido em sincronia pelo stream) — de propósito
  /// NÃO fazemos aqui um `get()` ao documento para verificar se já
  /// existe: as regras de segurança negam a leitura de um documento que
  /// ainda não existe (nesse caso `resource` é `null` e a condição
  /// `resource.data.usuarioId == ...` falha a avaliar), o que causava o
  /// erro "Ocorreu um erro ao atualizar os favoritos" sempre que se
  /// favoritava algo pela primeira vez.
  ///
  /// Devolve `true` se ficou favoritado, `false` se deixou de estar, e
  /// `null` se o utilizador não tiver sessão iniciada.
  Future<bool?> toggleFavorito({
    required String itemId,
    required String tipo,
    required String nome,
    required bool isFavoritoAtual,
    String? imagemUrl,
    double? preco,
  }) async {
    final usuarioId = uid;
    if (usuarioId == null) return null;

    final docId = _favoritoId(usuarioId, tipo, itemId);
    final docRef = _ref.doc(docId);

    if (isFavoritoAtual) {
      await docRef.delete();
      return false;
    }

    await docRef.set(FavoritoModel(
      id: docId,
      usuarioId: usuarioId,
      itemId: itemId,
      tipo: tipo,
      nome: nome,
      imagemUrl: imagemUrl,
      preco: preco,
      criadoEm: DateTime.now(),
    ).toMap());
    return true;
  }

  Future<bool> remover(String favoritoId) async {
    try {
      await _ref.doc(favoritoId).delete();
      return true;
    } catch (e) {
      debugPrint('Erro remover favorito: $e');
      return false;
    }
  }
}