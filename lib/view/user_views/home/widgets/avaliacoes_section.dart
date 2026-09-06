import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/avaliacao_model.dart';
import 'package:loahstudio/view/auth/auth_page.dart';

class AvaliacoesSection extends StatelessWidget {
  final List<Avaliacao> avaliacoes;
  final bool isLoading;
  final bool isSubmitting;
  final Future<bool> Function({required String nome, required String mensagem, required int nota}) onEnviarAvaliacao;

  const AvaliacoesSection({
    super.key,
    required this.avaliacoes,
    required this.isLoading,
    required this.isSubmitting,
    required this.onEnviarAvaliacao,
  });

  Future<void> _abrirFormulario(BuildContext context) async {
    final nomeCtrl = TextEditingController();
    final mensagemCtrl = TextEditingController();
    int notaSelecionada = 5;

    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    Text('Deixe a sua avaliação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brown)),
                    SizedBox(height: 16),
                    TextField(
                      controller: nomeCtrl,
                      decoration: InputDecoration(labelText: 'O seu nome', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.pinkStrong))),
                    ),
                    SizedBox(height: 12),
                    Text('A sua nota', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                    SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        final preenchida = index < notaSelecionada;
                        return IconButton(
                          onPressed: () => setModalState(() => notaSelecionada = index + 1),
                          icon: Icon(preenchida ? Icons.star : Icons.star_border, color: Color(0xFFFFB800), size: 30),
                        );
                      }),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: mensagemCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(labelText: 'O seu comentário', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.pinkStrong))),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                            child: Text('Cancelar', style: TextStyle(color: AppColors.brown)),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (nomeCtrl.text.trim().isEmpty || mensagemCtrl.text.trim().isEmpty) return;
                                    final sucesso = await onEnviarAvaliacao(nome: nomeCtrl.text.trim(), mensagem: mensagemCtrl.text.trim(), nota: notaSelecionada);
                                    if (ctx.mounted) Navigator.pop(ctx, sucesso);
                                  },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            child: Text('Enviar', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (resultado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Obrigado! A tua avaliação foi recebida e ficará visível assim que for aprovada.'), backgroundColor: AppColors.pinkStrong),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: isMobile ? 40 : 60),
      color: AppColors.lightCreamBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('O que dizem os nossos clientes', style: TextStyle(fontSize: isMobile ? 22 : 32, fontWeight: FontWeight.bold, color: AppColors.brown)),
          SizedBox(height: 8),
          Text('Depoimentos de quem já confiou no nosso trabalho.', style: TextStyle(fontSize: isMobile ? 13 : 16, color: AppColors.grey)),
          SizedBox(height: isMobile ? 20 : 24),
          if (isLoading)
            SizedBox(height: 220, child: Center(child: CircularProgressIndicator(color: AppColors.pinkStrong)))
          else if (avaliacoes.isEmpty)
            _buildEmptyState()
          else
            SizedBox(
              height: isMobile ? 220 : 240,
              child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: avaliacoes.length, itemBuilder: (context, index) => _avaliacaoCard(avaliacoes[index], isMobile)),
            ),
          SizedBox(height: isMobile ? 20 : 24),
          Center(child: _buildBotaoAvaliar(context, isMobile)),
        ],
      ),
    );
  }

  /// Ouve o estado de auth em tempo real: se o utilizador fizer login numa
  /// aba, ou já estava logado ao carregar a página, o botão reage sem
  /// precisar de refresh manual.
  Widget _buildBotaoAvaliar(BuildContext context, bool isMobile) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final logado = snapshot.data != null;

        if (!logado) {
          return Column(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.grey.withValues(alpha: 0.3),
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 30, vertical: isMobile ? 14 : 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage())),
                icon: Icon(Icons.lock_outline, color: AppColors.grey, size: isMobile ? 16 : 18),
                label: Text('Inicia sessão para avaliar', style: TextStyle(fontSize: isMobile ? 14 : 16, color: AppColors.grey)),
              ),
            ],
          );
        }

        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 30, vertical: isMobile ? 14 : 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 4),
          onPressed: () => _abrirFormulario(context),
          icon: Icon(Icons.rate_review_outlined, color: Colors.white, size: isMobile ? 16 : 18),
          label: Text('Deixar a minha avaliação', style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.white)),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey.withValues(alpha: 0.2))),
      child: Column(
        children: [
          Icon(Icons.format_quote, color: AppColors.grey.withValues(alpha: 0.5), size: 40),
          SizedBox(height: 12),
          Text('Ainda não há avaliações. Seja a primeira pessoa a partilhar a sua experiência!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _avaliacaoCard(Avaliacao avaliacao, bool isMobile) {
    return Container(
      width: isMobile ? 260 : 340,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      margin: EdgeInsets.only(right: isMobile ? 12 : 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(isMobile ? 16 : 20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: isMobile ? 15 : 20, offset: Offset(0, isMobile ? 6 : 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: Color(0xFFC87F6A), size: isMobile ? 24 : 32),
              Spacer(),
              Row(children: List.generate(5, (i) => Icon(i < avaliacao.nota ? Icons.star : Icons.star_border, color: Color(0xFFFFB800), size: isMobile ? 14 : 18))),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Expanded(
            child: Text(avaliacao.mensagem, style: TextStyle(fontSize: isMobile ? 13 : 15, color: AppColors.brown, height: 1.5, fontStyle: FontStyle.italic), maxLines: isMobile ? 3 : 4, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Container(height: 1, color: AppColors.grey.withValues(alpha: 0.15)),
          SizedBox(height: isMobile ? 12 : 16),
          Text(avaliacao.nomeCliente, style: TextStyle(fontSize: isMobile ? 13 : 15, fontWeight: FontWeight.w600, color: AppColors.brown)),
        ],
      ),
    );
  }
}