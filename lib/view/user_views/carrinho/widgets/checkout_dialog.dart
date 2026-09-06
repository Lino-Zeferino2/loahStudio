import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/controller/auth_controller.dart';
import 'package:loahstudio/controller/pedido_controller.dart';
import 'package:loahstudio/model/pagamento_config_model.dart';
import 'package:loahstudio/model/user_model.dart';
import 'package:loahstudio/utils/endereco_validators.dart';

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
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final moradaController = TextEditingController();
  final cpController = TextEditingController();
  final cidadeController = TextEditingController();
  String pagamentoSelecionado = 'transferencia';

  late final Future<PagamentoConfig> _configFuture;
  final AuthController _authController = AuthController();

  UserModel? _perfil;
  bool _carregandoPerfil = true;
  // true = campos de contacto vêm do perfil (bloqueados); false = manual.
  bool _usarDadosProprios = true;

  @override
  void initState() {
    super.initState();
    _configFuture = PedidoController().fetchPagamentoConfig();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // Não deve acontecer — o CarrinhoPage só chama o checkout com utilizador
      // autenticado — mas mantemos o formulário manual como rede de segurança.
      setState(() => _carregandoPerfil = false);
      return;
    }

    final user = await _authController.getUserData(uid);
    if (!mounted) return;

    setState(() {
      _perfil = user;
      _carregandoPerfil = false;
      // Só ativa o preenchimento automático se houver pelo menos nome e
      // telefone guardados — senão não há nada útil para pré-preencher.
      _usarDadosProprios = user != null && user.nome.isNotEmpty && user.telefone.isNotEmpty;
      if (_usarDadosProprios) _preencherComPerfil();
    });
  }

  void _preencherComPerfil() {
    if (_perfil == null) return;
    nomeController.text = _perfil!.nome;
    emailController.text = _perfil!.email;
    telefoneController.text = _perfil!.telefone;
  }

  void _alternarModoPreenchimento(bool usarProprios) {
    setState(() {
      _usarDadosProprios = usarProprios;
      if (usarProprios) {
        _preencherComPerfil();
      } else {
        nomeController.clear();
        emailController.clear();
        telefoneController.clear();
      }
    });
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
    final formValido = _formKey.currentState?.validate() ?? false;

    if (!formValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Corrige os campos assinalados a vermelho antes de continuar."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (nomeController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        telefoneController.text.trim().isEmpty) {
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
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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

                if (_carregandoPerfil)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else ...[
                  if (_perfil != null && _perfil!.nome.isNotEmpty && _perfil!.telefone.isNotEmpty) ...[
                    _buildToggleModoPreenchimento(isMobile),
                    SizedBox(height: isMobile ? 12 : 16),
                  ],
                  _textField(nomeController, "Nome completo", Icons.person_outline, isMobile: isMobile, enabled: !_usarDadosProprios),
                  SizedBox(height: isMobile ? 8 : 12),
                  _textField(emailController, "Email", Icons.email_outlined, keyboardType: TextInputType.emailAddress, isMobile: isMobile, enabled: !_usarDadosProprios),
                  SizedBox(height: isMobile ? 8 : 12),
                  _textField(telefoneController, "Telemóvel", Icons.phone_outlined, keyboardType: TextInputType.phone, isMobile: isMobile, enabled: !_usarDadosProprios),
                ],

                SizedBox(height: isMobile ? 16 : 24),
                Text("Morada de entrega", style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w600, color: const Color(0xFF5A4A42))),
                SizedBox(height: isMobile ? 10 : 16),
                _moradaFormField(isMobile: isMobile),
                SizedBox(height: isMobile ? 8 : 12),
                if (isMobile) ...[
                  _codigoPostalFormField(isMobile: isMobile),
                  const SizedBox(height: 8),
                  _cidadeFormField(isMobile: isMobile),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _codigoPostalFormField(isMobile: isMobile)),
                      const SizedBox(width: 12),
                      Expanded(child: _cidadeFormField(isMobile: isMobile)),
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
      ),
    );
  }

  // Toggle "Usar os meus dados" vs "Preencher manualmente" — só aparece
  // quando existe perfil suficiente para pré-preencher.
  Widget _buildToggleModoPreenchimento(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4F2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(child: _modoChip("Usar os meus dados", true, isMobile)),
          Expanded(child: _modoChip("Preencher manualmente", false, isMobile)),
        ],
      ),
    );
  }

  Widget _modoChip(String texto, bool valor, bool isMobile) {
    final selecionado = _usarDadosProprios == valor;
    return GestureDetector(
      onTap: () => _alternarModoPreenchimento(valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.pinkStrong : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        alignment: Alignment.center,
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: selecionado ? Colors.white : const Color(0xFF5A4A42),
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

  // Campo genérico usado para nome/email/telefone (sem validação obrigatória
  // de morada — mantém-se como TextField simples).
  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    bool isMobile = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(fontSize: isMobile ? 14 : 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
        prefixIcon: Icon(icon, size: isMobile ? 18 : 20),
        filled: !enabled,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pinkStrong)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  // Base partilhada para os campos de morada com validação em tempo real.
  Widget _addressFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    bool isMobile = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(fontSize: isMobile ? 14 : 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
        prefixIcon: Icon(icon, size: isMobile ? 18 : 20),
        errorMaxLines: 2,
        errorStyle: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.red.shade700),
        contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pinkStrong)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade700, width: 2)),
      ),
    );
  }

  Widget _moradaFormField({required bool isMobile}) {
    return _addressFormField(
      controller: moradaController,
      label: "Morada (rua, número)",
      icon: Icons.location_on_outlined,
      validator: EnderecoValidators.validarMorada,
      isMobile: isMobile,
    );
  }

  Widget _codigoPostalFormField({required bool isMobile}) {
    return _addressFormField(
      controller: cpController,
      label: "Código Postal (0000-000)",
      icon: Icons.markunread_outlined,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
        LengthLimitingTextInputFormatter(8),
        CodigoPostalFormatter(),
      ],
      validator: EnderecoValidators.validarCodigoPostal,
      isMobile: isMobile,
    );
  }

  Widget _cidadeFormField({required bool isMobile}) {
    return _addressFormField(
      controller: cidadeController,
      label: "Cidade",
      icon: Icons.location_city_outlined,
      validator: EnderecoValidators.validarCidade,
      isMobile: isMobile,
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