import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';

class AdminServicosPage extends StatefulWidget {
  const AdminServicosPage({super.key});

  @override
  State<AdminServicosPage> createState() => _AdminServicosPageState();
}

class _AdminServicosPageState extends State<AdminServicosPage> {
  String _selectedFilter = 'todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _servicos = [
    {'id': 1, 'nome': 'Maquilhagem noiva', 'descricao': 'Maquilhagem completa para.noiva com bertahancia', 'categoria': 'Noiva', 'duracao': 90, 'preco': 250.00, 'disponivel': true, 'totalVendas': 45, 'notaMedia': 4.9, 'imagem': '👰‍♀️'},
    {'id': 2, 'nome': 'Maquilhagem Festa', 'descricao': 'Maquilhagem para festas e eventos', 'categoria': 'Festa', 'duracao': 60, 'preco': 150.00, 'disponivel': true, 'totalVendas': 89, 'notaMedia': 4.8, 'imagem': '💃'},
    {'id': 3, 'nome': 'Maquilhagem Editorial', 'descricao': 'Maquilhagem para sessões fotograficas', 'categoria': 'Editorial', 'duracao': 45, 'preco': 200.00, 'disponivel': true, 'totalVendas': 34, 'notaMedia': 4.7, 'imagem': '📸'},
    {'id': 4, 'nome': 'Maquilhagem Casamento', 'descricao': 'Maquilhagem para.noiva e madrinhas', 'categoria': 'Casamento', 'duracao': 120, 'preco': 350.00, 'disponivel': true, 'totalVendas': 28, 'notaMedia': 5.0, 'imagem': '💒'},
    {'id': 5, 'nome': 'Maquilhagem Natural', 'descricao': 'Maquilhagem leve e natural do dia a dia', 'categoria': 'Natural', 'duracao': 30, 'preco': 80.00, 'disponivel': true, 'totalVendas': 112, 'notaMedia': 4.6, 'imagem': '✨'},
    {'id': 6, 'nome': 'Maquilhagem Profissional', 'descricao': 'Maquilhagem para.atrizes e modelos', 'categoria': 'Profissional', 'duracao': 75, 'preco': 300.00, 'disponivel': false, 'totalVendas': 15, 'notaMedia': 4.8, 'imagem': '🎬'},
  ];

  List<String> get _categorias { final cats = _servicos.map((s) => s['categoria'] as String).toSet().toList(); cats.sort(); return cats; }
  int get _totalServicos => _servicos.length;
  int get _totalVendas => _servicos.fold(0, (sum, s) => sum + (s['totalVendas'] as int));
  double get _receitaEstimada => _servicos.fold(0.0, (sum, s) => sum + (s['totalVendas'] as int) * (s['preco'] as double));

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  List<Map<String, dynamic>> get _filteredServicos {
    var result = List<Map<String, dynamic>>.from(_servicos);
    if (_selectedFilter != 'todos') result = result.where((s) => s['disponivel'] == (_selectedFilter == 'ativo')).toList();
    if (_searchQuery.isNotEmpty) result = result.where((s) => (s['nome'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) || (s['categoria'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    result.sort((a, b) => (b['totalVendas'] as int).compareTo(a['totalVendas'] as int));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isTablet = ResponsiveHelper.isTablet(context);
    return Column(children: [_buildAppBar(isMobile), if (!isMobile) _buildStatsBar(isTablet), Expanded(child: _filteredServicos.isEmpty ? _buildEmptyState() : _buildServicosList(isMobile, isTablet))]);
  }

  Widget _buildAppBar(bool isMobile) => Container(
    padding: EdgeInsets.all(isMobile ? 12 : 16),
    decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]),
    child: Column(children: [
      TextField(controller: _searchController, onChanged: (value) => setState(() => _searchQuery = value), decoration: InputDecoration(hintText: 'Pesquisar serviço, categoria...', prefixIcon: const Icon(Icons.search, color: AppColors.grey), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: AppColors.grey), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null, filled: true, fillColor: AppColors.lightCreamBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14))),
      SizedBox(height: isMobile ? 12 : 16),
      Row(children: [Expanded(child: isMobile ? _buildFiltroDropdown() : Wrap(spacing: 8, runSpacing: 8, children: [_buildFilterChip('todos', 'Todos'), _buildFilterChip('ativo', 'Disponíveis'), _buildFilterChip('inativo', 'Indisponíveis')])), const SizedBox(width: 12), ElevatedButton.icon(onPressed: () => _showAdicionarDialog(), icon: const Icon(Icons.add, size: 18), label: const Text('Novo Serviço'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, foregroundColor: AppColors.white))]),
    ]),
  );

  Widget _buildFiltroDropdown() => Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.grey.withValues(alpha: 0.3))), child: DropdownButton<String>(value: _selectedFilter, isExpanded: true, underline: const SizedBox(), icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey), style: TextStyle(color: _selectedFilter == 'todos' ? AppColors.grey : AppColors.brown, fontSize: 14), items: const [DropdownMenuItem(value: 'todos', child: Text('Todos')), DropdownMenuItem(value: 'ativo', child: Text('Disponíveis')), DropdownMenuItem(value: 'inativo', child: Text('Indisponíveis'))], onChanged: (value) { if (value != null) setState(() => _selectedFilter = value); }));

  Widget _buildFilterChip(String value, String label) {
    final bool isSelected = _selectedFilter == value;
    Color chipColor = value == 'ativo' ? Colors.green : value == 'inativo' ? Colors.red : AppColors.pinkStrong;
    return GestureDetector(onTap: () => setState(() => _selectedFilter = value), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isSelected ? chipColor : AppColors.lightCreamBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? chipColor : AppColors.grey.withValues(alpha: 0.3))), child: Text(label, style: TextStyle(color: isSelected ? AppColors.white : AppColors.brown, fontSize: 13, fontWeight: FontWeight.w500))));
  }

  Widget _buildStatsBar(bool isTablet) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.lightCreamBg, border: Border(bottom: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)))),
    child: isTablet ? Wrap(spacing: 24, runSpacing: 12, children: [_buildStatItem('Total Serviços', '$_totalServicos', Icons.content_cut), _buildStatItem('Total Vendas', '$_totalVendas', Icons.trending_up), _buildStatItem('Receita', 'R\$ ${_receitaEstimada.toStringAsFixed(0)}', Icons.attach_money)]) : Row(children: [Expanded(child: _buildStatItem('Total Serviços', '$_totalServicos', Icons.content_cut)), Expanded(child: _buildStatItem('Total Vendas', '$_totalVendas', Icons.trending_up)), Expanded(child: _buildStatItem('Receita', 'R\$ ${_receitaEstimada.toStringAsFixed(0)}', Icons.attach_money))]),
  );

  Widget _buildStatItem(String label, String value, IconData icon) => Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppColors.pinkStrong, size: 20)), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)), Text(value, style: const TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold))])]);

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.content_cut, size: 64, color: AppColors.grey.withValues(alpha: 0.5)), const SizedBox(height: 16), const Text('Nenhum serviço encontrado', style: TextStyle(color: AppColors.grey, fontSize: 16))]));

  Widget _buildServicosList(bool isMobile, bool isTablet) => GridView.builder(padding: EdgeInsets.all(isMobile ? 12 : 16), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isMobile ? 1 : isTablet ? 2 : 3, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: isMobile ? 1.4 : 1.2), itemCount: _filteredServicos.length, itemBuilder: (context, index) => _buildServicoCard(_filteredServicos[index]));

  Widget _buildServicoCard(Map<String, dynamic> servico) {
    final bool disponivel = servico['disponivel'] as bool;
    final int totalVendas = servico['totalVendas'] as int;
    final double preco = servico['preco'] as double;
    final int duracao = servico['duracao'] as int;
    final double notaMedia = servico['notaMedia'] as double;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: !disponivel ? Colors.grey.withValues(alpha: 0.1) : AppColors.white, borderRadius: BorderRadius.circular(12), border: !disponivel ? Border.all(color: Colors.grey.withValues(alpha: 0.3)) : null, boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(servico['imagem'] as String? ?? '💄', style: const TextStyle(fontSize: 24)))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(servico['nome'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis), Text(servico['categoria'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 12))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: disponivel ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(disponivel ? 'DISPONÍVEL' : 'INDISPONÍVEL', style: TextStyle(color: disponivel ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 8),
        Expanded(child: Text(servico['descricao'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis)),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: Text('R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppColors.pinkStrong, fontSize: 18, fontWeight: FontWeight.bold))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.access_time, color: AppColors.grey, size: 14), const SizedBox(width: 4), Text('$duracao min', style: const TextStyle(color: AppColors.brown, fontSize: 12, fontWeight: FontWeight.w500))]))]),
        const SizedBox(height: 8),
        Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), const SizedBox(width: 4), Text(notaMedia.toStringAsFixed(1), style: const TextStyle(color: AppColors.brown, fontSize: 12, fontWeight: FontWeight.w500)), const SizedBox(width: 12), const Icon(Icons.trending_up, color: Colors.green, size: 16), const SizedBox(width: 4), Text('$totalVendas vendas', style: const TextStyle(color: AppColors.brown, fontSize: 12, fontWeight: FontWeight.w500)), const Spacer(), Transform.scale(scale: 0.8, child: Switch(value: disponivel, onChanged: (v) => _toggleDisponibilidade(servico, v), activeColor: Colors.green)), IconButton(onPressed: () => _showEditarDialog(servico), icon: const Icon(Icons.edit, size: 18), color: AppColors.pinkStrong, padding: EdgeInsets.zero, constraints: const BoxConstraints())]),
      ]),
    );
  }

  void _toggleDisponibilidade(Map<String, dynamic> servico, bool disponivel) { setState(() { final index = _servicos.indexWhere((s) => s['id'] == servico['id']); if (index != -1) _servicos[index]['disponivel'] = disponivel; }); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${servico['nome']} ${disponivel ? "disponível" : "indisponível"}!'), backgroundColor: disponivel ? Colors.green : Colors.red)); }

  void _showAdicionarDialog() {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();
    final precoController = TextEditingController();
    final duracaoController = TextEditingController();
    final imagemController = TextEditingController();
    String categoriaSelecionada = _categorias.isNotEmpty ? _categorias.first : 'Noiva';

    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Row(children: [Icon(Icons.add_box, color: AppColors.pinkStrong), SizedBox(width: 8), Text('Novo Serviço')]),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: imagemController, decoration: InputDecoration(labelText: 'Imagem (emoji opcional)', hintText: 'Ex: 👰💃📸 ouLeave vazio para padrão', prefixIcon: const Icon(Icons.image, color: AppColors.grey), border: const OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Serviço', border: OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: descricaoController, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()), maxLines: 2), const SizedBox(height: 12), DropdownButtonFormField<String>(value: categoriaSelecionada, decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()), items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (value) { if (value != null) categoriaSelecionada = value; }), const SizedBox(height: 12), Row(children: [Expanded(child: TextField(controller: precoController, decoration: const InputDecoration(labelText: 'Preço', prefixText: 'R\$ ', border: OutlineInputBorder()), keyboardType: TextInputType.number)), const SizedBox(width: 12), Expanded(child: TextField(controller: duracaoController, decoration: const InputDecoration(labelText: 'Duração', suffixText: 'min', border: OutlineInputBorder()), keyboardType: TextInputType.number))])])),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Serviço "${nomeController.text}" adicionado!'))); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, foregroundColor: AppColors.white), child: const Text('Adicionar'))],
    ));
  }

  void _showEditarDialog(Map<String, dynamic> servico) => showDialog(context: context, builder: (context) => AlertDialog(title: Text('Editar ${servico['nome']}'), content: Text('Preço: R\$ ${(servico['preco'] as double).toStringAsFixed(2).replaceAll('.', ',')}\nVendas: ${servico['totalVendas']}'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]));
}