import 'package:cloud_firestore/cloud_firestore.dart';
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
  final CollectionReference _clientesRef =
      FirebaseFirestore.instance.collection('clientes');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _clienteFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String nome = (data['nome'] as String?)?.trim().isNotEmpty == true
        ? (data['nome'] as String)
        : 'Sem nome';
    return {
      'id': doc.id,
      'nome': nome,
      'email': data['email'] as String? ?? '',
      'telefone': data['telefone'] as String? ?? '',
      'endereco': data['endereco'] as String? ?? '',
      'dataCadastro': (data['dataCadastro'] as Timestamp?)?.toDate(),
      'ultimoAgendamento': (data['ultimoAgendamento'] as Timestamp?)?.toDate(),
      'ultimaCompra': (data['ultimaCompra'] as Timestamp?)?.toDate(),
      'totalAgendamentos': data['totalAgendamentos'] as int? ?? 0,
      'totalCompras': data['totalCompras'] as int? ?? 0,
      'totalGasto': (data['totalGasto'] as num?)?.toDouble() ?? 0.0,
      'status': data['status'] as String? ?? 'ativo',
      'notas': data['notas'] as String? ?? '',
      'role': data['role'] as String? ?? 'user',
      'avatar': nome.isNotEmpty ? nome[0].toUpperCase() : '?',
    };
  }

  List<Map<String, dynamic>> _mapDocs(List<QueryDocumentSnapshot> docs) {
    return docs
        .map(_clienteFromDoc)
        .where((c) => c['role'] != 'admin')
        .toList();
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> clientes) {
    var result = List<Map<String, dynamic>>.from(clientes);
    if (_selectedFilter != 'todos') {
      result = result.where((c) => c['status'] == _selectedFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((c) =>
          (c['nome'] as String).toLowerCase().contains(q) ||
          (c['email'] as String).toLowerCase().contains(q) ||
          (c['telefone'] as String).contains(_searchQuery)).toList();
    }
    result.sort((a, b) => (a['nome'] as String).compareTo(b['nome'] as String));
    return result;
  }

  Future<void> _atualizarStatus(String docId, String status) async {
    try {
      await _clientesRef.doc(docId).update({'status': status});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isTablet = ResponsiveHelper.isTablet(context);

    return StreamBuilder<QuerySnapshot>(
      stream: _clientesRef.orderBy('nome').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar clientes: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final todosClientes = _mapDocs(snapshot.data!.docs);
        final filteredClientes = _applyFilters(todosClientes);
        final totalClientes = todosClientes.length;
        final clientesAtivos = todosClientes.where((c) => c['status'] == 'ativo').length;

        return Column(children: [
          _buildAppBar(isMobile),
          if (!isMobile) _buildStatsBar(isTablet, totalClientes, clientesAtivos),
          Expanded(
            child: filteredClientes.isEmpty
                ? _buildEmptyState()
                : _buildClientesList(filteredClientes, isMobile, isTablet),
          ),
        ]);
      },
    );
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

  Widget _buildStatsBar(bool isTablet, int totalClientes, int clientesAtivos) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.lightCreamBg, border: Border(bottom: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)))), child: isTablet ? Wrap(spacing: 24, runSpacing: 12, children: [_buildStatItem('Total Clientes', '$totalClientes', Icons.people), _buildStatItem('Ativos', '$clientesAtivos', Icons.person)]) : Row(children: [Expanded(child: _buildStatItem('Total Clientes', '$totalClientes', Icons.people)), Expanded(child: _buildStatItem('Ativos', '$clientesAtivos', Icons.person))]));

  Widget _buildStatItem(String label, String value, IconData icon) => Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppColors.pinkStrong, size: 20)), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)), Text(value, style: const TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold))])]);

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people_outline, size: 64, color: AppColors.grey.withValues(alpha: 0.5)), const SizedBox(height: 16), const Text('Nenhum cliente encontrado', style: TextStyle(color: AppColors.grey, fontSize: 16))]));

  Widget _buildClientesList(List<Map<String, dynamic>> clientes, bool isMobile, bool isTablet) => ListView.builder(padding: EdgeInsets.all(isMobile ? 12 : 16), itemCount: clientes.length, itemBuilder: (context, index) => _buildClienteCard(clientes[index], isMobile, isTablet));

  Widget _buildClienteCard(Map<String, dynamic> cliente, bool isMobile, bool isTablet) {
    final String status = cliente['status'] as String;
    final DateTime? ultimoAgendamento = cliente['ultimoAgendamento'] as DateTime?;
    final DateTime? dataCadastro = cliente['dataCadastro'] as DateTime?;
    final double totalGasto = cliente['totalGasto'] as double;
    final int totalAgendamentos = cliente['totalAgendamentos'] as int;
    final int totalCompras = cliente['totalCompras'] as int;
    final String notas = cliente['notas'] as String;
    final String endereco = cliente['endereco'] as String;

    Color statusColor;
    switch (status) { case 'ativo': statusColor = Colors.green; break; case 'bloqueado': statusColor = Colors.red; break; default: statusColor = Colors.grey; }

    String formatData(DateTime? d) => d == null ? 'Nunca' : '${d.day}/${d.month}/${d.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: status == 'bloqueado' ? Colors.red.withValues(alpha: 0.05) : AppColors.white, borderRadius: BorderRadius.circular(12), border: status == 'bloqueado' ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2) : null, boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: isMobile ? 50 : 56, height: isMobile ? 50 : 56, decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), shape: BoxShape.circle), child: Center(child: Text(cliente['avatar'] as String, style: const TextStyle(color: AppColors.pinkStrong, fontSize: 20, fontWeight: FontWeight.bold)))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cliente['nome'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 18, fontWeight: FontWeight.bold)), Text(cliente['email'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 13)), Text(cliente['telefone'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 13))])), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        if (endereco.isNotEmpty) ...[
          Row(children: [const Icon(Icons.location_on, color: AppColors.grey, size: 16), const SizedBox(width: 6), Expanded(child: Text(endereco, style: const TextStyle(color: AppColors.brown, fontSize: 13), overflow: TextOverflow.ellipsis))]),
          const SizedBox(height: 12),
        ],
        isMobile ? Column(children: [_buildStatRow('Cadastro', formatData(dataCadastro)), _buildStatRow('Último Serviço', formatData(ultimoAgendamento)), _buildStatRow('Total Serviços', '$totalAgendamentos'), _buildStatRow('Total Compras', '$totalCompras'), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Gasto:', style: TextStyle(color: AppColors.brown, fontSize: 14, fontWeight: FontWeight.bold)), Text('€ ${totalGasto.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppColors.pinkStrong, fontSize: 16, fontWeight: FontWeight.bold))]))]) : Wrap(spacing: 16, runSpacing: 8, children: [_buildStatChip('Cadastro', formatData(dataCadastro)), _buildStatChip('Últ.Serviço', formatData(ultimoAgendamento)), _buildStatChip('Total Serviços', '$totalAgendamentos'), _buildStatChip('Total Compras', '$totalCompras'), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Text('Total: ', style: TextStyle(color: AppColors.brown, fontSize: 14, fontWeight: FontWeight.bold)), Text('€ ${totalGasto.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppColors.pinkStrong, fontSize: 16, fontWeight: FontWeight.bold))]))]),
        if (notas.isNotEmpty) ...[const SizedBox(height: 12), Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Notas:', style: TextStyle(color: AppColors.brown, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(notas, style: const TextStyle(color: AppColors.grey, fontSize: 13))]))],
        const SizedBox(height: 12),
        Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [ElevatedButton.icon(onPressed: () => _showDetalhesDialog(cliente), icon: const Icon(Icons.visibility, size: 18), label: const Text('Detalhes'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, foregroundColor: AppColors.white)), TextButton.icon(onPressed: () {}, icon: const Icon(Icons.edit, size: 18), label: const Text('Editar'), style: TextButton.styleFrom(foregroundColor: AppColors.pinkStrong)), TextButton.icon(onPressed: () {}, icon: const Icon(Icons.chat, size: 18), label: const Text('WhatsApp'), style: TextButton.styleFrom(foregroundColor: Colors.green)), if (status == 'ativo') TextButton.icon(onPressed: () => _showBloquearDialog(cliente), icon: const Icon(Icons.block, size: 18), label: const Text('Bloquear'), style: TextButton.styleFrom(foregroundColor: Colors.red)) else if (status == 'bloqueado') TextButton.icon(onPressed: () => _atualizarStatus(cliente['id'] as String, 'ativo'), icon: const Icon(Icons.lock_open, size: 18), label: const Text('Desbloquear'), style: TextButton.styleFrom(foregroundColor: Colors.orange))]),
      ]),
    );
  }

  Widget _buildStatRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('$label:', style: const TextStyle(color: AppColors.grey, fontSize: 13)), Text(value, style: const TextStyle(color: AppColors.brown, fontSize: 13, fontWeight: FontWeight.w500))]));

  Widget _buildStatChip(String label, String value) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8)), child: Column(children: [Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 10)), Text(value, style: const TextStyle(color: AppColors.brown, fontSize: 13, fontWeight: FontWeight.w500))]));

  void _showDetalhesDialog(Map<String, dynamic> cliente) {
    final DateTime? dataCadastro = cliente['dataCadastro'] as DateTime?;
    final DateTime? ultimoAgendamento = cliente['ultimoAgendamento'] as DateTime?;
    final DateTime? ultimaCompra = cliente['ultimaCompra'] as DateTime?;
    showDialog(context: context, builder: (context) => AlertDialog(title: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), shape: BoxShape.circle), child: Center(child: Text(cliente['avatar'] as String, style: const TextStyle(color: AppColors.pinkStrong, fontSize: 16, fontWeight: FontWeight.bold)))), const SizedBox(width: 12), Expanded(child: Text(cliente['nome'] as String))]), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Email: ${cliente["email"]}'), Text('Telefone: ${cliente["telefone"]}'), Text('Endereço: ${(cliente["endereco"] as String).isEmpty ? "-" : cliente["endereco"]}'), const Divider(), Text('Cadastro: ${dataCadastro ?? "-"}'), Text('Último Serviço: ${ultimoAgendamento ?? "Nunca"}'), Text('Última Compra: ${ultimaCompra ?? "Nunca"}'), const Divider(), Text('Total Serviços: ${cliente["totalAgendamentos"]}'), Text('Total Compras: ${cliente["totalCompras"]}'), Text('Total Gasto: € ${(cliente["totalGasto"] as double).toStringAsFixed(2).replaceAll(".", ",")}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.pinkStrong))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]));
  }

  void _showBloquearDialog(Map<String, dynamic> cliente) => showDialog(context: context, builder: (context) => AlertDialog(title: const Row(children: [Icon(Icons.block, color: Colors.red), SizedBox(width: 8), Text('Bloquear Cliente')]), content: Text('Tem certeza que deseja BLOQUEAR o cliente ${cliente['nome']}?\n\nO cliente não poderá mais agendar serviços ou comprar produtos.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), ElevatedButton(onPressed: () { Navigator.pop(context); _atualizarStatus(cliente['id'] as String, 'bloqueado'); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: AppColors.white), child: const Text('Bloquear'))]));
}