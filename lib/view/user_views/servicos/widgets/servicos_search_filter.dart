import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';

class ServicosSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<String> categorias;
  final String categoriaSelecionada;
  final ValueChanged<String> onCategoriaChanged;
  final bool isMobile;

  const ServicosSearchFilter({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.categorias,
    required this.categoriaSelecionada,
    required this.onCategoriaChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Pesquisar serviço...',
            hintStyle: const TextStyle(color: Color(0xFF7A6A62)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF7A6A62)),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF7A6A62)),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF7F4F2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
          ),
        ),
        if (categorias.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip('Todas', 'todas'),
                ...categorias.map((c) => _chip(c, c)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _chip(String label, String valor) {
    final isSelected = categoriaSelecionada == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onCategoriaChanged(valor),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: isSelected ? AppColors.pinkStrong : const Color(0xFFF7F4F2), borderRadius: BorderRadius.circular(20)),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF5A4A42))),
        ),
      ),
    );
  }
}