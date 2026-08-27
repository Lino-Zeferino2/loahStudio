import 'package:cloud_firestore/cloud_firestore.dart';

class Agendamento {
  final String? id;
  final String? clienteId;
  final String clienteNome;
  final String clienteEmail;
  final String clienteTelefone;
  final String? observacao;
  final String servicoId;
  final String servicoNome;
  final double servicoPreco;
  final int servicoDuracaoMinutos;
  final DateTime data;
  final String horaInicio;
  final String horaFim;
  final String status; // 'pendente', 'confirmado', 'concluido', 'cancelado'
  final DateTime? criadoEm;

  Agendamento({
    this.id,
    this.clienteId,
    required this.clienteNome,
    required this.clienteEmail,
    required this.clienteTelefone,
    this.observacao,
    required this.servicoId,
    required this.servicoNome,
    required this.servicoPreco,
    required this.servicoDuracaoMinutos,
    required this.data,
    required this.horaInicio,
    required this.horaFim,
    this.status = 'pendente',
    this.criadoEm,
  });

  factory Agendamento.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Agendamento(
      id: doc.id,
      clienteId: map['clienteId'] as String?,
      clienteNome: map['clienteNome'] as String? ?? '',
      clienteEmail: map['clienteEmail'] as String? ?? '',
      clienteTelefone: map['clienteTelefone'] as String? ?? '',
      observacao: map['observacao'] as String?,
      servicoId: map['servicoId'] as String? ?? '',
      servicoNome: map['servicoNome'] as String? ?? '',
      servicoPreco: (map['servicoPreco'] as num?)?.toDouble() ?? 0.0,
      servicoDuracaoMinutos: map['servicoDuracaoMinutos'] as int? ?? 0,
      data: (map['data'] as Timestamp).toDate(),
      horaInicio: map['horaInicio'] as String? ?? '',
      horaFim: map['horaFim'] as String? ?? '',
      status: map['status'] as String? ?? 'pendente',
      criadoEm: (map['criadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'clienteEmail': clienteEmail,
      'clienteTelefone': clienteTelefone,
      'observacao': observacao,
      'servicoId': servicoId,
      'servicoNome': servicoNome,
      'servicoPreco': servicoPreco,
      'servicoDuracaoMinutos': servicoDuracaoMinutos,
      'data': Timestamp.fromDate(DateTime(data.year, data.month, data.day)),
      'horaInicio': horaInicio,
      'horaFim': horaFim,
      'status': status,
      'criadoEm': FieldValue.serverTimestamp(),
    };
  }
}