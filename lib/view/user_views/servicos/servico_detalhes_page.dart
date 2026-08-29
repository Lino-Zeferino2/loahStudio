import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/servico_model.dart';

class ServicoDetalhesPage extends StatelessWidget {
  final Servico servico;
  final bool isSelected;
  final VoidCallback onSelecionar;

  const ServicoDetalhesPage({
    super.key,
    required this.servico,
    required this.isSelected,
    required this.onSelecionar,
  });

  String get _duracaoTexto {
    final d = servico.duracaoMinutos;
    if (d >= 60) {
      final h = d ~/ 60;
      final m = d % 60;
      return m == 0 ? '${h}h' : '${h}h${m.toString().padLeft(2, '0')}';
    }
    return '${d}min';
  }

  Widget _imagem() {
    if (servico.imagemUrl != null && servico.imagemUrl!.isNotEmpty) {
      return Image.network(
        servico.imagemUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        color: AppColors.pinkNude.withValues(alpha: 0.3),
        child: Center(child: Icon(Icons.content_cut, color: AppColors.pinkStrong, size: 64)),
      );

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final precoTexto = '€${servico.preco.toStringAsFixed(0)}';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem grande + botão de voltar sobreposto
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                    child: SizedBox(width: double.infinity, height: isMobile ? 260 : 380, child: _imagem()),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF5A4A42)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(isMobile ? 20 : 60, 24, isMobile ? 20 : 60, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            servico.nome,
                            style: TextStyle(fontSize: isMobile ? 22 : 28, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(precoTexto, style: TextStyle(fontSize: isMobile ? 22 : 26, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.access_time, size: 16, color: Color(0xFF5A4A42)),
                          const SizedBox(width: 6),
                          Text(_duracaoTexto, style: const TextStyle(fontSize: 14, color: Color(0xFF5A4A42))),
                        ]),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFF5A4A42), borderRadius: BorderRadius.circular(20)),
                        child: Text(servico.categoria, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                      ),
                    ]),
                    const SizedBox(height: 26),
                    Text("Sobre este serviço", style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold, color: const Color(0xFF5A4A42))),
                    const SizedBox(height: 10),
                    Text(
                      servico.descricao.isNotEmpty ? servico.descricao : 'Sem descrição disponível para este serviço.',
                      style: const TextStyle(fontSize: 15, color: Color(0xFF7A6A62), height: 1.6),
                    ),
                    const SizedBox(height: 90), // espaço para o botão fixo não tapar o texto
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4))],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.red : AppColors.pinkStrong,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: onSelecionar,
              child: Text(
                isSelected ? "Serviço selecionado ✓" : "Selecionar este serviço",
                style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}