import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';

class AdminComprasPage extends StatefulWidget {
  const AdminComprasPage({super.key});

  @override
  State<AdminComprasPage> createState() => _AdminComprasPageState();
}

class _AdminComprasPageState extends State<AdminComprasPage> {
  String _selectedFilter = 'todos';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _compras = [
    {'id': 1, 'cliente': 'Maria Santos', 'email': 'maria@email.com', 'telefone': '(11) 99999-1111', 'produtos': [{'nome': 'Batom Rouge', 'quantidade': 2}, {'nome': 'Gloss Brilho', 'quantidade': 1}], 'data': DateTime(2025, 4, 26), 'hora': '14:30', 'valor': 125.00, 'status': 'pago', 'codigo': 'PED #001'},
    {'id': 2, 'cliente': 'João Silva', 'email': 'joao@email.com', 'telefone': '(11) 99999-2222', 'produtos': [{'nome': 'Delineador', 'quantidade': 1}], 'data': DateTime(2025, 4, 26), 'hora': '10:15', 'valor': 42.00, 'status': 'pendente', 'codigo': 'PED #002'},
    {'id': 3, 'cliente': 'Ana Costa', 'email': 'ana@email.com', 'telefone': '(11) 99999-3333', 'produtos': [{'nome': 'Paleta Sombra', 'quantidade': 1}, {'nome': 'Primer Facial', 'quantidade': 2}], 'data': DateTime(2025, 4, 25), 'hora': '09:45', 'valor': 270.00, 'status': 'enviado', 'codigo': 'PED #003'},
    {'id': 4, 'cliente': 'Pedro Oliveira', 'email': 'pedro@email.com', 'telefone': '(11) 99999-4444', 'produtos': [{'nome': 'Batom Rouge', 'quantidade': 1}], 'data': DateTime(2025, 4, 24), 'hora': '15:20', 'valor': 45.00, 'status': 'entregue', 'codigo': 'PED #004'},
    {'id': 5, 'cliente': 'Carla Souza', 'email': 'carla@email.com', 'telefone': '(11) 99999-5555', 'produtos': [{'nome': 'Kit Maquiagem', 'quantidade': 1}], 'data': DateTime(2025, 4, 27), 'hora': '11:30', 'valor': 250.00, 'status': 'processando', 'codigo': 'PED #005'},
    {'id': 6, 'cliente': 'Lucas Ferreira', 'email': 'lucas@email.com', 'telefone': '(11) 99999-6666', 'produtos': [{'nome': 'Gloss Brilho', 'quantidade': 1}], 'data': DateTime(2025, 4, 27), 'hora': '16:00', 'valor': 35.00, 'status': 'devolvido', 'codigo': 'PED #006'},
    {'id': 7, 'cliente': 'Juliana Mendes', 'email': 'juliana@email.com', 'telefone': '(11) 99999-7777', 'produtos': [{'nome': 'Delineador', 'quantidade': 1}], 'data': DateTime(2025, 4, 23), 'hora': '13:00', 'valor': 42.00, 'status': 'cancelado', 'codigo': 'PED #007'},
  ];

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  List<Map<String, dynamic>> get _filteredCompras {
    var result = List<Map<String, dynamic>>.from(_compras);
    if (_selectedFilter != 'todos') result = result.where((c) => c['status'] == _selectedFilter).toList();
    if (_selectedStartDate != null) result = result.where((c) => (c['data'] as DateTime).isAfter(_selectedStartDate!) || (c['data'] as DateTime).isAtSameMomentAs(_selectedStartDate!)).toList();
    if (_selectedEndDate != null) result = result.where((c) => (c['data'] as DateTime).isBefore(_selectedEndDate!) || (c['data'] as DateTime).isAtSameMomentAs(_selectedEndDate!)).toList();
    if (_searchQuery.isNotEmpty) result = result.where((c) => (c['cliente'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) || (c['email'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) || (c['codigo'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) || _getProdutosString(c).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    result.sort((a, b) => (b['data'] as DateTime).compareTo(a['data'] as DateTime));
    return result;
  }

  String _getProdutosString(Map<String, dynamic> compra, {int maxMostrar = 2}) {
    final produtos = compra['produtos'] as List;
    if (produtos.length <= maxMostrar) return produtos.map((p) => '${p['nome']} x${p['quantidade']}').join(', ');
    final primeiros = produtos.take(maxMostrar).map((p) => '${p['nome']} x${p['quantidade']}').join(', ');
    return '$primeiros +${produtos.length - maxMostrar} mais';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    return Column(children: [_buildAppBar(isMobile), Expanded(child: _filteredCompras.isEmpty ? _buildEmptyState() : _buildComprasList(isMobile))]);
  }

  Widget _buildAppBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(children: [
        TextField(controller: _searchController, onChanged: (value) => setState(() => _searchQuery = value), decoration: InputDecoration(hintText: 'Pesquisar cliente, código, produto...', prefixIcon: const Icon(Icons.search, color: AppColors.grey), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: AppColors.grey), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null, filled: true, fillColor: AppColors.lightCreamBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14))),
        SizedBox(height: isMobile ? 12 : 16),
        isMobile ? _buildFiltroDropdown() : Wrap(spacing: 8, runSpacing: 8, children: [_buildFilterChip('todos', 'Todos'), _buildFilterChip('pendente', 'Pendente'), _buildFilterChip('pago', 'Pago'), _buildFilterChip('processando', 'Processando'), _buildFilterChip('enviado', 'Enviado'), _buildFilterChip('entregue', 'Entregue'), _buildFilterChip('devolvido', 'Devolvido'), _buildFilterChip('cancelado', 'Cancelado')]),
        SizedBox(height: isMobile ? 12 : 16),
        Row(children: [
          Expanded(child: _buildDatePicker(label: 'Data Início', date: _selectedStartDate, onSelect: (date) => setState(() => _selectedStartDate = date), isMobile: isMobile)),
          SizedBox(width: isMobile ? 8 : 16),
          Expanded(child: _buildDatePicker(label: 'Data Fim', date: _selectedEndDate, onSelect: (date) => setState(() => _selectedEndDate = date), isMobile: isMobile)),
          if (_selectedStartDate != null || _selectedEndDate != null) ...[const SizedBox(width: 8), IconButton(onPressed: () => setState(() { _selectedStartDate = null; _selectedEndDate = null; }), icon: const Icon(Icons.clear, color: Colors.redAccent), tooltip: 'Limpar datas')],
        ]),
      ]),
    );
  }

