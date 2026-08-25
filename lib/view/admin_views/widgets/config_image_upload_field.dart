import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';

class ConfigImageUploadField extends StatelessWidget {
  final String label;
  final String? imagemUrl;
  final bool isUploading;
  final VoidCallback onUploadPressed;

  const ConfigImageUploadField({
    super.key,
    required this.label,
    required this.imagemUrl,
    required this.isUploading,
    required this.onUploadPressed,
  });

  @override
  Widget build(BuildContext context) {
    final temImagem = imagemUrl != null && imagemUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.brown,
                fontSize: 14)),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: temImagem
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imagemUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                              color: AppColors.pinkStrong),
                        );
                      },
                      errorBuilder: (context, error, stack) => Center(
                        child: Icon(Icons.broken_image,
                            color: AppColors.grey, size: 40),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: _buildTrocarButton(),
                    ),
                  ],
                )
              : Center(
                  child: isUploading
                      ? CircularProgressIndicator(color: AppColors.pinkStrong)
                      : InkWell(
                          onTap: onUploadPressed,
                          borderRadius: BorderRadius.circular(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: AppColors.pinkStrong, size: 36),
                              SizedBox(height: 8),
                              Text('Carregar imagem',
                                  style: TextStyle(color: AppColors.pinkStrong)),
                            ],
                          ),
                        ),
                ),
        ),
      ],
    );
  }

  Widget _buildTrocarButton() {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: isUploading ? null : onUploadPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: isUploading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Trocar',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
        ),
      ),
    );
  }
}