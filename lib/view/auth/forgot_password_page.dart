import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/auth_controller.dart';
import 'package:loahstudio/utils/validators.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthController _authController = AuthController();

  bool _isLoading = false;
  bool _emailEnviado = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() => _isLoading = true);

    await _authController.sendPasswordResetEmail(
      email: _emailController.text,
      onComplete: (success, error) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        if (success) {
          setState(() => _emailEnviado = true);
        } else if (error != null && error.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      },
    );
  }

  Widget _iconeValidacao() {
    return AnimatedBuilder(
      animation: _emailController,
      builder: (context, _) {
        if (_emailController.text.isEmpty) return const SizedBox.shrink();
        final erro = AppValidators.email(_emailController.text);
        return Icon(
          erro == null ? Icons.check_circle : Icons.error,
          color: erro == null ? Colors.green : Colors.red,
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
      appBar: AppBar(
        backgroundColor: AppColors.lightCreamBg,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.brown),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 20 : 40),
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
            child: _emailEnviado ? _buildSucesso(isMobile) : _buildFormulario(isMobile),
          ),
        ),
      ),
    );
  }

  Widget _buildFormulario(bool isMobile) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_reset, color: AppColors.pinkStrong, size: 56),
          const SizedBox(height: 16),
          Text(
            'Recuperar Senha',
            style: TextStyle(color: AppColors.brown, fontSize: isMobile ? 22 : 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Insira o seu email e enviaremos um link para redefinir a sua senha.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey, fontSize: 14),
          ),
          const SizedBox(height: 28),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email, color: AppColors.grey),
              suffixIcon: _iconeValidacao(),
              filled: true,
              fillColor: AppColors.lightCreamBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            validator: AppValidators.email,
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: ResponsiveHelper.buttonHeight(context),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _enviar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkStrong,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Text('Enviar link de recuperação', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),

          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Voltar ao login', style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSucesso(bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_outlined, color: Colors.green, size: 36),
        ),
        const SizedBox(height: 20),
        Text(
          'Email enviado!',
          style: TextStyle(color: AppColors.brown, fontSize: isMobile ? 22 : 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Enviámos um link de recuperação para ${_emailController.text.trim()}. Siga as instruções no email para definir uma nova senha.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 8),
        Text(
          'Se não encontrar a mensagem, verifique também a pasta de spam ou lixo eletrónico.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.grey, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: ResponsiveHelper.buttonHeight(context),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinkStrong,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Voltar ao login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}