import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

typedef AuthCallback = void Function(bool success, String? errorMessage);

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void clearError() {}

  void registerUser({
    required String nome,
    required String email,
    required String password,
    required AuthCallback onComplete,
  }) async {
    _isLoading = true;
    onComplete(false, null);

    try {
      debugPrint('A criar utilizador com email: ${email.trim()}');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        debugPrint('UserCredential.user é null');
        _isLoading = false;
        onComplete(false, 'Erro ao criar utilizador.');
        return;
      }

      final uid = user.uid;
      debugPrint('Utilizador criado com UID: $uid');

      // Force refresh the ID token so Firestore can use it
      try {
        await user.getIdToken(true);
        debugPrint('Token forcado');
      } catch (e) {
        debugPrint('Token refresh error (continuando): $e');
      }

      // Save to Firestore with its own timeout
      try {
        debugPrint('A guardar no Firestore...');
        final writeFuture = _firestore.collection('clientes').doc(uid).set({
          'nome': nome.trim(),
          'email': email.trim(),
          'role': 'admin',
          'status': 'ativo',
          'dataCadastro': Timestamp.now(),
        });

        final result = await writeFuture.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('Firestore timeout - ignorando e continuando');
            throw TimeoutException('Firestore timeout');
          },
        );
        debugPrint('Documento guardado no Firestore com sucesso');
      } catch (e) {
        debugPrint('Firestore erro: $e');
        // Continue even if Firestore fails - user is already created
      }

      _isLoading = false;
      debugPrint('Registo completo');
      onComplete(true, null);

    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      _isLoading = false;
      onComplete(false, _translateAuthError(e.code));
    } catch (e) {
      debugPrint('Erro geral no registo: $e');
      _isLoading = false;
      onComplete(false, 'Erro: ${e.toString()}');
    }
  }

  String _translateAuthError(String code) {
    switch (code) {
      case 'network-request-failed':
        return 'Erro de rede. Verifique a sua ligação à internet.';
      case 'email-already-in-use':
        return 'Este email já está registado. Tente fazer login.';
      case 'invalid-email':
        return 'O email introduzido não é válido.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
        return 'Utilizador não encontrado.';
      case 'wrong-password':
        return 'Palavra-passe incorreta.';
      case 'too-many-requests':
        return 'Demasiadas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro: ${code}';
    }
  }
}