import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loahstudio/controller/auth_controller.dart';
import 'package:loahstudio/services/fcm_service.dart';
import 'package:loahstudio/view/admin_views/admin_layout.dart';
import 'package:loahstudio/view/auth/email_verification_pending_page.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<_AuthGateData> _resolver(User user) async {
    // O emailVerified do stream authStateChanges() não se atualiza sozinho —
    // é preciso recarregar o utilizador para obter o estado mais recente.
    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;
    final verificado = refreshedUser?.emailVerified ?? false;

    if (!verificado) {
      return const _AuthGateData(emailVerificado: false, role: null);
    }

    final role = await AuthController().getUserRole(user.uid);
    return _AuthGateData(emailVerificado: true, role: role);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authSnapshot.data;
        if (user == null) return HomePage();

        // Fire-and-forget: garante que este dispositivo fica registado
        // para receber push notifications deste utilizador.
        FcmService.registarAposLogin();

        return FutureBuilder<_AuthGateData>(
          future: _resolver(user),
          builder: (context, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final data = dataSnapshot.data;
            if (data == null || !data.emailVerificado) {
              return const EmailVerificationPendingPage();
            }

            return data.role == 'admin' ? const AdminLayout() : HomePage();
          },
        );
      },
    );
  }
}

class _AuthGateData {
  final bool emailVerificado;
  final String? role;
  const _AuthGateData({required this.emailVerificado, required this.role});
}