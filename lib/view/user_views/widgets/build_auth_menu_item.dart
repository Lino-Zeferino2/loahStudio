import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/view/auth/auth_page.dart';

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
            onTap: () async {
              if (isLoggedIn) {
                await FirebaseAuth.instance.signOut();
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage()));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: Text(isLoggedIn ? "Logout" : "Login", style: TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.w500))),
            ),
          );
        },
      ),
    ),
  );
}