import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/controller/pedido_controller.dart';
import 'package:loahstudio/model/pagamento_config_model.dart';

class CheckoutDialog extends StatefulWidget {
  final double total;
  final void Function({
    required String metodoPagamento,
    required String nome,
    required String email,
    required String telefone,
    required String morada,
    required String codigoPostal,
    required String cidade,
  }) onConfirmar;

  const CheckoutDialog({super.key, required this.total, required this.onConfirmar});

  static Future<void> show(
    BuildContext context, {
    required double total,
    required void Function({
      required String metodoPagamento,
      required String nome,
      required String email,
      required String telefone,
      required String morada,
      required String codigoPostal,
      required String cidade,
    }) onConfirmar,
  }) {
    return showDialog(context: context, builder: (_) => CheckoutDialog(total: total, onConfirmar: onConfirmar));
  }

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final moradaController = TextEditingController();
  final cpController = TextEditingController();
  final cidadeController = TextEditingController();
  String pagamentoSelecionado = 'transferencia';

  late final Future<PagamentoConfig> _configFuture;

  @override
  void initState() {
    super.initState();
    _configFuture = PedidoController().fetchPagamentoConfig();
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    moradaController.dispose();
    cpController.dispose();
    cidadeController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (nomeController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        telefoneController.text.trim().isEmpty ||
        moradaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, preencha todos os campos necessários."), backgroundColor: Colors.red),
      );
      return;
    }

    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final telefone = telefoneController.text.trim();
    final morada = moradaController.text.trim();
    final cp = cpController.text.trim();
    final cidade = cidadeController.text.trim();

