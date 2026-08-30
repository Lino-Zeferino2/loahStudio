class PagamentoConfig {
  final String iban;
  final String titular;
  final String mbwayNumero;
  final String whatsappNumero;

  const PagamentoConfig({
    this.iban = '',
    this.titular = '',
    this.mbwayNumero = '',
    this.whatsappNumero = '',
  });

  bool get isConfigurado => iban.isNotEmpty || mbwayNumero.isNotEmpty;

  factory PagamentoConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PagamentoConfig();
    return PagamentoConfig(
      iban: map['iban'] as String? ?? '',
      titular: map['titular'] as String? ?? '',
      mbwayNumero: map['mbwayNumero'] as String? ?? '',
      whatsappNumero: map['whatsappNumero'] as String? ?? '',
    );
  }
}