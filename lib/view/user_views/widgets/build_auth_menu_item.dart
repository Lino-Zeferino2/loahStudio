import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/view/auth/auth_page.dart';
import 'package:loahstudio/view/user_views/perfil/perfil_page.dart';

Widget buildAuthMenuItem({bool isMobile = false}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 34,
      decoration: BoxDecoration(color: AppColors.pinkNude, borderRadius: BorderRadius.circular(20)),
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final isLoggedIn = snapshot.data != null;
          return GestureDetector(
            onTap: () {
              if (isLoggedIn) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilPage()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage()));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoggedIn) ...[
                      Icon(Icons.person, size: 16, color: AppColors.brown),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      isLoggedIn ? "Perfil" : "Entrar",
                      style: TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}