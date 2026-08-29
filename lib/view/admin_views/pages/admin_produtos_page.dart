import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/produtos_controller.dart';
import 'package:loahstudio/model/produto_model.dart';
import 'package:loahstudio/view/admin_views/widgets/produto_form_dialog.dart';

class AdminProdutosPage extends StatefulWidget {
  const AdminProdutosPage({super.key});

  @override
  State<AdminProdutosPage> createState() => _AdminProdutosPageState();
}

class _AdminProdutosPageState extends State<AdminProdutosPage> {
  final ProdutosController _controller = ProdutosController();
  String _selectedFilter = 'todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Produto> _applyFilters(List<Produto> produtos) {
    var result = List<Produto>.from(produtos);
    if (_selectedFilter != 'todos') {
      result = result.where((p) => p.disponivel == (_selectedFilter == 'ativo')).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((p) => p.nome.toLowerCase().contains(q) || p.categoria.toLowerCase().contains(q))
          .toList();
    }
    result.sort((a, b) => a.nome.compareTo(b.nome));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isTablet = ResponsiveHelper.isTablet(context);

    return StreamBuilder<List<Produto>>(
      stream: _controller.streamProdutos(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar produtos: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final todosProdutos = snapshot.data!;
        final filtrados = _applyFilters(todosProdutos);
        final categorias = todosProdutos.map((p) => p.categoria).where((c) => c.isNotEmpty).toSet().toList()..sort();
        final totalEstoque = todosProdutos.fold(0, (sum, p) => sum + p.estoque);
        final valorEstoque = todosProdutos.fold(0.0, (sum, p) => sum + (p.estoque * p.preco));

        return Column(children: [
          _buildAppBar(isMobile, categorias),
          if (!isMobile) _buildStatsBar(isTablet, todosProdutos.length, totalEstoque, valorEstoque),
          Expanded(
            child: filtrados.isEmpty
                ? _buildEmptyState()
                : _buildProdutosList(filtrados, isMobile, isTablet),
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
                  hintText: 'Pesquisar produto, categoria...',
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
                onPressed: () => showProdutoFormDialog(context, categoriasExistentes: categorias),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Novo Produto'),
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

  Widget _buildStatsBar(bool isTablet, int totalProdutos, int totalEstoque, double valorEstoque) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.lightCreamBg, border: Border(bottom: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)))),
        child: isTablet
            ? Wrap(spacing: 24, runSpacing: 12, children: [
                _buildStatItem('Total Produtos', '$totalProdutos', Icons.inventory_2),
                _buildStatItem('Em Estoque', '$totalEstoque', Icons.assignment),
                _buildStatItem('Valor em Estoque', '€ ${valorEstoque.toStringAsFixed(2).replaceAll('.', ',')}', Icons.euro),
              ])
            : Row(children: [
                Expanded(child: _buildStatItem('Total Produtos', '$totalProdutos', Icons.inventory_2)),
                Expanded(child: _buildStatItem('Em Estoque', '$totalEstoque', Icons.assignment)),
                Expanded(
                    child: _buildStatItem(
                        'Valor em Estoque', '€ ${valorEstoque.toStringAsFixed(2).replaceAll('.', ',')}', Icons.euro)),
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
        Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.grey.withValues(alpha: 0.5)),
        const SizedBox(height: 16),
        const Text('Nenhum produto encontrado', style: TextStyle(color: AppColors.grey, fontSize: 16))
      ]));

