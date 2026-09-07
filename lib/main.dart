import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:loahstudio/firebase_options.dart';
import 'package:loahstudio/services/fcm_service.dart';
import 'package:loahstudio/view/auth/auth_gate.dart';
import 'package:loahstudio/view/auth/auth_page.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Global — permite navegar (ex: ao tocar numa notificação push) sem
/// precisar de um BuildContext local.
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      webExperimentalForceLongPolling: true, // Force, não AutoDetect
    );
  }
  FirebaseFirestore.setLoggingEnabled(true);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FcmService.inicializar(navigatorKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Loah Stúdio',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const AuthPage(),
      },
    );
  }
}