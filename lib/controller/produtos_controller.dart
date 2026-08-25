import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loahstudio/model/produto_model.dart';

class ProdutosController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _produtosRef => _firestore.collection('produtos');

  Stream<List<Produto>> streamProdutos() {
    return _produtosRef.orderBy('criadoEm', descending: true).snapshots().map(
        (snap) => snap.docs.map((d) => Produto.fromDoc(d)).toList());
  }

  Future<String?> _uploadImagem(XFile imagem, String produtoId) async {
    try {
      final Uint8List bytes = await imagem.readAsBytes();
      final ref = _storage.ref().child('produtos/$produtoId.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<bool> addProduto(Produto produto, {XFile? imagem}) async {
    try {
      final docRef = await _produtosRef.add(produto.toMap());
      if (imagem != null) {
        final url = await _uploadImagem(imagem, docRef.id);
        if (url != null) {
          await docRef.update({'imagemUrl': url});
        }
      }
      return true;
    } catch (e) {
      debugPrint('Erro ao adicionar produto: $e');
      return false;
    }
  }

  Future<bool> updateProduto(
    String id,
    Map<String, dynamic> data, {
    XFile? imagem,
  }) async {
    try {
      if (imagem != null) {
        final url = await _uploadImagem(imagem, id);
        if (url != null) data['imagemUrl'] = url;
      }
      await _produtosRef.doc(id).update(data);
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar produto: $e');
      return false;
    }
  }

  Future<bool> deleteProduto(String id) async {
    try {
      await _produtosRef.doc(id).delete();
      try {
        await _storage.ref().child('produtos/$id.jpg').delete();
      } catch (_) {
        // Ignora se não houver imagem associada.
      }
      return true;
    } catch (e) {
      debugPrint('Erro ao eliminar produto: $e');
      return false;
    }
  }

  Future<bool> toggleDisponibilidade(String id, bool disponivel) async {
    try {
      await _produtosRef.doc(id).update({'disponivel': disponivel});
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar disponibilidade: $e');
      return false;
    }
  }
}