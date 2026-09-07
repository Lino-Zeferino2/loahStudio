import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipos de notificação — mantém sincronizado com o campo 'tipo' que as
/// Cloud Functions escrevem em 'notificacoes'.
class NotificacaoTipo {
  static const agendamentoCriado = 'agendamento_criado';
  static const agendamentoConfirmado = 'agendamento_confirmado';
  static const agendamentoCancelado = 'agendamento_cancelado';
  static const agendamentoReagendado = 'agendamento_reagendado';
  static const agendamentoConcluido = 'agendamento_concluido';
  static const agendamentoLembrete24h = 'agendamento_lembrete_24h';
  static const agendamentoLembrete1h = 'agendamento_lembrete_1h';
  static const pedidoCriado = 'pedido_criado';
  static const pedidoConfirmado = 'pedido_confirmado';
  static const pedidoPreparando = 'pedido_preparando';
  static const pedidoEntregue = 'pedido_entregue';
  static const pedidoCancelado = 'pedido_cancelado';
}

class NotificacaoReferenciaTipo {
  static const agendamento = 'agendamento';
  static const pedido = 'pedido';
}

class Notificacao {
  final String id;
  final String destinatarioId;
  final String tipo;
  final String titulo;
  final String corpo;
  final String referenciaId;
  final String referenciaTipo;
  final bool lida;
  final DateTime? criadoEm;

  const Notificacao({
    required this.id,
    required this.destinatarioId,
    required this.tipo,
    required this.titulo,
    required this.corpo,
    required this.referenciaId,
    required this.referenciaTipo,
    required this.lida,
    this.criadoEm,
  });

  factory Notificacao.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return Notificacao(
      id: doc.id,
      destinatarioId: map['destinatarioId'] as String? ?? '',
      tipo: map['tipo'] as String? ?? '',
      titulo: map['titulo'] as String? ?? '',
      corpo: map['corpo'] as String? ?? '',
      referenciaId: map['referenciaId'] as String? ?? '',
      referenciaTipo: map['referenciaTipo'] as String? ?? '',
      lida: map['lida'] as bool? ?? false,
      criadoEm: (map['criadoEm'] as Timestamp?)?.toDate(),
    );
  }

  bool get isAgendamento => referenciaTipo == NotificacaoReferenciaTipo.agendamento;
  bool get isPedido => referenciaTipo == NotificacaoReferenciaTipo.pedido;
}