import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:loahstudio/model/avaliacao_model.dart';

class AvaliacaoController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _avaliacoesRef => _firestore.collection('avaliacoes');

  /// Stream com TODAS as avaliações (aprovadas ou não). O HomeController
  /// (site público) só lê as aprovadas — aqui o admin precisa ver tudo
  /// para poder rever, editar ou ocultar.
  Stream<List<Avaliacao>> streamTodasAvaliacoes() {
    return _avaliacoesRef
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Avaliacao.fromDoc(d)).toList());
  }

  /// Update campo a campo — nunca usa toMap() inteiro, para não sobrescrever
  /// 'criadoEm' com FieldValue.serverTimestamp() ao editar uma avaliação
  /// que já tinha uma data de criação real.
  Future<bool> atualizarAvaliacao(
    String id, {
    String? nomeCliente,
    String? mensagem,
    int? nota,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (nomeCliente != null) updates['nomeCliente'] = nomeCliente.trim();
      if (mensagem != null) updates['mensagem'] = mensagem.trim();
      if (nota != null) updates['nota'] = nota;
      if (updates.isEmpty) return true;
      await _avaliacoesRef.doc(id).update(updates);
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar avaliação: $e');
      return false;
    }
  }

  /// Aprovar/ocultar — controla se a avaliação aparece na página pública.
  Future<bool> alternarAprovacao(String id, bool aprovado) async {
    try {
      await _avaliacoesRef.doc(id).update({'aprovado': aprovado});
      return true;
    } catch (e) {
      debugPrint('Erro ao alternar aprovação da avaliação: $e');
      return false;
    }
  }

  Future<bool> deletarAvaliacao(String id) async {
    try {
      await _avaliacoesRef.doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar avaliação: $e');
      return false;
    }
  }
}