import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:loahstudio/model/user_model.dart';

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

  // ---------------- DADOS DO UTILIZADOR ----------------
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('clientes').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao obter dados do utilizador: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required String uid,
    required String nome,
    required String telefone,
    String? morada,
  }) async {
    try {
      await _firestore.collection('clientes').doc(uid).update({
        'nome': nome.trim(),
        'telefone': _normalizePhonePT(telefone),
        'morada': (morada == null || morada.trim().isEmpty) ? FieldValue.delete() : morada.trim(),
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      return false;
    }
  }

  // ---------------- RECUPERAÇÃO DE SENHA ----------------
  Future<void> sendPasswordResetEmail({
    required String email,
    required AuthCallback onComplete,
  }) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty || !trimmed.contains('@') || !trimmed.contains('.')) {
      onComplete(false, 'Por favor, insira um email válido.');
      return;
    }

    try {
      debugPrint('A enviar email de recuperação de senha para: $trimmed');
      await _auth.sendPasswordResetEmail(email: trimmed);
      debugPrint('Email de recuperação enviado com sucesso');
      onComplete(true, null);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException (reset password): ${e.code} - ${e.message}');
      onComplete(false, _translateAuthError(e.code));
    } catch (e) {
      debugPrint('Erro geral ao enviar email de recuperação: $e');
      onComplete(false, 'Erro: ${e.toString()}');
    }
  }

  // ---------------- VERIFICAÇÃO DE EMAIL ----------------
  Future<bool> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      await user.sendEmailVerification();
      debugPrint('Email de verificação enviado para: ${user.email}');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException (envio verificação): ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Erro ao enviar email de verificação: $e');
      return false;
    }
  }

  /// Devolve `true` se este utilizador já confirmou o seu email alguma vez.
  /// A confirmação é guardada no Firestore (`emailVerificado: true`) e só
  /// precisa ser feita uma única vez: depois de confirmada, o login
  /// decorre normalmente sem reexigir nova verificação.
  Future<bool> isEmailVerified() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    try {
      final doc = await _firestore.collection('clientes').doc(uid).get();
      return doc.data()?['emailVerificado'] == true;
    } catch (e) {
      debugPrint('Erro ao verificar estado do email: $e');
      return false;
    }
  }

  /// Marca o email como verificado na Firestore. Chamado após o utilizador
  /// clicar no link de confirmação enviado pelo Firebase.
  Future<void> marcarEmailComoVerificado(String uid) async {
    try {
      await _firestore.collection('clientes').doc(uid).update({
        'emailVerificado': true,
      });
    } catch (e) {
      debugPrint('Erro ao marcar email como verificado: $e');
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logoutUser({
    required AuthCallback onComplete,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;

      // Remove o token FCM deste dispositivo antes de terminar a sessão —
      // caso contrário este utilizador continuaria a receber pushes
      // destinados a quem entrar a seguir neste mesmo dispositivo/browser.
      if (uid != null) {
        try {
          final token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            await _firestore.collection('clientes').doc(uid).update({
              'fcmTokens': FieldValue.arrayRemove([token]),
            });
          }
        } catch (e) {
          debugPrint('Erro ao remover token FCM no logout (a continuar): $e');
        }
      }

      debugPrint('A terminar sessão do utilizador: $uid');
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
    required bool aceitouTermos,
    required AuthCallback onComplete,
  }) async {
    _isLoading = true;

    if (!aceitouTermos) {
      _isLoading = false;
      onComplete(false, 'É necessário aceitar os Termos e Condições e a Política de Privacidade.');
      return;
    }

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

      // Envia o email de confirmação — só depois de confirmado é que o
      // utilizador terá acesso à área de cliente/admin (ver AuthGate).
      try {
        await user.sendEmailVerification();
        debugPrint('Email de verificação enviado para: ${user.email}');
      } catch (e) {
        debugPrint('Erro ao enviar email de verificação (a continuar): $e');
      }

      bool firestoreOk = true;
      String? firestoreError;

      try {
        debugPrint('A guardar no Firestore...');
        await _firestore.collection('clientes').doc(uid).set({
          'id': uid,
          'nome': nome.trim(),
          'email': email.trim().toLowerCase(),
          'telefone': _normalizePhonePT(telefone),
          'role': 'user',
          'emailVerificado': false,
          'status': 'ativo',
          'dataCadastro': Timestamp.now(),
          'termosAceites': true,
          'termosAceitesEm': Timestamp.now(),
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Firestore timeout'),
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
        return 'Não existe nenhuma conta associada a este email.';
      case 'wrong-password':
        return 'Palavra-passe incorreta.';
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