import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loahstudio/firebase_options.dart';
import 'package:loahstudio/view/auth/auth_gate.dart';
import 'package:loahstudio/view/auth/auth_page.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
if (kIsWeb) {
  FirebaseFirestore.instance.settings = const Settings(
    webExperimentalForceLongPolling: true,  // Force, não AutoDetect
  );
}
FirebaseFirestore.setLoggingEnabled(true);
  runApp(
    
     MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Loah Stúdio',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: '/',
    routes: {
  '/': (context) => const AuthGate(), // era HomePage()
  '/login': (context) => const AuthPage(),
},
    );
  }
}
