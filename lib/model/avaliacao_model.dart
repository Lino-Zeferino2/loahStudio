import 'package:cloud_firestore/cloud_firestore.dart';

class Avaliacao {
  final String? id;
  final String nomeCliente;
  final String mensagem;
  final int nota; // 1 a 5
  final bool aprovado;
  final DateTime? criadoEm;

  Avaliacao({
    this.id,
    required this.nomeCliente,
    required this.mensagem,
    required this.nota,
    this.aprovado = true,
    this.criadoEm,
  });

  factory Avaliacao.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Avaliacao(
      id: doc.id,
      nomeCliente: data['nomeCliente'] as String? ?? '',
      mensagem: data['mensagem'] as String? ?? '',
      nota: (data['nota'] as num?)?.toInt() ?? 5,
      aprovado: data['aprovado'] as bool? ?? true,
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomeCliente': nomeCliente,
      'mensagem': mensagem,
      'nota': nota,
      'aprovado': aprovado,
      'criadoEm': criadoEm != null ? Timestamp.fromDate(criadoEm!) : FieldValue.serverTimestamp(),
    };
  }

  Avaliacao copyWith({String? id}) {
    return Avaliacao(
      id: id ?? this.id,
      nomeCliente: nomeCliente,
      mensagem: mensagem,
      nota: nota,
      aprovado: aprovado,
      criadoEm: criadoEm,
    );
  }
}