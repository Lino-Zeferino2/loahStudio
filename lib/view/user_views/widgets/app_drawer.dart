import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/view/auth/auth_page.dart';
import 'package:loahstudio/view/user_views/perfil/perfil_page.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final List<String> menuItems;
  final ValueChanged<int> onNavigate;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.menuItems,
    required this.onNavigate,
  });

  IconData _iconFor(int index) {
    switch (index) {
      case 0: return Icons.home_outlined;
      case 1: return Icons.face_outlined;
      case 2: return Icons.shopping_bag_outlined;
      case 3: return Icons.event_outlined;
      default: return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 2)),
                  GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.close, color: AppColors.brown)),
                ],
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              ...List.generate(menuItems.length, (index) {
                final isSelected = selectedIndex == index;
                return ListTile(
                  leading: Icon(_iconFor(index), color: isSelected ? AppColors.pinkStrong : AppColors.brown),
                  title: Text(menuItems[index], style: TextStyle(color: isSelected ? AppColors.pinkStrong : AppColors.brown, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(index);
                  },
                );
              }),
              _buildAuthMenuItem(context),
              const Spacer(),
              const Divider(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicosPage()));
                  },
                  child: const Text("Agendar", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthMenuItem(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.data != null;
        return ListTile(
          leading: Icon(isLoggedIn ? Icons.person_outline : Icons.login, color: AppColors.brown),
          title: Text(isLoggedIn ? "Perfil" : "Entrar", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w500)),
          onTap: () {
            Navigator.pop(context);
            if (isLoggedIn) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilPage()));
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage()));
            }
          },
        );
      },
    );
  }
}