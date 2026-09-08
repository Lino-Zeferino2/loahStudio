import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/auth_controller.dart';
import 'package:loahstudio/view/admin_views/admin_layout.dart';
import 'package:loahstudio/view/auth/email_verification_pending_page.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';

/// Página mostrada quando o utilizador abre o link de verificação do email.
/// Após a verificação ser confirmada, redireciona automaticamente para a Home.
class EmailVerifiedSuccessPage extends StatefulWidget {
  const EmailVerifiedSuccessPage({super.key});

  @override
  State<EmailVerifiedSuccessPage> createState() => _EmailVerifiedSuccessPageState();
}

class _EmailVerifiedSuccessPageState extends State<EmailVerifiedSuccessPage> {
  bool _isProcessing = true;
  String _status = 'A verificar a confirmação do email...';

  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _verificarEmail();
  }

  Future<void> _verificarEmail() async {
    try {
      // Tenta fazer reload do utilizador para obter o estado mais recente
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;

        if (refreshedUser?.emailVerified ?? false) {
          // Email confirmado! Marca no Firestore e continua
          await _authController.marcarEmailComoVerificado(user.uid);
          await _navegarParaHome();
          return;
        }
      }

      // Se não estiver verificado, redireciona para a página de verificação pendente
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const EmailVerificationPendingPage()),
      );
    } catch (e) {
      setState(() {
        _status = 'Erro ao verificar. Tenta novamente.';
      });
    }
  }

  Future<void> _navegarParaHome() async {
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _status = 'Email confirmado! A dirigir para a Home...';
    });

    final role = user != null ? await _authController.getUserRole(user.uid) : null;

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => role == 'admin' ? const AdminLayout() : HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

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
                    color: _isProcessing ? AppColors.pinkStrong.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isProcessing ? Icons.email_outlined : Icons.mark_email_read_outlined,
                    color: _isProcessing ? AppColors.pinkStrong : Colors.green,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.brown, fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 28),
                if (!_isProcessing)
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveHelper.buttonHeight(context),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pinkStrong,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Ir para a Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}