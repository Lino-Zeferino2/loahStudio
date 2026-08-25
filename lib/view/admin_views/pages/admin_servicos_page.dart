import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/servicos_controller.dart';
import 'package:loahstudio/model/servico_model.dart';
import 'package:loahstudio/view/admin_views/widgets/servico_form_dialog.dart';

class AdminServicosPage extends StatefulWidget {
  const AdminServicosPage({super.key});

  @override
  State<AdminServicosPage> createState() => _AdminServicosPageState();
}

class _AdminServicosPageState extends State<AdminServicosPage> {
  final ServicosController _controller = ServicosController();
  String _selectedFilter = 'todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Servico> _applyFilters(List<Servico> servicos) {
    var result = List<Servico>.from(servicos);
    if (_selectedFilter != 'todos') {
      result = result.where((s) => s.disponivel == (_selectedFilter == 'ativo')).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((s) => s.nome.toLowerCase().contains(q) || s.categoria.toLowerCase().contains(q))
          .toList();
    }
    result.sort((a, b) => b.totalVendas.compareTo(a.totalVendas));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isTablet = ResponsiveHelper.isTablet(context);

    return StreamBuilder<List<Servico>>(
      stream: _controller.streamServicos(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar serviços: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final todosServicos = snapshot.data!;
        final filtrados = _applyFilters(todosServicos);
        final categorias = todosServicos.map((s) => s.categoria).where((c) => c.isNotEmpty).toSet().toList()..sort();
        final totalVendas = todosServicos.fold(0, (sum, s) => sum + s.totalVendas);
        final receita = todosServicos.fold(0.0, (sum, s) => sum + (s.totalVendas * s.preco));

        return Column(children: [
          _buildAppBar(isMobile, categorias),
          if (!isMobile) _buildStatsBar(isTablet, todosServicos.length, totalVendas, receita),
          Expanded(
            child: filtrados.isEmpty
                ? _buildEmptyState()
                : _buildServicosList(filtrados, isMobile, isTablet),
          ),
        ]);
      },
    );
  }

  Widget _buildAppBar(bool isMobile, List<String> categorias) => Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(color: AppColors.white, boxShadow: [
          BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
        ]),
        child: Column(children: [
          TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                  hintText: 'Pesquisar serviço, categoria...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          })
                      : null,
                  filled: true,
                  fillColor: AppColors.lightCreamBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14))),
          SizedBox(height: isMobile ? 12 : 16),
          Row(children: [
            Expanded(
                child: isMobile
                    ? _buildFiltroDropdown()
                    : Wrap(spacing: 8, runSpacing: 8, children: [
                        _buildFilterChip('todos', 'Todos'),
                        _buildFilterChip('ativo', 'Disponíveis'),
                        _buildFilterChip('inativo', 'Indisponíveis')
                      ])),
            const SizedBox(width: 12),
            ElevatedButton.icon(
                onPressed: () => showServicoFormDialog(context, categoriasExistentes: categorias),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Novo Serviço'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, foregroundColor: AppColors.white))
          ]),
        ]),
      );

  Widget _buildFiltroDropdown() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: AppColors.lightCreamBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.3))),
      child: DropdownButton<String>(
          value: _selectedFilter,
          isExpanded: true,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
          style: TextStyle(color: _selectedFilter == 'todos' ? AppColors.grey : AppColors.brown, fontSize: 14),
          items: const [
            DropdownMenuItem(value: 'todos', child: Text('Todos')),
            DropdownMenuItem(value: 'ativo', child: Text('Disponíveis')),
            DropdownMenuItem(value: 'inativo', child: Text('Indisponíveis'))
          ],
          onChanged: (value) {
            if (value != null) setState(() => _selectedFilter = value);
          }));

  Widget _buildFilterChip(String value, String label) {
    final bool isSelected = _selectedFilter == value;
    Color chipColor = value == 'ativo' ? Colors.green : value == 'inativo' ? Colors.red : AppColors.pinkStrong;
    return GestureDetector(
        onTap: () => setState(() => _selectedFilter = value),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: isSelected ? chipColor : AppColors.lightCreamBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? chipColor : AppColors.grey.withValues(alpha: 0.3))),
            child: Text(label,
                style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.brown, fontSize: 13, fontWeight: FontWeight.w500))));
  }

  Widget _buildStatsBar(bool isTablet, int totalServicos, int totalVendas, double receita) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.lightCreamBg, border: Border(bottom: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)))),
        child: isTablet
            ? Wrap(spacing: 24, runSpacing: 12, children: [
                _buildStatItem('Total Serviços', '$totalServicos', Icons.content_cut),
                _buildStatItem('Total Vendas', '$totalVendas', Icons.trending_up),
                _buildStatItem('Receita', '€ ${receita.toStringAsFixed(0)}', Icons.euro),
              ])
            : Row(children: [
                Expanded(child: _buildStatItem('Total Serviços', '$totalServicos', Icons.content_cut)),
                Expanded(child: _buildStatItem('Total Vendas', '$totalVendas', Icons.trending_up)),
                Expanded(child: _buildStatItem('Receita', '€ ${receita.toStringAsFixed(0)}', Icons.euro)),
              ]),
      );

  Widget _buildStatItem(String label, String value, IconData icon) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.pinkStrong, size: 20)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
          Text(value, style: const TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold))
        ])
      ]);

  Widget _buildEmptyState() => Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.content_cut, size: 64, color: AppColors.grey.withValues(alpha: 0.5)),
        const SizedBox(height: 16),
        const Text('Nenhum serviço encontrado', style: TextStyle(color: AppColors.grey, fontSize: 16))
      ]));

