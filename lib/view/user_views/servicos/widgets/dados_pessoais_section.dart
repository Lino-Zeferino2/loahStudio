import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/controller/auth_controller.dart';

enum ModoDados { convidado, login, criarConta }

class DadosPessoaisSection extends StatefulWidget {
  final TextEditingController nomeController;
  final TextEditingController emailController;
  final TextEditingController telefoneController;
  final TextEditingController observacaoController;
  final bool isMobile;
  final bool aceitouTermos;
  final ValueChanged<bool> onAceitouTermosChanged;

  const DadosPessoaisSection({
    super.key,
    required this.nomeController,
    required this.emailController,
    required this.telefoneController,
    required this.observacaoController,
    required this.isMobile,
    required this.aceitouTermos,
    required this.onAceitouTermosChanged,
  });

  @override
  State<DadosPessoaisSection> createState() => DadosPessoaisSectionState();
}

class DadosPessoaisSectionState extends State<DadosPessoaisSection> {
  final AuthController _authController = AuthController();
  ModoDados _modo = ModoDados.convidado;
  bool _isProcessando = false;
  String? _erro;

  final _loginEmailController = TextEditingController();
  final _loginSenhaController = TextEditingController();
  final _criarSenhaController = TextEditingController();
  final _criarConfirmarSenhaController = TextEditingController();

  User? get _user => FirebaseAuth.instance.currentUser;
  bool get isLoggedIn => _user != null;

  @override
  void initState() {
    super.initState();
    if (isLoggedIn) _preencherDadosDoUtilizador();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginSenhaController.dispose();
    _criarSenhaController.dispose();
    _criarConfirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _preencherDadosDoUtilizador() async {
    final uid = _user?.uid;
    if (uid == null) return;
    setState(() => _isProcessando = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('clientes').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        widget.nomeController.text = data['nome'] as String? ?? '';
        widget.emailController.text = data['email'] as String? ?? '';
        widget.telefoneController.text = data['telefone'] as String? ?? '';
      }
    } catch (_) {
      // Se falhar, o utilizador continua logado mas com campos vazios —
      // ele pode preenchê-los manualmente, o formulário não é bloqueado.
    }
    if (!mounted) return;
    setState(() => _isProcessando = false);
  }

  Future<void> _fazerLogin() async {
    if (_loginEmailController.text.trim().isEmpty || _loginSenhaController.text.isEmpty) {
      setState(() => _erro = 'Preenche email e senha.');
      return;
    }
    setState(() { _isProcessando = true; _erro = null; });
    _authController.loginUser(
      email: _loginEmailController.text,
      password: _loginSenhaController.text,
      onComplete: (success, error) async {
        if (!mounted) return;
        if (success) {
          await _preencherDadosDoUtilizador();
        } else {
          setState(() { _isProcessando = false; _erro = error; });
        }
      },
    );
  }

  Future<void> _criarConta() async {
    if (widget.nomeController.text.trim().isEmpty ||
        widget.emailController.text.trim().isEmpty ||
        widget.telefoneController.text.trim().isEmpty ||
        _criarSenhaController.text.isEmpty) {
      setState(() => _erro = 'Preenche todos os campos.');
      return;
    }
    if (_criarSenhaController.text != _criarConfirmarSenhaController.text) {
      setState(() => _erro = 'As senhas não coincidem.');
      return;
    }
    if (_criarSenhaController.text.length < 6) {
      setState(() => _erro = 'A senha deve ter pelo menos 6 caracteres.');
      return;
    }
    if (!widget.aceitouTermos) {
      setState(() => _erro = 'Tens de aceitar os termos e condições.');
      return;
    }
    setState(() { _isProcessando = true; _erro = null; });
    _authController.registerUser(
  nome: widget.nomeController.text,
  email: widget.emailController.text,
  password: _criarSenhaController.text,
  telefone: widget.telefoneController.text,
  aceitouTermos: widget.aceitouTermos,
  onComplete: (success, error) {
    if (!mounted) return;
    setState(() { _isProcessando = false; });
    if (!success) {
      setState(() => _erro = error);
    } else {
      setState(() {}); // isLoggedIn passa a true, rebuild mostra o resumo
    }
  },
);
  }