    Navigator.pop(context);
    widget.onConfirmar(
      metodoPagamento: pagamentoSelecionado,
      nome: nome,
      email: email,
      telefone: telefone,
      morada: morada,
      codigoPostal: cp,
      cidade: cidade,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = isMobile ? screenWidth * 0.95 : 500.0;
    final horizontalPad = isMobile ? 16.0 : 30.0;
    final titleSize = isMobile ? 20.0 : 24.0;
    final subtitleSize = isMobile ? 14.0 : 16.0;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: EdgeInsets.all(horizontalPad),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Finalizar compra", style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 24),
              Text("Dados de contacto", style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w600, color: const Color(0xFF5A4A42))),
              SizedBox(height: isMobile ? 10 : 16),
              _textField(nomeController, "Nome completo", Icons.person_outline, isMobile: isMobile),
              SizedBox(height: isMobile ? 8 : 12),
              _textField(emailController, "Email", Icons.email_outlined, keyboardType: TextInputType.emailAddress, isMobile: isMobile),
              SizedBox(height: isMobile ? 8 : 12),
              _textField(telefoneController, "Telemóvel", Icons.phone_outlined, keyboardType: TextInputType.phone, isMobile: isMobile),
              SizedBox(height: isMobile ? 16 : 24),
              Text("Morada de entrega", style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w600, color: const Color(0xFF5A4A42))),
              SizedBox(height: isMobile ? 10 : 16),
              _textField(moradaController, "Morada", Icons.location_on_outlined, isMobile: isMobile),
              SizedBox(height: isMobile ? 8 : 12),
              if (isMobile) ...[
                _textField(cpController, "Código Postal", Icons.markunread_outlined, isMobile: isMobile),
                const SizedBox(height: 8),
                _textField(cidadeController, "Cidade", Icons.location_city_outlined, isMobile: isMobile),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: _textField(cpController, "Código Postal", Icons.markunread_outlined, isMobile: isMobile)),
                    const SizedBox(width: 12),
                    Expanded(child: _textField(cidadeController, "Cidade", Icons.location_city_outlined, isMobile: isMobile)),
                  ],
                ),
              ],
              SizedBox(height: isMobile ? 16 : 24),
              Text("Método de pagamento", style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w600, color: const Color(0xFF5A4A42))),
              SizedBox(height: isMobile ? 10 : 16),
              _metodoPagamento("Transferência Bancária", "transferencia", Icons.account_balance, isMobile),
              SizedBox(height: isMobile ? 8 : 12),
              _metodoPagamento("MB Way", "mbway", Icons.phone_android, isMobile),
              SizedBox(height: isMobile ? 16 : 24),
              FutureBuilder<PagamentoConfig>(
                future: _configFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  final config = snapshot.data!;
                  if (!config.isConfigurado) {
                    return Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        "As instruções de pagamento ainda não foram configuradas. Contacta-nos diretamente para combinar o pagamento.",
                        style: TextStyle(fontSize: isMobile ? 12 : 13, color: Colors.orange.shade900),
                      ),
                    );
                  }
                  return _instrucoesPagamento(config, isMobile);
                },
              ),
              SizedBox(height: isMobile ? 16 : 24),
              const Divider(),
              SizedBox(height: isMobile ? 12 : 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total a pagar", style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
                  Text("€${widget.total.toStringAsFixed(2)}", style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  onPressed: _confirmar,
                  child: Text("Confirmar pedido", style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _instrucoesPagamento(PagamentoConfig config, bool isMobile) {
    final linhas = <Widget>[];

    if (pagamentoSelecionado == 'transferencia') {
      linhas.addAll([
        Text("Transferência Bancária", style: TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 12 : 14, color: const Color(0xFF5A4A42))),
        const SizedBox(height: 8),
        if (config.titular.isNotEmpty) Text("Titular: ${config.titular}", style: TextStyle(fontSize: isMobile ? 12 : 14, color: const Color(0xFF7A6A62))),
        Text("IBAN: ${config.iban}", style: TextStyle(fontSize: isMobile ? 12 : 14, color: const Color(0xFF7A6A62))),
      ]);
    } else {
      linhas.addAll([
        Text("MB Way", style: TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 12 : 14, color: const Color(0xFF5A4A42))),
        const SizedBox(height: 8),
        Text("Envia o valor pela app MB Way para o número: ${config.mbwayNumero}", style: TextStyle(fontSize: isMobile ? 12 : 14, color: const Color(0xFF7A6A62))),
      ]);
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(color: const Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...linhas,
          const SizedBox(height: 12),
          Text(
            "Depois de pagares, envia o comprovativo pelo WhatsApp"
            "${config.whatsappNumero.isNotEmpty ? ' (${config.whatsappNumero})' : ''} "
            "ou carrega-o na página \"As minhas Compras\" enquanto o pedido estiver pendente.",
            style: TextStyle(fontSize: isMobile ? 11 : 12, color: const Color(0xFF7A6A62), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, bool isMobile = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: isMobile ? 14 : 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
        prefixIcon: Icon(icon, size: isMobile ? 18 : 20),
        contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pinkStrong)),
      ),
    );
  }

  Widget _metodoPagamento(String titulo, String valor, IconData icone, bool isMobile) {
    final isSelected = pagamentoSelecionado == valor;
    final fontSize = isMobile ? 14.0 : 16.0;
    final iconSize = isMobile ? 20.0 : 24.0;
    final padding = isMobile ? 12.0 : 16.0;
    return GestureDetector(
      onTap: () => setState(() => pagamentoSelecionado = valor),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppColors.pinkStrong : Colors.grey.shade300, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.pinkStrong.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: isMobile ? 20 : 24,
              height: isMobile ? 20 : 24,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? AppColors.pinkStrong : Colors.grey.shade400, width: 2)),
              child: isSelected
                  ? Center(child: Container(width: isMobile ? 10 : 12, height: isMobile ? 10 : 12, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.pinkStrong)))
                  : null,
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Icon(icone, size: iconSize, color: isSelected ? AppColors.pinkStrong : const Color(0xFF5A4A42)),
            SizedBox(width: isMobile ? 8 : 12),
            Flexible(
              child: Text(titulo, style: TextStyle(fontSize: fontSize, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? AppColors.pinkStrong : const Color(0xFF5A4A42)), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}