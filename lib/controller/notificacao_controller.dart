import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:loahstudio/model/notificacao_model.dart';

class NotificacaoController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _notificacoesRef => _firestore.collection('notificacoes');
  CollectionReference get _clientesRef => _firestore.collection('clientes');

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Lista reativa das notificações do utilizador autenticado, mais
  /// recentes primeiro. Precisa do índice composto
  /// (destinatarioId ASC, criadoEm DESC) — ver nota na Parte 3.
  Stream<List<Notificacao>> streamMinhasNotificacoes({int limite = 100}) {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);
    return _notificacoesRef
        .where('destinatarioId', isEqualTo: uid)
        .orderBy('criadoEm', descending: true)
        .limit(limite)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Notificacao.fromDoc(d)).toList());
  }

  /// Contagem de não lidas, para o badge do ícone. Só usa filtros de
  /// igualdade — não precisa de índice composto extra.
  Stream<int> streamContagemNaoLidas() {
    final uid = currentUserId;
    if (uid == null) return Stream.value(0);
    return _notificacoesRef
        .where('destinatarioId', isEqualTo: uid)
        .where('lida', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<bool> marcarComoLida(String id) async {
    try {
      await _notificacoesRef.doc(id).update({'lida': true});
      return true;
    } catch (e) {
      debugPrint('Erro ao marcar notificação como lida: $e');
      return false;
    }
  }

  Future<bool> marcarTodasComoLidas(List<String> ids) async {
    if (ids.isEmpty) return true;
    try {
      final batch = _firestore.batch();
      for (final id in ids) {
        batch.update(_notificacoesRef.doc(id), {'lida': true});
      }
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Erro ao marcar notificações como lidas: $e');
      return false;
    }
  }

  Future<bool> eliminarNotificacao(String id) async {
    try {
      await _notificacoesRef.doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Erro ao eliminar notificação: $e');
      return false;
    }
  }

  /// Regista o token FCM deste dispositivo — um array, porque o mesmo
  /// utilizador pode ter várias sessões/dispositivos (telemóvel + browser).
  Future<void> registrarTokenFcm(String uid, String token) async {
    try {
      await _clientesRef.doc(uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (e) {
      debugPrint('Erro ao registar token FCM: $e');
    }
  }

  Future<void> removerTokenFcm(String uid, String token) async {
    try {
      await _clientesRef.doc(uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    } catch (e) {
      debugPrint('Erro ao remover token FCM: $e');
    }
  }
}