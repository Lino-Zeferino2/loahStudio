import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';

class AdminProdutosPage extends StatefulWidget {
  const AdminProdutosPage({super.key});

  @override
  State<AdminProdutosPage> createState() => _AdminProdutosPageState();
}

class _AdminProdutosPageState extends State<AdminProdutosPage> {
  String _selectedFilter = 'todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _produtos = [
    {'id': 1, 'nome': 'Batom Rouge', 'descricao': 'Batom vermelho matte de longa duração', 'categoria': 'Batom', 'preco': 45.00, 'estoque': 30, 'estoqueMinimo': 5, 'imagem': '💄', 'disponivel': true, 'dataCadastro': DateTime(2024, 1, 10)},
    {'id': 2, 'nome': 'Gloss Brilho', 'descricao': 'Gloss labial com brilho', 'categoria': 'Gloss', 'preco': 35.00, 'estoque': 20, 'estoqueMinimo': 5, 'imagem': '💋', 'disponivel': true, 'dataCadastro': DateTime(2024, 2, 15)},
    {'id': 3, 'nome': 'Paleta Sombra', 'descricao': 'Paleta de sombras 12 cores', 'categoria': 'Olhos', 'preco': 120.00, 'estoque': 12, 'estoqueMinimo': 3, 'imagem': '👁️', 'disponivel': true, 'dataCadastro': DateTime(2024, 3, 20)},
    {'id': 4, 'nome': 'Primer Facial', 'descricao': 'Primer base para maquiagem', 'categoria': 'Base', 'preco': 75.00, 'estoque': 18, 'estoqueMinimo': 3, 'imagem': '✨', 'disponivel': true, 'dataCadastro': DateTime(2024, 4, 5)},
    {'id': 5, 'nome': 'Delineador', 'descricao': 'Delineador líquido preto', 'categoria': 'Olhos', 'preco': 42.00, 'estoque': 25, 'estoqueMinimo': 5, 'imagem': '🖊️', 'disponivel': true, 'dataCadastro': DateTime(2024, 5, 12)},
    {'id': 6, 'nome': 'Kit Maquiagem', 'descricao': 'Kit completo maquiagem básica', 'categoria': 'Kit', 'preco': 250.00, 'estoque': 8, 'estoqueMinimo': 2, 'imagem': '🎁', 'disponivel': true, 'dataCadastro': DateTime(2024, 6, 1)},
  ];

  List<String> get _categorias { final cats = _produtos.map((p) => p['categoria'] as String).toSet().toList(); cats.sort(); return cats; }
  int get _totalEstoque => _produtos.fold(0, (sum, p) => sum + (p['estoque'] as int));
  double get _valorEstoque => _produtos.fold(0.0, (sum, p) => sum + (p['estoque'] as int) * (p['preco'] as double));

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  List<Map<String, dynamic>> get _filteredProdutos {
    var result = List<Map<String, dynamic>>.from(_produtos);
    if (_selectedFilter != 'todos') result = result.where((p) => p['disponivel'] == (_selectedFilter == 'ativo')).toList();
    if (_searchQuery.isNotEmpty) result = result.where((p) => (p['nome'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) || (p['categoria'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    result.sort((a, b) => (a['nome'] as String).compareTo(b['nome'] as String));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isTablet = ResponsiveHelper.isTablet(context);
    return Column(children: [_buildAppBar(isMobile), if (!isMobile) _buildStatsBar(isTablet), Expanded(child: _filteredProdutos.isEmpty ? _buildEmptyState() : _buildProdutosList(isMobile, isTablet))]);
  }

  Widget _buildAppBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(children: [
        TextField(controller: _searchController, onChanged: (value) => setState(() => _searchQuery = value), decoration: InputDecoration(hintText: 'Pesquisar produto, categoria...', prefixIcon: const Icon(Icons.search, color: AppColors.grey), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: AppColors.grey), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null, filled: true, fillColor: AppColors.lightCreamBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14))),
        SizedBox(height: isMobile ? 12 : 16),
        Row(children: [Expanded(child: isMobile ? _buildFiltroDropdown() : Wrap(spacing: 8, runSpacing: 8, children: [_buildFilterChip('todos', 'Todos'), _buildFilterChip('ativo', 'Disponíveis'), _buildFilterChip('inativo', 'Indisponíveis')])), const SizedBox(width: 12), ElevatedButton.icon(onPressed: () => _showAdicionarDialog(), icon: const Icon(Icons.add, size: 18), label: const Text('Novo Produto'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, foregroundColor: AppColors.white))]),
      ]),
    );
  }

  Widget _buildFiltroDropdown() => Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.grey.withValues(alpha: 0.3))), child: DropdownButton<String>(value: _selectedFilter, isExpanded: true, underline: const SizedBox(), icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey), style: TextStyle(color: _selectedFilter == 'todos' ? AppColors.grey : AppColors.brown, fontSize: 14), items: const [DropdownMenuItem(value: 'todos', child: Text('Todos')), DropdownMenuItem(value: 'ativo', child: Text('Disponíveis')), DropdownMenuItem(value: 'inativo', child: Text('Indisponíveis'))], onChanged: (value) { if (value != null) setState(() => _selectedFilter = value); }));

  Widget _buildFilterChip(String value, String label) {
    final bool isSelected = _selectedFilter == value;
    Color chipColor = value == 'ativo' ? Colors.green : value == 'inativo' ? Colors.red : AppColors.pinkStrong;
    return GestureDetector(onTap: () => setState(() => _selectedFilter = value), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isSelected ? chipColor : AppColors.lightCreamBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? chipColor : AppColors.grey.withValues(alpha: 0.3))), child: Text(label, style: TextStyle(color: isSelected ? AppColors.white : AppColors.brown, fontSize: 13, fontWeight: FontWeight.w500))));
  }

  Widget _buildStatsBar(bool isTablet) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.lightCreamBg, border: Border(bottom: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)))), child: isTablet ? Wrap(spacing: 24, runSpacing: 12, children: [_buildStatItem('Total Produtos', '${_produtos.length}', Icons.inventory_2), _buildStatItem('Em Estoque', '$_totalEstoque', Icons.assignment), _buildStatItem('Valor em Estoque', 'R\$ ${_valorEstoque.toStringAsFixed(2).replaceAll('.', ',')}', Icons.attach_money)]) : Row(children: [Expanded(child: _buildStatItem('Total Produtos', '${_produtos.length}', Icons.inventory_2)), Expanded(child: _buildStatItem('Em Estoque', '$_totalEstoque', Icons.assignment)), Expanded(child: _buildStatItem('Valor em Estoque', 'R\$ ${_valorEstoque.toStringAsFixed(2).replaceAll('.', ',')}', Icons.attach_money))]));

  Widget _buildStatItem(String label, String value, IconData icon) => Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppColors.pinkStrong, size: 20)), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)), Text(value, style: const TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold))])]);

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.grey.withValues(alpha: 0.5)), const SizedBox(height: 16), const Text('Nenhum produto encontrado', style: TextStyle(color: AppColors.grey, fontSize: 16))]));

  Widget _buildProdutosList(bool isMobile, bool isTablet) => GridView.builder(padding: EdgeInsets.all(isMobile ? 12 : 16), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isMobile ? 1 : isTablet ? 2 : 3, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: isMobile ? 1.5 : 1.3), itemCount: _filteredProdutos.length, itemBuilder: (context, index) => _buildProdutoCard(_filteredProdutos[index]));

  Widget _buildProdutoCard(Map<String, dynamic> produto) {
    final bool disponivel = produto['disponivel'] as bool;
    final int estoque = produto['estoque'] as int;
    final int estoqueMinimo = produto['estoqueMinimo'] as int;
    final double preco = produto['preco'] as double;
    final bool estoqueBaixo = estoque <= estoqueMinimo && estoque > 0;
    final bool semEstoque = estoque == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: !disponivel ? Colors.grey.withValues(alpha: 0.1) : semEstoque ? Colors.red.withValues(alpha: 0.05) : estoqueBaixo ? Colors.orange.withValues(alpha: 0.05) : AppColors.white, borderRadius: BorderRadius.circular(12), border: !disponivel ? Border.all(color: Colors.grey.withValues(alpha: 0.3)) : semEstoque ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2) : estoqueBaixo ? Border.all(color: Colors.orange.withValues(alpha: 0.3)) : null, boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8)), child: Center(child: Text(produto['imagem'] as String, style: const TextStyle(fontSize: 24)))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(produto['nome'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis), Text(produto['categoria'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 12))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: disponivel ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(disponivel ? 'DISPONÍVEL' : 'INDISPONÍVEL', style: TextStyle(color: disponivel ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 8),
        Expanded(child: Text(produto['descricao'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis)),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: Text('R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppColors.pinkStrong, fontSize: 18, fontWeight: FontWeight.bold))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: semEstoque ? Colors.red.withValues(alpha: 0.2) : estoqueBaixo ? Colors.orange.withValues(alpha: 0.2) : AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(semEstoque ? Icons.error : estoqueBaixo ? Icons.warning : Icons.inventory, color: semEstoque ? Colors.red : estoqueBaixo ? Colors.orange : AppColors.grey, size: 14), const SizedBox(width: 4), Text('$estoque uni', style: TextStyle(color: semEstoque ? Colors.red : estoqueBaixo ? Colors.orange : AppColors.brown, fontSize: 12, fontWeight: FontWeight.w500))]))]),
        const SizedBox(height: 8),
        Row(children: [Transform.scale(scale: 0.8, child: Switch(value: disponivel, onChanged: (v) => _toggleDisponibilidade(produto, v), activeColor: Colors.green, inactiveThumbColor: Colors.red)), const Spacer(), IconButton(onPressed: () => _showEditarDialog(produto), icon: const Icon(Icons.edit, size: 18), color: AppColors.pinkStrong, padding: EdgeInsets.zero, constraints: const BoxConstraints()), IconButton(onPressed: () => _showExcluirDialog(produto), icon: const Icon(Icons.delete, size: 18), color: Colors.red, padding: EdgeInsets.zero, constraints: const BoxConstraints())]),
      ]),
    );
  }

  void _toggleDisponibilidade(Map<String, dynamic> produto, bool disponivel) {
    setState(() { final index = _produtos.indexWhere((p) => p['id'] == produto['id']); if (index != -1) _produtos[index]['disponivel'] = disponivel; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${produto['nome']} agora está ${disponivel ? "disponível" : "indisponível"}!'), backgroundColor: disponivel ? Colors.green : Colors.red));
  }

  void _showAdicionarDialog() {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();
    final precoController = TextEditingController();
    final estoqueController = TextEditingController();
    final imagemController = TextEditingController();
    String categoriaSelecionada = _categorias.isNotEmpty ? _categorias.first : 'Batom';

    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Row(children: [Icon(Icons.add_box, color: AppColors.pinkStrong), SizedBox(width: 8), Text('Novo Produto')]),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: imagemController, decoration: InputDecoration(labelText: 'Imagem (emoji opcional)', hintText: 'Ex: 💄💋👁️ ou Leave vazio para padrão', prefixIcon: const Icon(Icons.image, color: AppColors.grey), border: const OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Produto', border: OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: descricaoController, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()), maxLines: 2), const SizedBox(height: 12), DropdownButtonFormField<String>(value: categoriaSelecionada, decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()), items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (value) { if (value != null) categoriaSelecionada = value; }), const SizedBox(height: 12), Row(children: [Expanded(child: TextField(controller: precoController, decoration: const InputDecoration(labelText: 'Preço', prefixText: 'R\$ ', border: OutlineInputBorder()), keyboardType: TextInputType.number)), const SizedBox(width: 12), Expanded(child: TextField(controller: estoqueController, decoration: const InputDecoration(labelText: 'Estoque', border: OutlineInputBorder()), keyboardType: TextInputType.number))])])),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produto "${nomeController.text}" adicionado!'))); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, foregroundColor: AppColors.white), child: const Text('Adicionar'))],
    ));
  }

  void _showEditarDialog(Map<String, dynamic> produto) => showDialog(context: context, builder: (context) => AlertDialog(title: const Row(children: [Icon(Icons.edit, color: AppColors.pinkStrong), SizedBox(width: 8), Text('Editar Produto')]), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Nome: ${produto['nome']}'), Text('Categoria: ${produto['categoria']}'), Text('Preço: R\$ ${(produto['preco'] as double).toStringAsFixed(2).replaceAll('.', ',')}'), Text('Estoque: ${produto['estoque']}'), const SizedBox(height: 16), const Text('Funcionalidade em desenvolvimento...')]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]));

  void _showExcluirDialog(Map<String, dynamic> produto) => showDialog(context: context, builder: (context) => AlertDialog(title: const Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Excluir Produto')]), content: Text('Tem certeza que deseja excluir ${produto['nome']}?'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${produto['nome']} foi excluído!'), backgroundColor: Colors.red)); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: AppColors.white), child: const Text('Excluir'))]));
}