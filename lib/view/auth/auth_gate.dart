// view/auth/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loahstudio/controller/auth_controller.dart';
import 'package:loahstudio/services/fcm_service.dart';
import 'package:loahstudio/view/admin_views/admin_layout.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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

        return FutureBuilder<String?>(
          future: AuthController().getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return roleSnapshot.data == 'admin' ? const AdminLayout() : HomePage();
          },
        );
      },
    );
  }
}