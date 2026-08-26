import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';

class ConfigGaleriaImagensField extends StatelessWidget {
  final List<String> imagens;
  final bool isUploading;
  final VoidCallback onAdicionarPressed;
  final ValueChanged<String> onRemoverImagem;

  const ConfigGaleriaImagensField({
    super.key,
    required this.imagens,
    required this.isUploading,
    required this.onAdicionarPressed,
    required this.onRemoverImagem,
  });

  Future<void> _confirmarRemocao(BuildContext context, String url) async {
    final confirmar = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 36),
              const SizedBox(height: 12),
              Text(
                'Remover esta imagem da galeria?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.brown),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: Text('Cancelar', style: TextStyle(color: AppColors.brown)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Remover', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmar == true) {
      onRemoverImagem(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Imagens da galeria',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.brown, fontSize: 14)),
        SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final largura = constraints.maxWidth;
            final colunas = largura < 400
                ? 2
                : largura < 700
                    ? 3
                    : 4;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: imagens.length + 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: colunas,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                if (index == imagens.length) {
                  return _buildAdicionarTile();
                }
                return _buildImagemTile(context, imagens[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdicionarTile() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: isUploading
          ? Center(child: CircularProgressIndicator(color: AppColors.pinkStrong))
          : InkWell(
              onTap: onAdicionarPressed,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: AppColors.pinkStrong, size: 30),
                  SizedBox(height: 6),
                  Text('Adicionar',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.pinkStrong, fontSize: 12)),
                ],
              ),
            ),
    );
  }

  Widget _buildImagemTile(BuildContext context, String url) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                  child: CircularProgressIndicator(
                      color: AppColors.pinkStrong, strokeWidth: 2));
            },
            errorBuilder: (context, error, stack) => Center(
              child: Icon(Icons.broken_image, color: AppColors.grey, size: 28),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: Material(
              color: Colors.black.withValues(alpha: 0.55),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => _confirmarRemocao(context, url),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}