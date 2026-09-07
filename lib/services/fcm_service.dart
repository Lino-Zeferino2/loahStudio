import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/controller/auth_controller.dart';
import 'package:loahstudio/controller/notificacao_controller.dart';
import 'package:loahstudio/firebase_options.dart';
import 'package:loahstudio/view/admin_views/admin_layout.dart';
import 'package:loahstudio/view/user_views/Compra/compra_page.dart';
import 'package:loahstudio/view/user_views/agendamento/agendamento_page.dart';

/// Handler do FCM para mensagens recebidas com a app em background/terminada
/// (Android/iOS). Tem de ser uma função de topo (não um método de classe),
/// e o `@pragma` evita que seja eliminada no build de release (tree-shaking).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Notificação recebida em background: ${message.data}');
}

/// Ponte entre o FCM e a app: pede permissão, guarda o token do dispositivo
/// no Firestore, e trata o toque numa notificação (app em background ou
/// terminada) navegando para a página certa consoante 'referenciaTipo' e
/// se o utilizador logado é admin.
class FcmService {
  static final NotificacaoController _notificacaoController = NotificacaoController();
  static final AuthController _authController = AuthController();

  static Future<void> inicializar(GlobalKey<NavigatorState> navigatorKey) async {
    final messaging = FirebaseMessaging.instance;

    try {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Erro ao pedir permissão de notificações: $e');
    }

    await _registarTokenAtual();

    messaging.onTokenRefresh.listen((novoToken) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) _notificacaoController.registrarTokenFcm(uid, novoToken);
    });

    // App aberta em primeiro plano: não há UI nativa de notificação aqui —
    // o badge do ícone já atualiza sozinho via stream do Firestore.
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Notificação recebida em primeiro plano: ${message.data}');
    });

    // Toque na notificação com a app em background.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _tratarClique(navigatorKey, message.data);
    });

    // Toque na notificação com a app totalmente fechada (cold start).
    try {
      final mensagemInicial = await messaging.getInitialMessage();
      if (mensagemInicial != null) {
        _tratarClique(navigatorKey, mensagemInicial.data);
      }
    } catch (e) {
      debugPrint('Erro ao obter mensagem inicial do FCM: $e');
    }
  }

static Future<void> _registarTokenAtual() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  try {
    final token = await FirebaseMessaging.instance.getToken(
      vapidKey: kIsWeb ? 'BOywT8ZYuB8tKes_ONyyGoRnOK01MvZeeykCx1175Imy5Itt_cnlZJAc-ItoQx2Y2C-33oYsDMZZCqGEdfKo4bY' : null,
    );
    if (token != null) await _notificacaoController.registrarTokenFcm(uid, token);
  } catch (e) {
    debugPrint('Erro ao obter token FCM: $e');
  }
}

  /// Chamar depois de um login bem-sucedido, para garantir que o token
  /// deste dispositivo fica associado ao utilizador certo.
  static Future<void> registarAposLogin() => _registarTokenAtual();

  static Future<void> _tratarClique(GlobalKey<NavigatorState> navigatorKey, Map<String, dynamic> data) async {
    final referenciaTipo = data['referenciaTipo'] as String?;
    final notificacaoId = data['notificacaoId'] as String?;
    if (notificacaoId != null) await _notificacaoController.marcarComoLida(notificacaoId);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isAdmin = uid != null && await _authController.getUserRole(uid) == 'admin';

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    if (referenciaTipo == NotificacaoReferenciaTipoConst.agendamento) {
      if (isAdmin) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminLayout(initialIndex: 1)),
          (r) => false,
        );
      } else {
        navigator.push(MaterialPageRoute(builder: (_) => const AgendamentoPage()));
      }
    } else if (referenciaTipo == NotificacaoReferenciaTipoConst.pedido) {
      if (isAdmin) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminLayout(initialIndex: 2)),
          (r) => false,
        );
      } else {
        navigator.push(MaterialPageRoute(builder: (_) => const ComprasPage()));
      }
    }
  }
}

/// Espelha os valores de NotificacaoReferenciaTipo — evita importar o
/// model completo aqui só por duas strings.
class NotificacaoReferenciaTipoConst {
  static const agendamento = 'agendamento';
  static const pedido = 'pedido';
}