import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loahstudio/model/servico_model.dart';

class ServicosController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _servicosRef => _firestore.collection('servicos');

  Stream<List<Servico>> streamServicos() {
    return _servicosRef.orderBy('criadoEm', descending: true).snapshots().map(
        (snap) => snap.docs.map((d) => Servico.fromDoc(d)).toList());
  }

  /// Faz upload da imagem a partir de bytes (funciona em web e mobile,
  /// ao contrário de dart:io File, que não existe em Flutter Web).
  Future<String?> _uploadImagem(XFile imagem, String servicoId) async {
    try {
      final Uint8List bytes = await imagem.readAsBytes();
      final ref = _storage.ref().child('servicos/$servicoId.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<bool> addServico(Servico servico, {XFile? imagem}) async {
    try {
      final docRef = await _servicosRef.add(servico.toMap());
      if (imagem != null) {
        final url = await _uploadImagem(imagem, docRef.id);
        if (url != null) {
          await docRef.update({'imagemUrl': url});
        }
      }
      return true;
    } catch (e) {
      debugPrint('Erro ao adicionar serviço: $e');
      return false;
    }
  }

  Future<bool> updateServico(
    String id,
    Map<String, dynamic> data, {
    XFile? imagem,
  }) async {
    try {
      if (imagem != null) {
        final url = await _uploadImagem(imagem, id);
        if (url != null) data['imagemUrl'] = url;
      }
      await _servicosRef.doc(id).update(data);
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar serviço: $e');
      return false;
    }
  }

  Future<bool> deleteServico(String id) async {
    try {
      await _servicosRef.doc(id).delete();
      try {
        await _storage.ref().child('servicos/$id.jpg').delete();
      } catch (_) {
        // Ignora se não houver imagem associada.
      }
      return true;
    } catch (e) {
      debugPrint('Erro ao eliminar serviço: $e');
      return false;
    }
  }

  Future<bool> toggleDisponibilidade(String id, bool disponivel) async {
    try {
      await _servicosRef.doc(id).update({'disponivel': disponivel});
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar disponibilidade: $e');
      return false;
    }
  }
}