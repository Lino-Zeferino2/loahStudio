import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/controller/auth_controller.dart';

// Removida a opção de convidado — o site já não permite agendar de forma
// anónima. Só resta escolher entre iniciar sessão numa conta existente ou
// criar uma conta nova.
enum ModoDados { login, criarConta }

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
  // Por defeito abre já em "Criar conta", já que é o caminho mais comum
  // para quem chega pela primeira vez a agendar.
  ModoDados _modo = ModoDados.criarConta;
  bool _isProcessando = false;
  String? _erroGeral;

  final _loginEmailController = TextEditingController();
  final _loginSenhaController = TextEditingController();
  final _criarSenhaController = TextEditingController();
  final _criarConfirmarSenhaController = TextEditingController();

  // Validação dinâmica: cada campo tem uma mensagem de erro (ou null se
  // válido) e um flag "tocado" — só mostramos o erro depois de o
  // utilizador ter interagido com o campo, para não pintar tudo de
  // vermelho antes de ele sequer começar a escrever.
  final Map<String, String?> _erros = {};
  final Set<String> _tocados = {};

  User? get _user => FirebaseAuth.instance.currentUser;
  bool get isLoggedIn => _user != null;
  bool get isCarregando => _isProcessando;

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

  // ---------------------------------------------------------------------
  // Validadores
  // ---------------------------------------------------------------------

  String? _validarNome(String v) {
    if (v.trim().isEmpty) return 'Indica o teu nome completo';
    if (v.trim().length < 3) return 'Nome demasiado curto';
    return null;
  }

  String? _validarEmail(String v) {
    if (v.trim().isEmpty) return 'Indica o teu email';
    final regex = RegExp(r'^[\w.\-+]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(v.trim())) return 'Email inválido';
    return null;
  }

  String? _validarTelefone(String v) {
    final digitos = v.replaceAll(RegExp(r'\D'), '');
    if (digitos.isEmpty) return 'Indica o teu número de telemóvel';
    if (digitos.length != 9) return 'O telemóvel deve ter 9 dígitos';
    if (!digitos.startsWith('9')) return 'Número de telemóvel inválido';
    return null;
  }

  String? _validarSenha(String v) {
    if (v.isEmpty) return 'Cria uma senha';
    if (v.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
    return null;
  }

  String? _validarConfirmarSenha(String v) {
    if (v.isEmpty) return 'Confirma a senha';
    if (v != _criarSenhaController.text) return 'As senhas não coincidem';
    return null;
  }

  String? _validarLoginSenha(String v) {
    if (v.isEmpty) return 'Indica a tua senha';
    return null;
  }

  void _validarCampo(String campoKey, String valor, String? Function(String) validador) {
    setState(() {
      _tocados.add(campoKey);
      _erros[campoKey] = validador(valor);
      // A confirmação de senha depende do valor da senha principal — ao
      // editar a senha, revalida a confirmação também, se já foi tocada.
      if (campoKey == 'senha' && _tocados.contains('confirmarSenha')) {
        _erros['confirmarSenha'] = _validarConfirmarSenha(_criarConfirmarSenhaController.text);
      }
    });
  }

  /// Indica se os campos relevantes ao modo atual estão todos válidos.
  /// Usado pelo ecrã pai (ServicosPage) para decidir se pode avançar para
  /// o resumo de confirmação.
  bool get isFormValido {
    if (isLoggedIn) {
      return _validarNome(widget.nomeController.text) == null &&
          _validarEmail(widget.emailController.text) == null &&
          _validarTelefone(widget.telefoneController.text) == null;
    }
    if (_modo == ModoDados.criarConta) {
      return _validarNome(widget.nomeController.text) == null &&
          _validarEmail(widget.emailController.text) == null &&
          _validarTelefone(widget.telefoneController.text) == null &&
          _validarSenha(_criarSenhaController.text) == null &&
          _validarConfirmarSenha(_criarConfirmarSenhaController.text) == null &&
          widget.aceitouTermos;
    }
    return _validarEmail(_loginEmailController.text) == null &&
        _validarLoginSenha(_loginSenhaController.text) == null;
  }

  /// Força a apresentação de todos os erros do modo atual — usado quando
  /// o utilizador tenta submeter sem ter tocado em todos os campos (ex:
  /// campos vazios vindos de um fetch que falhou).
  void marcarTodosTocados() {
    setState(() {
      if (isLoggedIn) {
        _tocados.addAll(['nome', 'email', 'telefone']);
        _erros['nome'] = _validarNome(widget.nomeController.text);
        _erros['email'] = _validarEmail(widget.emailController.text);
        _erros['telefone'] = _validarTelefone(widget.telefoneController.text);
      } else if (_modo == ModoDados.criarConta) {
        _tocados.addAll(['nome', 'email', 'telefone', 'senha', 'confirmarSenha']);
        _erros['nome'] = _validarNome(widget.nomeController.text);
        _erros['email'] = _validarEmail(widget.emailController.text);
        _erros['telefone'] = _validarTelefone(widget.telefoneController.text);
        _erros['senha'] = _validarSenha(_criarSenhaController.text);
        _erros['confirmarSenha'] = _validarConfirmarSenha(_criarConfirmarSenhaController.text);
      } else {
        _tocados.addAll(['loginEmail', 'loginSenha']);
        _erros['loginEmail'] = _validarEmail(_loginEmailController.text);
        _erros['loginSenha'] = _validarLoginSenha(_loginSenhaController.text);
      }
    });
  }

  void _limparValidacao() {
    _erros.clear();
    _tocados.clear();
  }

  // ---------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------

  Future<void> _preencherDadosDoUtilizador() async {
    final uid = _user?.uid;
    if (uid == null) return;
    setState(() => _isProcessando = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('clientes').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        widget.nomeController.text = data['nome'] as String? ?? '';
        widget.emailController.text = data['email'] as String? ?? (_user?.email ?? '');
        widget.telefoneController.text = data['telefone'] as String? ?? '';
      } else {
        // Documento ainda não existe no Firestore — pelo menos usa o
        // email da autenticação para não deixar o campo vazio.
        widget.emailController.text = _user?.email ?? '';
      }
    } catch (_) {
      // Se falhar, o utilizador continua logado mas com campos vazios —
      // ele vê isso nos campos (agora visíveis) e pode preenchê-los
      // manualmente, o formulário não é bloqueado.
    }
    if (!mounted) return;
    setState(() => _isProcessando = false);
  }

  Future<void> _fazerLogin() async {
    marcarTodosTocados();
    if (_validarEmail(_loginEmailController.text) != null ||
        _validarLoginSenha(_loginSenhaController.text) != null) {
      return;
    }
    setState(() { _isProcessando = true; _erroGeral = null; });
    _authController.loginUser(
      email: _loginEmailController.text,
      password: _loginSenhaController.text,
      onComplete: (success, error) async {
        if (!mounted) return;
        if (success) {
          _limparValidacao();
          await _preencherDadosDoUtilizador();
        } else {
          setState(() { _isProcessando = false; _erroGeral = error; });
        }
      },
    );
  }

  Future<void> _criarConta() async {
    marcarTodosTocados();
    if (!isFormValido) {
      if (!widget.aceitouTermos) {
        setState(() => _erroGeral = 'Tens de aceitar os termos e condições.');
      }
      return;
    }
    setState(() { _isProcessando = true; _erroGeral = null; });
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
          setState(() => _erroGeral = error);
        } else {
          _limparValidacao();
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
    _limparValidacao();
    if (!mounted) return;
    setState(() => _modo = ModoDados.criarConta);
  }

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------

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
                child: Text(
                  _isProcessando ? 'A carregar os teus dados...' : 'Sessão iniciada',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A4A42)),
                ),
              ),
              TextButton(onPressed: _sair, child: const Text('Sair', style: TextStyle(color: Colors.red))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isProcessando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          // Os campos ficam sempre visíveis e editáveis (mesmo pré-
          // preenchidos), para que vejas de imediato se algum ficou vazio
          // em vez de descobrires só ao tentar confirmar.
          _campo(
            campoKey: 'nome',
            controller: widget.nomeController,
            label: 'Nome',
            hint: 'Digite o seu nome completo',
            tipo: TextInputType.name,
            validador: _validarNome,
          ),
          const SizedBox(height: 12),
          _campo(
            campoKey: 'email',
            controller: widget.emailController,
            label: 'Email',
            hint: 'Digite o seu email',
            tipo: TextInputType.emailAddress,
            validador: _validarEmail,
          ),
          const SizedBox(height: 12),
          _campo(
            campoKey: 'telefone',
            controller: widget.telefoneController,
            label: 'Número de Telemóvel',
            hint: '9XX XXX XXX',
            tipo: TextInputType.phone,
            validador: _validarTelefone,
          ),
          const SizedBox(height: 12),
          _campo(
            campoKey: 'observacao',
            controller: widget.observacaoController,
            label: 'Observação (opcional)',
            hint: 'Alguma informação adicional?',
            tipo: TextInputType.multiline,
            validador: (_) => null,
            maxLines: 3,
          ),
        ],
      ],
    );
  }

  Widget _buildNaoLogado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: const Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.pinkStrong),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Para agendar precisas de ter conta. Cria uma agora ou inicia sessão se já tiveres.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF7A6A62)),
                ),
              ),
            ],
          ),
        ),
        _buildTabs(),
        const SizedBox(height: 16),
        if (_erroGeral != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_erroGeral!, style: const TextStyle(color: Colors.red, fontSize: 13))),
        if (_modo == ModoDados.login) _buildLoginForm(),
        if (_modo == ModoDados.criarConta) _buildDadosForm(),
        if (_modo == ModoDados.criarConta) ...[
          const SizedBox(height: 12),
          _buildTermos(),
        ],
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
    );
  }

  Widget _buildTabs() {
    Widget tab(String label, ModoDados modo) {
      final isSelected = _modo == modo;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() { _modo = modo; _erroGeral = null; }),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: isSelected ? AppColors.pinkStrong : const Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(10)),
            child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF5A4A42), fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      );
    }
    return Row(children: [
      tab('Já tenho conta', ModoDados.login),
      const SizedBox(width: 8),
      tab('Criar conta', ModoDados.criarConta),
    ]);
  }

  Widget _buildLoginForm() {
    return Column(children: [
      _campo(
        campoKey: 'loginEmail',
        controller: _loginEmailController,
        label: 'Email',
        hint: 'Digite o seu email',
        tipo: TextInputType.emailAddress,
        validador: _validarEmail,
      ),
      const SizedBox(height: 12),
      _campo(
        campoKey: 'loginSenha',
        controller: _loginSenhaController,
        label: 'Senha',
        hint: 'Digite a sua senha',
        tipo: TextInputType.visiblePassword,
        validador: _validarLoginSenha,
        obscure: true,
      ),
    ]);
  }

  Widget _buildDadosForm() {
    return Column(children: [
      _campo(
        campoKey: 'nome',
        controller: widget.nomeController,
        label: 'Nome',
        hint: 'Digite o seu nome completo',
        tipo: TextInputType.name,
        validador: _validarNome,
      ),
      const SizedBox(height: 12),
      _campo(
        campoKey: 'email',
        controller: widget.emailController,
        label: 'Email',
        hint: 'Digite o seu email',
        tipo: TextInputType.emailAddress,
        validador: _validarEmail,
      ),
      const SizedBox(height: 12),
      _campo(
        campoKey: 'telefone',
        controller: widget.telefoneController,
        label: 'Número de Telemóvel',
        hint: '9XX XXX XXX',
        tipo: TextInputType.phone,
        validador: _validarTelefone,
      ),
      const SizedBox(height: 12),
      _campo(
        campoKey: 'observacao',
        controller: widget.observacaoController,
        label: 'Observação (opcional)',
        hint: 'Alguma informação adicional?',
        tipo: TextInputType.multiline,
        validador: (_) => null,
        maxLines: 3,
      ),
      const SizedBox(height: 12),
      _campo(
        campoKey: 'senha',
        controller: _criarSenhaController,
        label: 'Senha',
        hint: 'Cria uma senha (mín. 6 caracteres)',
        tipo: TextInputType.visiblePassword,
        validador: _validarSenha,
        obscure: true,
      ),
      const SizedBox(height: 12),
      _campo(
        campoKey: 'confirmarSenha',
        controller: _criarConfirmarSenhaController,
        label: 'Confirmar Senha',
        hint: 'Repete a senha',
        tipo: TextInputType.visiblePassword,
        validador: _validarConfirmarSenha,
        obscure: true,
      ),
    ]);
  }

  /// Campo de texto com validação em tempo real: mostra contorno e ícone
  /// vermelhos com mensagem de erro assim que o campo é tocado e fica
  /// inválido, ou um visto verde quando o valor introduzido é válido.
  Widget _campo({
    required String campoKey,
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType tipo,
    required String? Function(String) validador,
    bool obscure = false,
    int maxLines = 1,
  }) {
    final tocado = _tocados.contains(campoKey);
    final erro = tocado ? _erros[campoKey] : null;
    final valido = tocado && erro == null && controller.text.trim().isNotEmpty;

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
          onChanged: (v) => _validarCampo(campoKey, v, validador),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF7A6A62)),
            filled: true,
            fillColor: const Color(0xFFF7F4F2),
            suffixIcon: erro != null
                ? const Icon(Icons.error_outline, color: Colors.red, size: 20)
                : (valido ? const Icon(Icons.check_circle, color: Colors.green, size: 20) : null),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: erro != null ? Colors.red : Colors.transparent, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: erro != null ? Colors.red : AppColors.pinkStrong, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        if (erro != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(erro, style: const TextStyle(color: Colors.red, fontSize: 12)),
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