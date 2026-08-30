import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:loahstudio/model/carrinho_item_model.dart';
import 'package:loahstudio/model/pagamento_config_model.dart';
import 'package:loahstudio/model/pedido_model.dart';

class PedidoController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _pedidosRef => _firestore.collection('pedidos');

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<PagamentoConfig> fetchPagamentoConfig() async {
    try {
      final doc = await _firestore.collection('configuracoes').doc('pagamento').get();
      return PagamentoConfig.fromMap(doc.data());
    } catch (e) {
      debugPrint('Erro ao carregar config de pagamento: $e');
      return const PagamentoConfig();
    }
  }

  Stream<List<Pedido>> streamMeusPedidos() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);
    return _pedidosRef
        .where('clienteId', isEqualTo: uid)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Pedido.fromDoc(d)).toList());
  }

  /// Cria o pedido com status 'pendente' — aguardando o cliente enviar o
  /// comprovativo (ou já ter enviado por WhatsApp) e o admin confirmar
  /// manualmente. Devolve o id do pedido criado, ou null em caso de falha.
  Future<String?> criarPedido({
    required List<CarrinhoItem> itens,
    required String clienteNome,
    required String clienteEmail,
    required String clienteTelefone,
    required String morada,
    required String codigoPostal,
    required String cidade,
    required String metodoPagamento,
  }) async {
    final uid = currentUserId;
    if (uid == null || itens.isEmpty) return null;

    try {
      final itensPedido = itens
          .map((c) => ItemPedido(
                produtoId: c.produtoId,
                nome: c.nome,
                marca: c.marca,
                imagemUrl: c.imagemUrl,
                precoUnitario: c.preco,
                quantidade: c.quantidade,
              ))
          .toList();

      final valorTotal = itensPedido.fold<double>(0, (soma, i) => soma + i.subtotal);

      final pedido = Pedido(
        clienteId: uid,
        clienteNome: clienteNome.trim(),
        clienteEmail: clienteEmail.trim().toLowerCase(),
        clienteTelefone: clienteTelefone.trim(),
        morada: morada.trim(),
        codigoPostal: codigoPostal.trim(),
        cidade: cidade.trim(),
        itens: itensPedido,
        valorTotal: valorTotal,
        metodoPagamento: metodoPagamento,
      );

      final docRef = await _pedidosRef.add(pedido.toMapCriacao());
      return docRef.id;
    } catch (e) {
      debugPrint('Erro ao criar pedido: $e');
      return null;
    }
  }

  Future<bool> cancelarPedido(Pedido pedido) async {
    if (!pedido.podeCancelar || pedido.id == null) return false;
    try {
      await _pedidosRef.doc(pedido.id).update({
        'status': 'cancelado',
        'atualizadoEm': FieldValue.serverTimestamp(),
        'historico': FieldValue.arrayUnion([
          HistoricoStatus(status: 'cancelado', data: DateTime.now()).toMap(),
        ]),
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao cancelar pedido: $e');
      return false;
    }
  }

  /// Envia o comprovativo de pagamento — só funciona enquanto o pedido
  /// ainda está pendente (a Rule do Firestore reforça isto do lado do
  /// servidor também).
  Future<bool> enviarComprovativo(String pedidoId, Uint8List bytes) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      final ref = _storage.ref().child('comprovativos/$uid/$pedidoId.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();

      await _pedidosRef.doc(pedidoId).update({
        'comprovativoUrl': url,
        'comprovativoEnviadoEm': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao enviar comprovativo: $e');
      return false;
    }
  }
}