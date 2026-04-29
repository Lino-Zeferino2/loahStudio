import 'package:flutter/material.dart';
import 'package:loahstudio/view/admin_views/auth_page.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Loah Stúdio - Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  HomePage(), 
      //HomePage(),  AuthPage(),
    );
  }
}