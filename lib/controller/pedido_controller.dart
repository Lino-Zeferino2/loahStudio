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

  /// Stream para admin - todos os pedidos
  Stream<List<Pedido>> streamTodosPedidos() {
    return _pedidosRef
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Pedido.fromDoc(d)).toList());
  }

  /// Atualiza o status de um pedido e regista no histórico. As mudanças
  /// para 'confirmado' e 'entregue' disparam automaticamente o email
  /// correspondente via Cloud Function 'onPedidoAtualizado' — não é
  /// preciso (nem deve) enviar email a partir daqui.
  Future<bool> atualizarStatusPedido(String pedidoId, String novoStatus) async {
    try {
      await _pedidosRef.doc(pedidoId).update({
        'status': novoStatus,
        'atualizadoEm': FieldValue.serverTimestamp(),
        'historico': FieldValue.arrayUnion([
          HistoricoStatus(status: novoStatus, data: DateTime.now()).toMap(),
        ]),
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar status do pedido: $e');
      return false;
    }
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

  /// Envia o comprovativo de pagamento a partir do CLIENTE — o path no
  /// Storage usa o uid de quem está logado, porque é o próprio dono do
  /// pedido. A Rule do Firestore/Storage reforça isto do lado do servidor.
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

  /// Envia o comprovativo a partir do ADMIN, em nome do cliente. Precisa do
  /// clienteId explícito porque o uid de quem está autenticado aqui é o do
  /// admin, não o do dono do pedido — o path no Storage tem de continuar a
  /// bater com 'comprovativos/{clienteId}/...' para ficar consistente com
  /// o que o próprio cliente teria enviado.
  ///
  /// IMPORTANTE: as Storage Rules atuais provavelmente só permitem que
  /// 'comprovativos/{uid}/...' seja escrito por esse mesmo uid — isto vai
  /// falhar com permission-denied até adicionares uma regra que permita
  /// também escrita por utilizadores com role == 'admin'.
  Future<bool> enviarComprovativoAdmin(String pedidoId, String clienteId, Uint8List bytes) async {
    try {
      final ref = _storage.ref().child('comprovativos/$clienteId/$pedidoId.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();

      await _pedidosRef.doc(pedidoId).update({
        'comprovativoUrl': url,
        'comprovativoEnviadoEm': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao enviar comprovativo (admin): $e');
      return false;
    }
  }
}