class AppValidators {
  AppValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  static bool isValidEmail(String value) => _emailRegex.hasMatch(value.trim());

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Por favor, insira o seu email';
    if (!isValidEmail(trimmed)) return 'Insira um email válido (ex: nome@exemplo.com)';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final v = value ?? '';
    if (v.isEmpty) return 'Por favor, insira a sua senha';
    if (v.length < minLength) return 'A senha deve ter pelo menos $minLength caracteres';
    return null;
  }

  static String? loginPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Por favor, insira a sua senha';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Por favor, confirme a sua senha';
    if (value != original) return 'As senhas não coincidem';
    return null;
  }

  static String? nomeCompleto(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Por favor, insira o seu nome';
    if (trimmed.length < 3) return 'Insira o seu nome completo';
    return null;
  }

  static String? telefonePT(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Por favor, insira o seu número de telemóvel';
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    final localNumber = digitsOnly.startsWith('351') ? digitsOnly.substring(3) : digitsOnly;
    if (localNumber.length != 9) return 'Número de telemóvel inválido';
    if (!RegExp(r'^[92368]').hasMatch(localNumber)) return 'Número de telemóvel inválido';
    return null;
  }
}