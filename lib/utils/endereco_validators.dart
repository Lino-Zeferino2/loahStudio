import 'package:flutter/services.dart';

/// Validadores e formatadores para campos de morada em Portugal.
///
/// Cobre: morada (rua + número), código postal (formato NNNN-NNN)
/// e cidade/localidade.
class EnderecoValidators {
  EnderecoValidators._();

  // Aceita letras (com acentos), números, espaços e pontuação comum
  // em moradas portuguesas (vírgulas, pontos, hífen, º/ª, barra para "5/2º").
  static final RegExp _regexMorada = RegExp(r"^[a-zA-ZÀ-ÿ0-9\s,.\-ºª/ºn.ºN.º]+$");

  static final RegExp _regexCodigoPostal = RegExp(r'^\d{4}-\d{3}$');

  // Letras (com acentos), espaços, hífen e apóstrofo (ex: "Vila Nova d'Além").
  static final RegExp _regexCidade = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");

  static const int _moradaMinLength = 5;
  static const int _moradaMaxLength = 100;
  static const int _cidadeMinLength = 2;
  static const int _cidadeMaxLength = 60;

  /// Valida o campo "Morada". Exige rua + número de porta.
  static String? validarMorada(String? value) {
    final texto = value?.trim() ?? '';

    if (texto.isEmpty) {
      return 'A morada é obrigatória';
    }
    if (texto.length < _moradaMinLength) {
      return 'A morada é demasiado curta';
    }
    if (texto.length > _moradaMaxLength) {
      return 'A morada não pode exceder $_moradaMaxLength caracteres';
    }
    if (!_regexMorada.hasMatch(texto)) {
      return 'A morada contém caracteres inválidos';
    }
    if (!RegExp(r'\d').hasMatch(texto)) {
      return 'Indica o número da porta (ex: Rua das Flores, 12)';
    }
    return null;
  }

  /// Valida o código postal no formato português NNNN-NNN.
  static String? validarCodigoPostal(String? value) {
    final texto = value?.trim() ?? '';

    if (texto.isEmpty) {
      return 'O código postal é obrigatório';
    }
    if (!texto.contains('-')) {
      return 'Falta o hífen. Formato: 1000-001';
    }
    if (!_regexCodigoPostal.hasMatch(texto)) {
      final partes = texto.split('-');
      if (partes.length == 2 && partes[0].length != 4) {
        return 'A primeira parte deve ter 4 dígitos';
      }
      if (partes.length == 2 && partes[1].length != 3) {
        return 'A segunda parte deve ter 3 dígitos';
      }
      return 'Formato inválido. Usa NNNN-NNN (ex: 1000-001)';
    }
    return null;
  }

  /// Valida o campo "Cidade".
  static String? validarCidade(String? value) {
    final texto = value?.trim() ?? '';

    if (texto.isEmpty) {
      return 'A cidade é obrigatória';
    }
    if (texto.length < _cidadeMinLength) {
      return 'Nome de cidade demasiado curto';
    }
    if (texto.length > _cidadeMaxLength) {
      return 'Nome de cidade demasiado longo';
    }
    if (!_regexCidade.hasMatch(texto)) {
      return 'A cidade não deve conter números ou símbolos';
    }
    return null;
  }
}

/// Formata automaticamente o código postal para o padrão NNNN-NNN
/// enquanto o utilizador escreve, inserindo o hífen na posição certa.
class CodigoPostalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitos.length > 7) {
      digitos = digitos.substring(0, 7);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digitos.length; i++) {
      if (i == 4) buffer.write('-');
      buffer.write(digitos[i]);
    }

    final texto = buffer.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}