  Future<void> _sair() async {
    await FirebaseAuth.instance.signOut();
    widget.nomeController.clear();
    widget.emailController.clear();
    widget.telefoneController.clear();
    if (!mounted) return;
    setState(() => _modo = ModoDados.convidado);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) return _buildLogado();
    return _buildNaoLogado();
  }

  Widget _buildLogado() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.pinkStrong,
              child: Text(
                widget.nomeController.text.isNotEmpty ? widget.nomeController.text[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_isProcessando ? 'A carregar...' : (widget.nomeController.text.isEmpty ? _user!.email ?? '' : widget.nomeController.text),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                  if (widget.emailController.text.isNotEmpty)
                    Text(widget.emailController.text, style: const TextStyle(fontSize: 12, color: Color(0xFF7A6A62))),
                ],
              ),
            ),
            TextButton(onPressed: _sair, child: const Text('Sair', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _campo(widget.observacaoController, 'Observação (opcional)', 'Alguma informação adicional?', TextInputType.multiline, maxLines: 3),
    ],
  );
}

  Widget _buildNaoLogado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabs(),
        const SizedBox(height: 16),
        if (_erro != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 13))),
        if (_modo == ModoDados.login) _buildLoginForm(),
        if (_modo == ModoDados.convidado) _buildDadosForm(mostrarSenha: false),
        if (_modo == ModoDados.criarConta) _buildDadosForm(mostrarSenha: true),
        if (_modo != ModoDados.login) ...[
          const SizedBox(height: 12),
          _buildTermos(),
        ],
        if (_modo == ModoDados.login || _modo == ModoDados.criarConta) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessando ? null : (_modo == ModoDados.login ? _fazerLogin : _criarConta),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              child: _isProcessando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : Text(_modo == ModoDados.login ? 'Entrar' : 'Criar Conta', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTabs() {
    Widget tab(String label, ModoDados modo) {
      final isSelected = _modo == modo;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() { _modo = modo; _erro = null; }),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: isSelected ? AppColors.pinkStrong : const Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(10)),
            child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF5A4A42), fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      );
    }
    return Row(children: [
      tab('Preencher dados', ModoDados.convidado),
      const SizedBox(width: 8),
      tab('Já tenho conta', ModoDados.login),
      const SizedBox(width: 8),
      tab('Criar conta', ModoDados.criarConta),
    ]);
  }

  Widget _buildLoginForm() {
    return Column(children: [
      _campo(_loginEmailController, 'Email', 'Digite o seu email', TextInputType.emailAddress),
      const SizedBox(height: 12),
      _campo(_loginSenhaController, 'Senha', 'Digite a sua senha', TextInputType.visiblePassword, obscure: true),
    ]);
  }

  Widget _buildDadosForm({required bool mostrarSenha}) {
    return Column(children: [
      _campo(widget.nomeController, 'Nome', 'Digite o seu nome completo', TextInputType.name),
      const SizedBox(height: 12),
      _campo(widget.emailController, 'Email', 'Digite o seu email', TextInputType.emailAddress),
      const SizedBox(height: 12),
      _campo(widget.telefoneController, 'Número de Telemóvel', '9XX XXX XXX', TextInputType.phone),
      const SizedBox(height: 12),
      _campo(widget.observacaoController, 'Observação (opcional)', 'Alguma informação adicional?', TextInputType.multiline, maxLines: 3),
      if (mostrarSenha) ...[
        const SizedBox(height: 12),
        _campo(_criarSenhaController, 'Senha', 'Cria uma senha (mín. 6 caracteres)', TextInputType.visiblePassword, obscure: true),
        const SizedBox(height: 12),
        _campo(_criarConfirmarSenhaController, 'Confirmar Senha', 'Repete a senha', TextInputType.visiblePassword, obscure: true),
      ],
    ]);
  }

  Widget _campo(TextEditingController controller, String label, String hint, TextInputType tipo, {bool obscure = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: tipo,
          obscureText: obscure,
          maxLines: obscure ? 1 : maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF7A6A62)),
            filled: true,
            fillColor: const Color(0xFFF7F4F2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pinkStrong, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTermos() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(value: widget.aceitouTermos, activeColor: AppColors.pinkStrong, onChanged: (v) => widget.onAceitouTermosChanged(v ?? false)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text.rich(TextSpan(
              style: const TextStyle(fontSize: 12, color: Color(0xFF7A6A62)),
              children: [
                const TextSpan(text: 'Li e aceito os '),
                TextSpan(text: 'termos e condições', style: TextStyle(color: AppColors.pinkStrong, fontWeight: FontWeight.w600)),
                const TextSpan(text: ' e a política de privacidade.'),
              ],
            )),
          ),
        ),
      ],
    );
  }
}