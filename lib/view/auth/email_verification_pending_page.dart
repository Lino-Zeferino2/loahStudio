import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/auth_controller.dart';
import 'package:loahstudio/view/admin_views/admin_layout.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';

class EmailVerificationPendingPage extends StatefulWidget {
  const EmailVerificationPendingPage({super.key});

  @override
  State<EmailVerificationPendingPage> createState() => _EmailVerificationPendingPageState();
}

class _EmailVerificationPendingPageState extends State<EmailVerificationPendingPage> {
  final AuthController _authController = AuthController();
  bool _isChecking = false;
  bool _isResending = false;
  int _cooldownSegundos = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _iniciarCooldown() {
    setState(() => _cooldownSegundos = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownSegundos--;
        if (_cooldownSegundos <= 0) timer.cancel();
      });
    });
  }

  Future<void> _reenviarEmail() async {
    if (_isResending || _cooldownSegundos > 0) return;
    setState(() => _isResending = true);

    final enviado = await _authController.sendEmailVerification();

    if (!mounted) return;
    setState(() => _isResending = false);

    if (enviado) {
      _iniciarCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email de verificação reenviado. Verifique também a pasta de spam.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível reenviar o email. Tente novamente mais tarde.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _jaVerifiquei() async {
    setState(() => _isChecking = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isChecking = false);
      return;
    }

    // Marca o email como verificado na Firestore e aguarda o reload para o estado atualizado
    await _authController.marcarEmailComoVerificado(user.uid);

    // Recarrega o estado do Firebase para verificar se a confirmação foi detectada
    try {
      await user.reload();
      final verificado = user.emailVerified ?? false;

      if (!mounted) return;
      setState(() => _isChecking = false);

      if (!verificado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ainda não detetámos a confirmação. Aguarde alguns segundos e tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint('Erro ao verificar email: $e');
      setState(() => _isChecking = false);
      return;
    }

    final role = await _authController.getUserRole(user.uid);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => role == 'admin' ? const AdminLayout() : HomePage()),
      (route) => false,
    );
  }

  void _terminarSessao() {
    _authController.logoutUser(
      onComplete: (success, error) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomePage()),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.lightCreamBg,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 20 : 40),
          child: Container(
            constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 450),
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.pinkStrong.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mark_email_unread_outlined, color: AppColors.pinkStrong, size: 36),
                ),
                const SizedBox(height: 20),
                Text(
                  'Confirme o seu email',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.brown, fontSize: isMobile ? 22 : 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enviámos um link de confirmação para:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.brown, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Clique no link do email para ativar a sua conta. Se não encontrar a mensagem, verifique também a pasta de spam ou lixo eletrónico.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: ResponsiveHelper.buttonHeight(context),
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _jaVerifiquei,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pinkStrong,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : const Text('Já confirmei, continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: ResponsiveHelper.buttonHeight(context),
                  child: OutlinedButton(
                    onPressed: (_isResending || _cooldownSegundos > 0) ? null : _reenviarEmail,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.pinkStrong,
                      side: BorderSide(color: AppColors.pinkStrong),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isResending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.pinkStrong)),
                          )
                        : Text(
                            _cooldownSegundos > 0 ? 'Reenviar (${_cooldownSegundos}s)' : 'Reenviar email de verificação',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: _terminarSessao,
                  child: Text('Terminar sessão', style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}