  Widget _buildFiltroDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.grey.withValues(alpha: 0.3))),
      child: DropdownButton<String>(
        value: _selectedFilter,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
        style: TextStyle(color: _selectedFilter == 'todos' ? AppColors.grey : AppColors.brown, fontSize: 14),
        items: const [DropdownMenuItem(value: 'todos', child: Text('Todos os status')), DropdownMenuItem(value: 'pendente', child: Text('Pendente')), DropdownMenuItem(value: 'pago', child: Text('Pago')), DropdownMenuItem(value: 'processando', child: Text('Processando')), DropdownMenuItem(value: 'enviado', child: Text('Enviado')), DropdownMenuItem(value: 'entregue', child: Text('Entregue')), DropdownMenuItem(value: 'devolvido', child: Text('Devolvido')), DropdownMenuItem(value: 'cancelado', child: Text('Cancelado'))],
        onChanged: (value) { if (value != null) setState(() => _selectedFilter = value); },
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final bool isSelected = _selectedFilter == value;
    Color chipColor;
    switch (value) { case 'pendente': chipColor = Colors.orange; break; case 'pago': chipColor = Colors.green; break; case 'processando': chipColor = Colors.blue; break; case 'enviado': chipColor = Colors.purple; break; case 'entregue': chipColor = Colors.teal; break; case 'devolvido': chipColor = Colors.brown; break; case 'cancelado': chipColor = Colors.red; break; default: chipColor = AppColors.pinkStrong; }
    return GestureDetector(onTap: () => setState(() => _selectedFilter = value), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isSelected ? chipColor : AppColors.lightCreamBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? chipColor : AppColors.grey.withValues(alpha: 0.3))), child: Text(label, style: TextStyle(color: isSelected ? AppColors.white : AppColors.brown, fontSize: 13, fontWeight: FontWeight.w500))));
  }

  Widget _buildDatePicker({required String label, required DateTime? date, required Function(DateTime) onSelect, required bool isMobile}) {
    return GestureDetector(
      onTap: () async { final selectedDate = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030)); if (selectedDate != null) onSelect(selectedDate); },
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.grey.withValues(alpha: 0.3))), child: Row(children: [const Icon(Icons.calendar_today, color: AppColors.grey, size: 18), const SizedBox(width: 8), Expanded(child: Text(date != null ? '${date.day}/${date.month}/${date.year}' : label, style: TextStyle(color: date != null ? AppColors.brown : AppColors.grey, fontSize: 13)))])),
    );
  }

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.grey.withValues(alpha: 0.5)), const SizedBox(height: 16), const Text('Nenhuma compra encontrada', style: TextStyle(color: AppColors.grey, fontSize: 16))]));

  Widget _buildComprasList(bool isMobile) => ListView.builder(padding: EdgeInsets.all(isMobile ? 12 : 16), itemCount: _filteredCompras.length, itemBuilder: (context, index) => _buildCompraCard(_filteredCompras[index], isMobile));

  Widget _buildCompraCard(Map<String, dynamic> compra, bool isMobile) {
    final DateTime data = compra['data'] as DateTime;
    final String status = compra['status'] as String;
    final double valor = compra['valor'] as double;
    Color statusColor;
    IconData statusIcon;
    switch (status) { case 'pendente': statusColor = Colors.orange; statusIcon = Icons.hourglass_empty; break; case 'pago': statusColor = Colors.green; statusIcon = Icons.payments; break; case 'processando': statusColor = Colors.blue; statusIcon = Icons.inventory_2; break; case 'enviado': statusColor = Colors.purple; statusIcon = Icons.local_shipping; break; case 'entregue': statusColor = Colors.teal; statusIcon = Icons.check_circle; break; case 'devolvido': statusColor = Colors.brown; statusIcon = Icons.replay; break; case 'cancelado': statusColor = Colors.red; statusIcon = Icons.cancel; break; default: statusColor = AppColors.grey; statusIcon = Icons.help; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)), child: Text(compra['codigo'] as String, style: const TextStyle(color: AppColors.pinkStrong, fontSize: 13, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(compra['cliente'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold)), Text(compra['email'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 13)), Text(compra['telefone'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 13))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(statusIcon, color: statusColor, size: 16), const SizedBox(width: 4), Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold))])),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        isMobile
            ? Column(children: [Row(children: [const Icon(Icons.shopping_bag, color: AppColors.pinkStrong, size: 16), const SizedBox(width: 6), Expanded(child: Text(_getProdutosString(compra), style: const TextStyle(color: AppColors.brown, fontSize: 13), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 8), Row(children: [const Icon(Icons.calendar_today, color: AppColors.grey, size: 16), const SizedBox(width: 6), Text('${data.day}/${data.month}', style: const TextStyle(color: AppColors.brown, fontSize: 13)), const SizedBox(width: 16), const Icon(Icons.access_time, color: AppColors.grey, size: 16), const SizedBox(width: 6), Text(compra['hora'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 13))])])
            : Row(children: [Expanded(child: Row(children: [const Icon(Icons.shopping_bag, color: AppColors.pinkStrong, size: 18), const SizedBox(width: 6), Expanded(child: Text(_getProdutosString(compra), style: const TextStyle(color: AppColors.brown, fontSize: 14), overflow: TextOverflow.ellipsis))])), Expanded(child: Row(children: [const Icon(Icons.calendar_today, color: AppColors.grey, size: 18), const SizedBox(width: 6), Text('${data.day}/${data.month}', style: const TextStyle(color: AppColors.brown, fontSize: 14))])), Expanded(child: Row(children: [const Icon(Icons.access_time, color: AppColors.grey, size: 18), const SizedBox(width: 6), Text(compra['hora'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 14))]))]),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total:', style: TextStyle(color: AppColors.brown, fontSize: 14)), Text('R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppColors.pinkStrong, fontSize: 16, fontWeight: FontWeight.bold))])),
        const SizedBox(height: 12),
        if (status != 'entregue' && status != 'devolvido' && status != 'cancelado')
          Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [if (status == 'pendente') ElevatedButton.icon(onPressed: () => _showConfirmDialog(compra, 'pago'), icon: const Icon(Icons.check, size: 18), label: const Text('Confirmar Pago'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: AppColors.white)), if (status == 'pago') ElevatedButton.icon(onPressed: () => _showConfirmDialog(compra, 'processando'), icon: const Icon(Icons.inventory_2, size: 18), label: const Text('Processar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: AppColors.white)), if (status == 'processando') ElevatedButton.icon(onPressed: () => _showConfirmDialog(compra, 'enviar'), icon: const Icon(Icons.local_shipping, size: 18), label: const Text('Enviar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: AppColors.white)), if (status == 'enviado') ElevatedButton.icon(onPressed: () => _showConfirmDialog(compra, 'entregar'), icon: const Icon(Icons.check_circle, size: 18), label: const Text('Confirmar Entrega'), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: AppColors.white)), if (status != 'cancelado') ElevatedButton.icon(onPressed: () => _showConfirmDialog(compra, 'cancelar'), icon: const Icon(Icons.close, size: 18), label: const Text('Cancelar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: AppColors.white)), TextButton.icon(onPressed: () => _showDetailsDialog(compra), icon: const Icon(Icons.visibility, size: 18), label: const Text('Detalhes'), style: TextButton.styleFrom(foregroundColor: AppColors.pinkStrong))])
        else Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [if (status == 'entregue') ElevatedButton.icon(onPressed: () => _showConfirmDialog(compra, 'devolver'), icon: const Icon(Icons.replay, size: 18), label: const Text('Registrar Devolução'), style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: AppColors.white)), TextButton.icon(onPressed: () => _showDetailsDialog(compra), icon: const Icon(Icons.visibility, size: 18), label: const Text('Detalhes'), style: TextButton.styleFrom(foregroundColor: AppColors.pinkStrong))]),
      ]),
    );
  }

  void _showDetailsDialog(Map<String, dynamic> compra) {
    final produtos = compra['produtos'] as List;
    showDialog(context: context, builder: (context) => AlertDialog(title: Text('Detalhes do ${compra["codigo"]}'), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cliente: ${compra["cliente"]}'), Text('Email: ${compra["email"]}'), Text('Telefone: ${compra["telefone"]}'), const Divider(), const Text('Produtos:', style: TextStyle(fontWeight: FontWeight.bold)), ...produtos.map((p) => Text('• ${p['nome']} x${p['quantidade']}')), Text('Data: ${compra["data"]}'), Text('Hora: ${compra["hora"]}'), Text('Valor: R\$ ${(compra["valor"] as double).toStringAsFixed(2).replaceAll(".", ",")}'), Text('Status: ${compra["status"]}')]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]));
  }

  void _showConfirmDialog(Map<String, dynamic> compra, String action) {
    String title, content, buttonText;
    IconData icon;
    Color buttonColor;
    switch (action) { case 'pago': title = 'Confirmar Pagamento'; content = 'Confirmar que o pagamento do pedido ${compra["codigo"]} foi recebido?'; buttonText = 'Confirmar'; icon = Icons.payments; buttonColor = Colors.green; break; case 'processando': title = 'Iniciar Processamento'; content = 'Iniciar o processamento do pedido ${compra["codigo"]}?'; buttonText = 'Iniciar'; icon = Icons.inventory_2; buttonColor = Colors.blue; break; case 'enviar': title = 'Enviar Pedido'; content = 'Marcar o pedido ${compra["codigo"]} como enviado?'; buttonText = 'Enviar'; icon = Icons.local_shipping; buttonColor = Colors.purple; break; case 'entregar': title = 'Confirmar Entrega'; content = 'Confirmar que o pedido ${compra["codigo"]} foi entregue?'; buttonText = 'Confirmar'; icon = Icons.check_circle; buttonColor = Colors.teal; break; case 'devolver': title = 'Registrar Devolução'; content = 'Registrar devolução do pedido ${compra["codigo"]}?'; buttonText = 'Registrar'; icon = Icons.replay; buttonColor = Colors.brown; break; default: title = 'Cancelar Pedido'; content = 'Tem certeza que deseja cancelar o pedido ${compra["codigo"]}?'; buttonText = 'Cancelar'; icon = Icons.close; buttonColor = Colors.red; }
    showDialog(context: context, builder: (context) => AlertDialog(title: Row(children: [Icon(icon, color: buttonColor), const SizedBox(width: 8), Text(title)]), content: Text(content), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')), ElevatedButton(onPressed: () { Navigator.pop(context); _updateStatus(compra, action == 'cancelar' ? 'cancelado' : action); }, style: ElevatedButton.styleFrom(backgroundColor: buttonColor, foregroundColor: AppColors.white), child: Text(buttonText))]));
  }

  void _updateStatus(Map<String, dynamic> compra, String newStatus) {
    setState(() { final index = _compras.indexWhere((c) => c['id'] == compra['id']); if (index != -1) _compras[index]['status'] = newStatus; });
    String message; switch (newStatus) { case 'pago': message = 'Pagamento confirmado!'; break; case 'processando': message = 'Pedido em processamento!'; break; case 'enviado': message = 'Pedido enviado!'; break; case 'entregue': message = 'Pedido entregue!'; break; case 'devolvido': message = 'Devolução registrada!'; break; case 'cancelado': message = 'Pedido cancelado!'; break; default: message = 'Status atualizado!'; }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}