import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/servico_model.dart';

class ServicoCard extends StatelessWidget {
  final Servico servico;
  final bool isSelected;
  final bool isMobile;
  final VoidCallback onTap; // toque no card inteiro -> abre a tela de detalhes
  final VoidCallback onSelecionar; // toque no botão -> seleciona direto na lista

  const ServicoCard({
    super.key,
    required this.servico,
    required this.isSelected,
    required this.isMobile,
    required this.onTap,
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
      return Image.network(servico.imagemUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder());
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        color: AppColors.pinkNude.withValues(alpha: 0.3),
        child: Center(child: Icon(Icons.content_cut, color: AppColors.pinkStrong, size: 32)),
      );

  @override
  Widget build(BuildContext context) {
    final precoTexto = '€${servico.preco.toStringAsFixed(0)}';

    if (isMobile) {
      // IMPORTANTE: este card vive dentro de um GridView com mainAxisExtent
      // fixo (ver servicos_page.dart). Por isso NÃO pode ter margin própria
      // (o espaçamento entre cards já é feito pelo mainAxisSpacing/
      // crossAxisSpacing do GridView) e a imagem usa Expanded em vez de
      // altura fixa, para o card se adaptar à altura real disponível e
      // nunca estourar (RenderFlex overflow).
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: AppColors.pinkStrong, width: 2) : null,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _imagem(),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
                          child: const Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      servico.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42), height: 1.2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(precoTexto, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
                ],
              ),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(12)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.access_time, size: 11, color: Color(0xFF5A4A42)),
                    const SizedBox(width: 4),
                    Text(_duracaoTexto, style: const TextStyle(fontSize: 10, color: Color(0xFF5A4A42))),
                  ]),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(servico.categoria, style: const TextStyle(fontSize: 10, color: Color(0xFF7A6A62)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.red : Colors.white,
                    foregroundColor: isSelected ? Colors.white : AppColors.pinkStrong,
                    side: BorderSide(color: isSelected ? Colors.red : AppColors.pinkStrong, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: onSelecionar,
                  child: Text(isSelected ? "Selecionado" : "Selecionar", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: AppColors.pinkStrong, width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(16), child: SizedBox(width: 180, height: 180, child: _imagem())),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(servico.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42)))),
                      Text(precoTexto, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.pinkStrong)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(servico.descricao, style: const TextStyle(fontSize: 15, color: Color(0xFF7A6A62), height: 1.5)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [const Icon(Icons.access_time, size: 16, color: Color(0xFF5A4A42)), const SizedBox(width: 6), Text(_duracaoTexto, style: const TextStyle(fontSize: 14, color: Color(0xFF5A4A42)))]),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF5A4A42), borderRadius: BorderRadius.circular(20)),
                      child: Text(servico.categoria, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.red : Colors.white,
                      foregroundColor: isSelected ? Colors.white : AppColors.pinkStrong,
                      side: BorderSide(color: isSelected ? Colors.red : AppColors.pinkStrong, width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: onSelecionar,
                    child: Text(isSelected ? "Selecionado" : "Selecionar", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}