Widget _buildServicosList(List<Servico> servicos, bool isMobile, bool isTablet) => GridView.builder(
    padding: EdgeInsets.all(isMobile ? 12 : 16),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : isTablet ? 2 : 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: isMobile ? 340 : 360),
    itemCount: servicos.length,
    itemBuilder: (context, index) => _buildServicoCard(servicos[index]));
  Widget _buildServicoCard(Servico servico) {
    return Container(
      decoration: BoxDecoration(
          color: !servico.disponivel ? Colors.grey.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: !servico.disponivel ? Border.all(color: Colors.grey.withValues(alpha: 0.3)) : null,
          boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Container(
              height: 130,
              width: double.infinity,
              child: servico.imagemUrl != null && servico.imagemUrl!.isNotEmpty
                  ? Image.network(servico.imagemUrl!, fit: BoxFit.cover, width: double.infinity,
                      errorBuilder: (_, __, ___) => _buildImagemPlaceholder())
                  : _buildImagemPlaceholder(),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text(servico.nome,
                          style: const TextStyle(color: AppColors.brown, fontSize: 15, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: servico.disponivel ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(servico.disponivel ? 'DISPONÍVEL' : 'INDISPONÍVEL',
                          style: TextStyle(
                              color: servico.disponivel ? Colors.green : Colors.red,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)))
                ]),
                Text(servico.categoria, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                Text(servico.descricao,
                    style: const TextStyle(color: AppColors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: Text('€ ${servico.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(color: AppColors.pinkStrong, fontSize: 16, fontWeight: FontWeight.bold))),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.access_time, color: AppColors.grey, size: 14),
                        const SizedBox(width: 4),
                        Text('${servico.duracaoMinutos} min',
                            style: const TextStyle(color: AppColors.brown, fontSize: 12, fontWeight: FontWeight.w500))
                      ]))
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(servico.notaMedia.toStringAsFixed(1),
                      style: const TextStyle(color: AppColors.brown, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  const Icon(Icons.trending_up, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text('${servico.totalVendas} vendas',
                      style: const TextStyle(color: AppColors.brown, fontSize: 12, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Transform.scale(
                      scale: 0.8,
                      child: Switch(
                          value: servico.disponivel,
                          onChanged: (v) => _controller.toggleDisponibilidade(servico.id!, v),
                          activeThumbColor: Colors.green)),
                  IconButton(
                      onPressed: () => showServicoFormDialog(context,
                          servico: servico,
                          categoriasExistentes: [servico.categoria]),
                      icon: const Icon(Icons.edit, size: 18),
                      color: AppColors.pinkStrong,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints())
                ]),
              ],
            ),
          ),
     ), ],),
      
    );
  }

  Widget _buildImagemPlaceholder() => Container(
      color: AppColors.pinkNude.withValues(alpha: 0.3),
      child: const Center(child: Icon(Icons.content_cut, size: 32, color: AppColors.pinkStrong)));
}