import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';

class AdminClientesPage extends StatefulWidget {
  const AdminClientesPage({super.key});

  @override
  State<AdminClientesPage> createState() => _AdminClientesPageState();
}

class _AdminClientesPageState extends State<AdminClientesPage> {
  String _selectedFilter = 'todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _clientes = [
    {'id': 1, 'nome': 'Maria Santos', 'email': 'maria@email.com', 'telefone': '(11) 99999-1111', 'endereco': 'Rua das Flores, 123 - São Paulo', 'dataCadastro': DateTime(2024, 1, 15), 'ultimoAgendamento': DateTime(2025, 4, 20), 'ultimaCompra': DateTime(2025, 4, 22), 'totalAgendamentos': 12, 'totalCompras': 8, 'totalGasto': 4250.00, 'status': 'ativo', 'notas': 'Cliente fidelity, prefere atendimento pela manhã', 'avatar': 'M'},
    {'id': 2, 'nome': 'João Silva', 'email': 'joao@email.com', 'telefone': '(11) 99999-2222', 'endereco': 'Av. Paulista, 456 - São Paulo', 'dataCadastro': DateTime(2024, 3, 10), 'ultimoAgendamento': DateTime(2025, 4, 18), 'ultimaCompra': DateTime(2025, 3, 5), 'totalAgendamentos': 5, 'totalCompras': 3, 'totalGasto': 1890.00, 'status': 'ativo', 'notas': '', 'avatar': 'J'},
    {'id': 3, 'nome': 'Ana Costa', 'email': 'ana@email.com', 'telefone': '(11) 99999-3333', 'endereco': 'Rua Augusta, 789 - São Paulo', 'dataCadastro': DateTime(2023, 11, 20), 'ultimoAgendamento': DateTime(2025, 4, 15), 'ultimaCompra': DateTime(2025, 4, 10), 'totalAgendamentos': 20, 'totalCompras': 15, 'totalGasto': 8500.00, 'status': 'ativo', 'notas': '', 'avatar': 'A'},
    {'id': 4, 'nome': 'Pedro Oliveira', 'email': 'pedro@email.com', 'telefone': '(11) 99999-4444', 'endereco': 'Rua Oscar Freire, 321 - São Paulo', 'dataCadastro': DateTime(2024, 6, 5), 'ultimoAgendamento': DateTime(2025, 2, 20), 'ultimaCompra': DateTime(2025, 1, 10), 'totalAgendamentos': 3, 'totalCompras': 2, 'totalGasto': 650.00, 'status': 'bloqueado', 'notas': '', 'avatar': 'P'},
    {'id': 5, 'nome': 'Carla Souza', 'email': 'carla@email.com', 'telefone': '(11) 99999-5555', 'endereco': 'Av. Rebouças, 654 - São Paulo', 'dataCadastro': DateTime(2024, 8, 12), 'ultimoAgendamento': DateTime(2025, 4, 25), 'ultimaCompra': DateTime(2025, 4, 26), 'totalAgendamentos': 8, 'totalCompras': 6, 'totalGasto': 3200.00, 'status': 'ativo', 'notas': 'Sempre pontual', 'avatar': 'C'},
  ];

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  List<Map<String, dynamic>> get _filteredClientes {
    var result = List<Map<String, dynamic>>.from(_clientes);
    if (_selectedFilter != 'todos') result = result.where((c) => c['status'] == _selectedFilter).toList();
    if (_searchQuery.isNotEmpty) result = result.where((c) => (c['nome'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) || (c['email'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) || (c['telefone'] as String).contains(_searchQuery)).toList();
    result.sort((a, b) => (a['nome'] as String).compareTo(b['nome'] as String));
    return result;
  }

  int get _totalClientes => _clientes.length;
  int get _clientesAtivos => _clientes.where((c) => c['status'] == 'ativo').length;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isTablet = ResponsiveHelper.isTablet(context);
    return Column(children: [_buildAppBar(isMobile), if (!isMobile) _buildStatsBar(isTablet), Expanded(child: _filteredClientes.isEmpty ? _buildEmptyState() : _buildClientesList(isMobile, isTablet))]);
  }

  Widget _buildAppBar(bool isMobile) => Container(
    padding: EdgeInsets.all(isMobile ? 12 : 16),
    decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]),
    child: Column(children: [
      TextField(controller: _searchController, onChanged: (value) => setState(() => _searchQuery = value), decoration: InputDecoration(hintText: 'Pesquisar cliente, email, telefone...', prefixIcon: const Icon(Icons.search, color: AppColors.grey), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: AppColors.grey), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null, filled: true, fillColor: AppColors.lightCreamBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14))),
      SizedBox(height: isMobile ? 12 : 16),
      isMobile ? _buildFiltroDropdown() : Wrap(spacing: 8, runSpacing: 8, children: [_buildFilterChip('todos', 'Todos'), _buildFilterChip('ativo', 'Ativos'), _buildFilterChip('inativo', 'Inativos'), _buildFilterChip('bloqueado', 'Bloqueados')]),
    ]),
  );

  Widget _buildFiltroDropdown() => Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.grey.withValues(alpha: 0.3))), child: DropdownButton<String>(value: _selectedFilter, isExpanded: true, underline: const SizedBox(), icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey), style: TextStyle(color: _selectedFilter == 'todos' ? AppColors.grey : AppColors.brown, fontSize: 14), items: const [DropdownMenuItem(value: 'todos', child: Text('Todos os clientes')), DropdownMenuItem(value: 'ativo', child: Text('Ativos')), DropdownMenuItem(value: 'inativo', child: Text('Inativos')), DropdownMenuItem(value: 'bloqueado', child: Text('Bloqueados'))], onChanged: (value) { if (value != null) setState(() => _selectedFilter = value); }));

  Widget _buildFilterChip(String value, String label) {
    final bool isSelected = _selectedFilter == value;
    Color chipColor;
    switch (value) { case 'ativo': chipColor = Colors.green; break; case 'inativo': chipColor = Colors.grey; break; case 'bloqueado': chipColor = Colors.red; break; default: chipColor = AppColors.pinkStrong; }
    return GestureDetector(onTap: () => setState(() => _selectedFilter = value), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isSelected ? chipColor : AppColors.lightCreamBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? chipColor : AppColors.grey.withValues(alpha: 0.3))), child: Text(label, style: TextStyle(color: isSelected ? AppColors.white : AppColors.brown, fontSize: 13, fontWeight: FontWeight.w500))));
  }

  Widget _buildStatsBar(bool isTablet) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.lightCreamBg, border: Border(bottom: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)))), child: isTablet ? Wrap(spacing: 24, runSpacing: 12, children: [_buildStatItem('Total Clientes', '$_totalClientes', Icons.people), _buildStatItem('Ativos', '$_clientesAtivos', Icons.person)]) : Row(children: [Expanded(child: _buildStatItem('Total Clientes', '$_totalClientes', Icons.people)), Expanded(child: _buildStatItem('Ativos', '$_clientesAtivos', Icons.person))]));

  Widget _buildStatItem(String label, String value, IconData icon) => Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppColors.pinkStrong, size: 20)), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)), Text(value, style: const TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold))])]);

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people_outline, size: 64, color: AppColors.grey.withValues(alpha: 0.5)), const SizedBox(height: 16), const Text('Nenhum cliente encontrado', style: TextStyle(color: AppColors.grey, fontSize: 16))]));

  Widget _buildClientesList(bool isMobile, bool isTablet) => ListView.builder(padding: EdgeInsets.all(isMobile ? 12 : 16), itemCount: _filteredClientes.length, itemBuilder: (context, index) => _buildClienteCard(_filteredClientes[index], isMobile, isTablet));

  Widget _buildClienteCard(Map<String, dynamic> cliente, bool isMobile, bool isTablet) {
    final String status = cliente['status'] as String;
    final DateTime ultimoAgendamento = cliente['ultimoAgendamento'] as DateTime;
    final DateTime ultimaCompra = cliente['ultimaCompra'] as DateTime;
    final DateTime dataCadastro = cliente['dataCadastro'] as DateTime;
    final double totalGasto = cliente['totalGasto'] as double;
    final int totalAgendamentos = cliente['totalAgendamentos'] as int;
    final int totalCompras = cliente['totalCompras'] as int;
    final String notas = cliente['notas'] as String;

    Color statusColor;
    switch (status) { case 'ativo': statusColor = Colors.green; break; case 'bloqueado': statusColor = Colors.red; break; default: statusColor = Colors.grey; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: status == 'bloqueado' ? Colors.red.withValues(alpha: 0.05) : AppColors.white, borderRadius: BorderRadius.circular(12), border: status == 'bloqueado' ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2) : null, boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: isMobile ? 50 : 56, height: isMobile ? 50 : 56, decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), shape: BoxShape.circle), child: Center(child: Text(cliente['avatar'] as String, style: const TextStyle(color: AppColors.pinkStrong, fontSize: 20, fontWeight: FontWeight.bold)))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cliente['nome'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 18, fontWeight: FontWeight.bold)), Text(cliente['email'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 13)), Text(cliente['telefone'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 13))])), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Row(children: [const Icon(Icons.location_on, color: AppColors.grey, size: 16), const SizedBox(width: 6), Expanded(child: Text(cliente['endereco'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 13), overflow: TextOverflow.ellipsis))]),
        const SizedBox(height: 12),
        isMobile ? Column(children: [_buildStatRow('Cadastro', '${dataCadastro.day}/${dataCadastro.month}/${dataCadastro.year}'), _buildStatRow('Último Serviço', '${ultimoAgendamento.day}/${ultimoAgendamento.month}/${ultimoAgendamento.year}'), _buildStatRow('Total Serviços', '$totalAgendamentos'), _buildStatRow('Total Compras', '$totalCompras'), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Gasto:', style: TextStyle(color: AppColors.brown, fontSize: 14, fontWeight: FontWeight.bold)), Text('R\$ ${totalGasto.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppColors.pinkStrong, fontSize: 16, fontWeight: FontWeight.bold))]))]) : Wrap(spacing: 16, runSpacing: 8, children: [_buildStatChip('Cadastro', '${dataCadastro.day}/${dataCadastro.month}/${dataCadastro.year}'), _buildStatChip('Últ.Serviço', '${ultimoAgendamento.day}/${ultimoAgendamento.month}/${ultimoAgendamento.year}'), _buildStatChip('Total Serviços', '$totalAgendamentos'), _buildStatChip('Total Compras', '$totalCompras'), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Text('Total: ', style: TextStyle(color: AppColors.brown, fontSize: 14, fontWeight: FontWeight.bold)), Text('R\$ ${totalGasto.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppColors.pinkStrong, fontSize: 16, fontWeight: FontWeight.bold))]))]),
        if (notas.isNotEmpty) ...[const SizedBox(height: 12), Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Notas:', style: TextStyle(color: AppColors.brown, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(notas, style: const TextStyle(color: AppColors.grey, fontSize: 13))]))],
        const SizedBox(height: 12),
        Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [ElevatedButton.icon(onPressed: () => _showDetalhesDialog(cliente), icon: const Icon(Icons.visibility, size: 18), label: const Text('Detalhes'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, foregroundColor: AppColors.white)), TextButton.icon(onPressed: () {}, icon: const Icon(Icons.edit, size: 18), label: const Text('Editar'), style: TextButton.styleFrom(foregroundColor: AppColors.pinkStrong)), TextButton.icon(onPressed: () {}, icon: const Icon(Icons.chat, size: 18), label: const Text('WhatsApp'), style: TextButton.styleFrom(foregroundColor: Colors.green)), if (cliente['status'] == 'ativo') TextButton.icon(onPressed: () => _showBloquearDialog(cliente), icon: const Icon(Icons.block, size: 18), label: const Text('Bloquear'), style: TextButton.styleFrom(foregroundColor: Colors.red)) else if (cliente['status'] == 'bloqueado') TextButton.icon(onPressed: () {}, icon: const Icon(Icons.lock_open, size: 18), label: const Text('Desbloquear'), style: TextButton.styleFrom(foregroundColor: Colors.orange))]),
      ]),
    );
  }

  Widget _buildStatRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('$label:', style: const TextStyle(color: AppColors.grey, fontSize: 13)), Text(value, style: const TextStyle(color: AppColors.brown, fontSize: 13, fontWeight: FontWeight.w500))]));

  Widget _buildStatChip(String label, String value) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8)), child: Column(children: [Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 10)), Text(value, style: const TextStyle(color: AppColors.brown, fontSize: 13, fontWeight: FontWeight.w500))]));

  void _showDetalhesDialog(Map<String, dynamic> cliente) => showDialog(context: context, builder: (context) => AlertDialog(title: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), shape: BoxShape.circle), child: Center(child: Text(cliente['avatar'] as String, style: const TextStyle(color: AppColors.pinkStrong, fontSize: 16, fontWeight: FontWeight.bold)))), const SizedBox(width: 12), Expanded(child: Text(cliente['nome'] as String))]), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Email: ${cliente["email"]}'), Text('Telefone: ${cliente["telefone"]}'), Text('Endereço: ${cliente["endereco"]}'), const Divider(), Text('Cadastro: ${cliente["dataCadastro"]}'), Text('Último Serviço: ${cliente["ultimoAgendamento"]}'), Text('Última Compra: ${cliente["ultimaCompra"]}'), const Divider(), Text('Total Serviços: ${cliente["totalAgendamentos"]}'), Text('Total Compras: ${cliente["totalCompras"]}'), Text('Total Gasto: R\$ ${(cliente["totalGasto"] as double).toStringAsFixed(2).replaceAll(".", ",")}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.pinkStrong))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]));

  void _showBloquearDialog(Map<String, dynamic> cliente) => showDialog(context: context, builder: (context) => AlertDialog(title: const Row(children: [Icon(Icons.block, color: Colors.red), SizedBox(width: 8), Text('Bloquear Cliente')]), content: Text('Tem certeza que deseja BLOQUEAR o cliente ${cliente['nome']}?\n\nO cliente não poderá mais agendar serviços ou comprar produtos.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), ElevatedButton(onPressed: () { Navigator.pop(context); setState(() { final index = _clientes.indexWhere((c) => c['id'] == cliente['id']); if (index != -1) _clientes[index]['status'] = 'bloqueado'; }); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${cliente['nome']} foi bloqueado!'), backgroundColor: Colors.red)); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: AppColors.white), child: const Text('Bloquear'))]));
}