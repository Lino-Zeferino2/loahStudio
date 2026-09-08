import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/view/admin_views/admin_layout.dart';
import 'package:loahstudio/controller/auth_controller.dart';
import 'package:loahstudio/utils/validators.dart';
import 'package:loahstudio/view/auth/email_verification_pending_page.dart';
import 'package:loahstudio/view/auth/forgot_password_page.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSubmitting = false; // Guard against double submissions
  bool _aceitouTermos = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefoneController = TextEditingController();

  final AuthController authController = AuthController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting) return;

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    // O Checkbox não participa do Form/validate() como os TextFormField,
    // por isso esta checagem tem de ficar separada — não é redundante.
    if (!_isLogin && !_aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tens de aceitar os Termos e Condições e a Política de Privacidade.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isSubmitting = true;
    });

    if (_isLogin) {
      authController.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
        onComplete: _onAuthComplete,
      );
    } else {
      authController.registerUser(
        nome: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        telefone: _telefoneController.text,
        aceitouTermos: _aceitouTermos,
        onComplete: _onAuthComplete,
      );
    }
  }

  void _mostrarTermos() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Termos e Condições'),
        content: const SingleChildScrollView(
          child: Text('Conteúdo dos Termos e Condições ainda por definir.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }

  void _mostrarPolitica() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Política de Privacidade'),
        content: const SingleChildScrollView(
          child: Text('Conteúdo da Política de Privacidade ainda por definir.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }

  void _irParaRecuperarSenha() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
  }

  // ---------- Ícones de validação em tempo real ----------

  Widget _iconeValidacao(Listenable listenable, bool Function() temValor, String? Function() erro) {
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        if (!temValor()) return const SizedBox.shrink();
        final e = erro();
        return Icon(
          e == null ? Icons.check_circle : Icons.error,
          color: e == null ? Colors.green : Colors.red,
          size: 20,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.lightCreamBg,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 20 : 40),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Container(
                  constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 450),
                  padding: EdgeInsets.all(isMobile ? 24 : 40),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.grey.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo/Título
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loah Stúdio',
                        style: TextStyle(
                          color: AppColors.brown,
                          fontSize: isMobile ? 24 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin ? 'Login' : 'Criar Conta',
                        style: TextStyle(color: AppColors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 32),

                      // Campo Nome (só para registo)
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _nameController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Nome Completo',
                            prefixIcon: const Icon(Icons.person, color: AppColors.grey),
                            suffixIcon: _iconeValidacao(
                              _nameController,
                              () => _nameController.text.isNotEmpty,
                              () => AppValidators.nomeCompleto(_nameController.text),
                            ),
                            filled: true,
                            fillColor: AppColors.lightCreamBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: AppValidators.nomeCompleto,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _telefoneController,
                          keyboardType: TextInputType.phone,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Telemóvel',
                            prefixIcon: const Icon(Icons.phone, color: AppColors.grey),
                            suffixIcon: _iconeValidacao(
                              _telefoneController,
                              () => _telefoneController.text.isNotEmpty,
                              () => AppValidators.telefonePT(_telefoneController.text),
                            ),
                            filled: true,
                            fillColor: AppColors.lightCreamBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => _isLogin ? null : AppValidators.telefonePT(value),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Campo Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email, color: AppColors.grey),
                          suffixIcon: _iconeValidacao(
                            _emailController,
                            () => _emailController.text.isNotEmpty,
                            () => AppValidators.email(_emailController.text),
                          ),
                          filled: true,
                          fillColor: AppColors.lightCreamBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: AppValidators.email,
                      ),
                      const SizedBox(height: 16),

                      // Campo Senha
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock, color: AppColors.grey),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _iconeValidacao(
                                _passwordController,
                                () => _passwordController.text.isNotEmpty,
                                () => _isLogin
                                    ? AppValidators.loginPassword(_passwordController.text)
                                    : AppValidators.password(_passwordController.text, minLength: 6),
                              ),
                              IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: AppColors.grey,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ],
                          ),
                          filled: true,
                          fillColor: AppColors.lightCreamBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) => _isLogin
                            ? AppValidators.loginPassword(value)
                            : AppValidators.password(value, minLength: 6),
                      ),
                      const SizedBox(height: 16),

                      // Campo Confirmar Senha (só para registo)
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Confirmar Senha',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _iconeValidacao(
                                  Listenable.merge([_passwordController, _confirmPasswordController]),
                                  () => _confirmPasswordController.text.isNotEmpty,
                                  () => AppValidators.confirmPassword(
                                    _confirmPasswordController.text,
                                    _passwordController.text,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                    color: AppColors.grey,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                              ],
                            ),
                            filled: true,
                            fillColor: AppColors.lightCreamBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => _isLogin
                              ? null
                              : AppValidators.confirmPassword(value, _passwordController.text),
                        ),
                        const SizedBox(height: 16),

                        // Aceitar Termos e Condições / Política de Privacidade
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _aceitouTermos,
                                activeColor: AppColors.pinkStrong,
                                onChanged: (v) => setState(() => _aceitouTermos = v ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _aceitouTermos = !_aceitouTermos),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                                    children: [
                                      const TextSpan(text: 'Li e aceito os '),
                                      TextSpan(
                                        text: 'Termos e Condições',
                                        style: TextStyle(
                                          color: AppColors.pinkStrong,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()..onTap = _mostrarTermos,
                                      ),
                                      const TextSpan(text: ' e a '),
                                      TextSpan(
                                        text: 'Política de Privacidade',
                                        style: TextStyle(
                                          color: AppColors.pinkStrong,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()..onTap = _mostrarPolitica,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Esqueceu a senha (só login)
                      if (_isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _irParaRecuperarSenha,
                            child: Text('Esqueceu a senha?', style: TextStyle(color: AppColors.pinkStrong)),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Botão Submit
                      SizedBox(
                        width: double.infinity,
                        height: ResponsiveHelper.buttonHeight(context),
                        child: ElevatedButton(
                          onPressed: (_isLoading || _isSubmitting) ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pinkStrong,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Entrar' : 'Registar',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Alternar Login/Registo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin ? 'Não tem conta? ' : 'Já tem conta? ',
                            style: TextStyle(color: AppColors.grey),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () => setState(() => _isLogin = !_isLogin),
                            child: Text(
                              _isLogin ? 'Registar' : 'Entrar',
                              style: TextStyle(color: AppColors.pinkStrong, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                      // Voltar para site (ícone)
                      const SizedBox(height: 24),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => HomePage()),
                            (route) => false,
                          );
                        },
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, color: AppColors.grey, size: 18),
                            const SizedBox(width: 4),
                            Text('Voltar para o site', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  void _onAuthComplete(bool success, String? error) async {
    if (!mounted) return;

    if (!success) {
      setState(() {
        _isLoading = false;
        _isSubmitting = false;
      });
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isSubmitting = false;
    });

    // Só deixa avançar para a Home/Admin quem já confirmou o email —
    // quem acabou de registar-se ou tenta entrar sem confirmar cai aqui.
    if (user != null && !user.emailVerified) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const EmailVerificationPendingPage()),
        (route) => false,
      );
      return;
    }

    final role = user != null ? await authController.getUserRole(user.uid) : null;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLogin ? 'Sessão iniciada!' : 'Conta criada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => role == 'admin' ? const AdminLayout() : HomePage()),
    );
  }
}