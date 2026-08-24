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

  // ---------------- LOGIN ----------------
  void loginUser({
    required String email,
    required String password,
    required AuthCallback onComplete,
  }) async {
    _isLoading = true;

    try {
      debugPrint('A iniciar sessão com email: ${email.trim()}');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        _isLoading = false;
        onComplete(false, 'Erro ao iniciar sessão.');
        return;
      }

      _isLoading = false;
      debugPrint('Login bem-sucedido: ${userCredential.user!.uid}');
      onComplete(true, null);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException (login): ${e.code} - ${e.message}');
      _isLoading = false;
      onComplete(false, _translateAuthError(e.code));
    } catch (e) {
      debugPrint('Erro geral no login: $e');
      _isLoading = false;
      onComplete(false, 'Erro: ${e.toString()}');
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('clientes').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao obter role: $e');
      return null;
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logoutUser({
    required AuthCallback onComplete,
  }) async {
    try {
      debugPrint('A terminar sessão do utilizador: ${_auth.currentUser?.uid}');
      await _auth.signOut();
      debugPrint('Logout bem-sucedido');
      onComplete(true, null);
    } catch (e) {
      debugPrint('Erro ao terminar sessão: $e');
      onComplete(false, 'Erro ao terminar sessão: ${e.toString()}');
    }
  }

  String _normalizePhonePT(String raw) {
    final digitsOnly = raw.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final localNumber = digitsOnly.startsWith('351')
        ? digitsOnly.substring(3)
        : digitsOnly;
    return '+351$localNumber';
  }

  // ---------------- REGISTO ----------------
  void registerUser({
    required String nome,
    required String email,
    required String password,
    required String telefone,
    required AuthCallback onComplete,
  }) async {
    _isLoading = true;

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

      try {
        await user.getIdToken(true);
        debugPrint('Token forcado');
      } catch (e) {
        debugPrint('Token refresh error (continuando): $e');
      }

      bool firestoreOk = true;
      String? firestoreError;

      try {
        debugPrint('A guardar no Firestore...');
        await _firestore.collection('clientes').doc(uid).set({
          'nome': nome.trim(),
          'email': email.trim(),
          'telefone': _normalizePhonePT(telefone),
          'role': 'user',
          'status': 'ativo',
          'dataCadastro': Timestamp.now(),
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Firestore timeout');
          },
        );
        debugPrint('Documento guardado no Firestore com sucesso');
      } catch (e) {
        debugPrint('Firestore erro: $e');
        firestoreOk = false;
        firestoreError = e.toString();
      }

      _isLoading = false;

      if (!firestoreOk) {
        onComplete(
          false,
          'Conta criada, mas houve um erro a guardar os teus dados. '
          'Verifica a tua ligação e tenta novamente, ou contacta o suporte.',
        );
        debugPrint('Detalhe do erro Firestore: $firestoreError');
        return;
      }

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
      // Versões recentes do Firebase Auth (proteção contra enumeração de
      // emails) devolvem este código genérico em vez de user-not-found /
      // wrong-password para credenciais erradas no login.
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Email ou palavra-passe incorretos.';
      case 'too-many-requests':
        return 'Demasiadas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro: $code';
    }
  }
}