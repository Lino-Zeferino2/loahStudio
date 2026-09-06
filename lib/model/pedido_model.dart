import 'package:cloud_firestore/cloud_firestore.dart';

class ItemPedido {
  final String? produtoId;
  final String nome;
  final String marca;
  final String imagemUrl;
  final double precoUnitario;
  final int quantidade;

  const ItemPedido({
    this.produtoId,
    required this.nome,
    required this.marca,
    required this.imagemUrl,
    required this.precoUnitario,
    required this.quantidade,
  });

  double get subtotal => precoUnitario * quantidade;

  factory ItemPedido.fromMap(Map<String, dynamic> map) {
    return ItemPedido(
      produtoId: map['produtoId'] as String?,
      nome: map['nome'] as String? ?? '',
      marca: map['marca'] as String? ?? '',
      imagemUrl: map['imagemUrl'] as String? ?? '',
      precoUnitario: (map['precoUnitario'] as num?)?.toDouble() ?? 0.0,
      quantidade: map['quantidade'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'produtoId': produtoId,
        'nome': nome,
        'marca': marca,
        'imagemUrl': imagemUrl,
        'precoUnitario': precoUnitario,
        'quantidade': quantidade,
      };
}

class HistoricoStatus {
  final String status;
  final DateTime data;

  const HistoricoStatus({required this.status, required this.data});

  factory HistoricoStatus.fromMap(Map<String, dynamic> map) {
    return HistoricoStatus(
      status: map['status'] as String? ?? '',
      data: (map['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status,
        'data': Timestamp.fromDate(data),
      };
}

/// pendente -> confirmado -> preparando -> enviado -> entregue
/// (ou -> cancelado, a partir de pendente/confirmado/preparando)
///
/// 'pendente' agora também significa "aguardando confirmação de
/// pagamento manual pelo admin" — não há gateway automático.
class Pedido {
  final String? id;
  final String clienteId;
  final String clienteNome;
  final String clienteEmail;
  final String clienteTelefone;
  final String morada;
  final String codigoPostal;
  final String cidade;
  final List<ItemPedido> itens;
  final double valorTotal;
  final String metodoPagamento; // 'transferencia' | 'mbway'
  final String status;
  final String? comprovativoUrl;
  final DateTime? comprovativoEnviadoEm;
  final List<HistoricoStatus> historico;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  const Pedido({
    this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.clienteEmail,
    required this.clienteTelefone,
    required this.morada,
    required this.codigoPostal,
    required this.cidade,
    required this.itens,
    required this.valorTotal,
    required this.metodoPagamento,
    this.status = 'pendente',
    this.comprovativoUrl,
    this.comprovativoEnviadoEm,
    this.historico = const [],
    this.criadoEm,
    this.atualizadoEm,
  });



  static const List<String> statusCancelavel = ['pendente', 'confirmado', 'preparando'];
  static const List<String> statusFinalizado = ['entregue', 'cancelado'];

  bool get podeCancelar => statusCancelavel.contains(status);
  bool get isFinalizado => statusFinalizado.contains(status);
  bool get aguardaComprovativo => status == 'pendente' && (comprovativoUrl == null || comprovativoUrl!.isEmpty);

  factory Pedido.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Pedido(
      id: doc.id,
      clienteId: map['clienteId'] as String? ?? '',
      clienteNome: map['clienteNome'] as String? ?? '',
      clienteEmail: map['clienteEmail'] as String? ?? '',
      clienteTelefone: map['clienteTelefone'] as String? ?? '',
      morada: map['morada'] as String? ?? '',
      codigoPostal: map['codigoPostal'] as String? ?? '',
      cidade: map['cidade'] as String? ?? '',
      itens: (map['itens'] as List<dynamic>? ?? [])
          .map((e) => ItemPedido.fromMap(e as Map<String, dynamic>))
          .toList(),
      valorTotal: (map['valorTotal'] as num?)?.toDouble() ?? 0.0,
      metodoPagamento: map['metodoPagamento'] as String? ?? '',
      status: map['status'] as String? ?? 'pendente',
      comprovativoUrl: map['comprovativoUrl'] as String?,
      comprovativoEnviadoEm: (map['comprovativoEnviadoEm'] as Timestamp?)?.toDate(),
      historico: (map['historico'] as List<dynamic>? ?? [])
          .map((e) => HistoricoStatus.fromMap(e as Map<String, dynamic>))
          .toList(),
      criadoEm: (map['criadoEm'] as Timestamp?)?.toDate(),
      atualizadoEm: (map['atualizadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMapCriacao() => {
        'clienteId': clienteId,
        'clienteNome': clienteNome,
        'clienteEmail': clienteEmail,
        'clienteTelefone': clienteTelefone,
        'morada': morada,
        'codigoPostal': codigoPostal,
        'cidade': cidade,
        'itens': itens.map((i) => i.toMap()).toList(),
        'valorTotal': valorTotal,
        'metodoPagamento': metodoPagamento,
        'status': 'pendente',
        'comprovativoUrl': null,
        'historico': [
          HistoricoStatus(status: 'pendente', data: DateTime.now()).toMap(),
        ],
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      };
}