  Widget _buildProdutosList(List<Produto> produtos, bool isMobile, bool isTablet) => GridView.builder(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : isTablet ? 2 : 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: isMobile ? 340 : 360),
      itemCount: produtos.length,
      itemBuilder: (context, index) => _buildProdutoCard(produtos[index]));

  Widget _buildProdutoCard(Produto produto) {
    return Container(
      decoration: BoxDecoration(
          color: !produto.disponivel
              ? Colors.grey.withValues(alpha: 0.1)
              : produto.semEstoque
                  ? Colors.red.withValues(alpha: 0.05)
                  : produto.estoqueBaixo
                      ? Colors.orange.withValues(alpha: 0.05)
                      : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: !produto.disponivel
              ? Border.all(color: Colors.grey.withValues(alpha: 0.3))
              : produto.semEstoque
                  ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2)
                  : produto.estoqueBaixo
                      ? Border.all(color: Colors.orange.withValues(alpha: 0.3))
                      : null,
          boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
  children: [
    SizedBox(
      height: 130,
      width: double.infinity,
      child: produto.imagemUrl != null && produto.imagemUrl!.isNotEmpty
          ? Image.network(produto.imagemUrl!, fit: BoxFit.cover, width: double.infinity,
              errorBuilder: (_, __, ___) => _buildImagemPlaceholder())
          : _buildImagemPlaceholder(),
    ),
    if (produto.destaque)
      Positioned(
        top: 8,
        left: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppColors.pinkStrong, borderRadius: BorderRadius.circular(20)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.star, color: Colors.white, size: 12),
            SizedBox(width: 4),
            Text('DESTAQUE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
  ],
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
                        child: Text(produto.nome,
                            style: const TextStyle(color: AppColors.brown, fontSize: 15, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: produto.disponivel ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(produto.disponivel ? 'DISPONÍVEL' : 'INDISPONÍVEL',
                            style: TextStyle(
                                color: produto.disponivel ? Colors.green : Colors.red,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)))
                  ]),
                  Text(produto.categoria, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(produto.descricao,
                      style: const TextStyle(color: AppColors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: Text('€ ${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(color: AppColors.pinkStrong, fontSize: 16, fontWeight: FontWeight.bold))),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: produto.semEstoque
                                ? Colors.red.withValues(alpha: 0.2)
                                : produto.estoqueBaixo
                                    ? Colors.orange.withValues(alpha: 0.2)
                                    : AppColors.lightCreamBg,
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                              produto.semEstoque
                                  ? Icons.error
                                  : produto.estoqueBaixo
                                      ? Icons.warning
                                      : Icons.inventory,
                              color: produto.semEstoque
                                  ? Colors.red
                                  : produto.estoqueBaixo
                                      ? Colors.orange
                                      : AppColors.grey,
                              size: 14),
                          const SizedBox(width: 4),
                          Text('${produto.estoque} uni',
                              style: TextStyle(
                                  color: produto.semEstoque
                                      ? Colors.red
                                      : produto.estoqueBaixo
                                          ? Colors.orange
                                          : AppColors.brown,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500))
                        ]))
                  ]),
                  const Spacer(),
                  Row(children: [
                    Transform.scale(
                        scale: 0.8,
                        child: Switch(
                            value: produto.disponivel,
                            onChanged: (v) => _controller.toggleDisponibilidade(produto.id!, v),
                            activeThumbColor: Colors.green,
                            inactiveThumbColor: Colors.red)),
                    const Spacer(),
                    IconButton(
                        onPressed: () => showProdutoFormDialog(context,
                            produto: produto, categoriasExistentes: [produto.categoria]),
                        icon: const Icon(Icons.edit, size: 18),
                        color: AppColors.pinkStrong,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints()),
                    IconButton(
                        onPressed: () => _showExcluirDialog(produto),
                        icon: const Icon(Icons.delete, size: 18),
                        color: Colors.red,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints())
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagemPlaceholder() => Container(
      color: AppColors.lightCreamBg,
      child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 32, color: AppColors.pinkStrong)));

  void _showExcluirDialog(Produto produto) => showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
            title: const Row(
                children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Excluir Produto')]),
            content: Text('Tem certeza que deseja excluir ${produto.nome}?\n\nEsta ação não pode ser desfeita.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
              ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    final sucesso = await _controller.deleteProduto(produto.id!);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(sucesso ? '${produto.nome} foi excluído!' : 'Erro ao excluir produto.'),
                        backgroundColor: sucesso ? Colors.red : Colors.grey));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: AppColors.white),
                  child: const Text('Excluir'))
            ],
          ));
}