import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String? morada; // opcional
  final String role;
  final String status;
  final DateTime? dataCadastro;

  const UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    this.morada,
    this.role = 'user',
    this.status = 'ativo',
    this.dataCadastro,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      nome: (map['nome'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      telefone: (map['telefone'] ?? '') as String,
      morada: map['morada'] as String?,
      role: (map['role'] ?? 'user') as String,
      status: (map['status'] ?? 'ativo') as String,
      dataCadastro: (map['dataCadastro'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      if (morada != null) 'morada': morada,
      'role': role,
      'status': status,
    };
  }

  UserModel copyWith({
    String? nome,
    String? email,
    String? telefone,
    String? morada,
    String? role,
    String? status,
  }) {
    return UserModel(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      morada: morada ?? this.morada,
      role: role ?? this.role,
      status: status ?? this.status,
      dataCadastro: dataCadastro,
    );
  }
}