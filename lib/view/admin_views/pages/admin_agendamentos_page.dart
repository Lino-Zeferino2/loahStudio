import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';

class AdminAgendamentosPage extends StatefulWidget {
  const AdminAgendamentosPage({super.key});

  @override
  State<AdminAgendamentosPage> createState() => _AdminAgendamentosPageState();
}

class _AdminAgendamentosPageState extends State<AdminAgendamentosPage> {
  String _selectedFilter = 'todos';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _agendamentos = [
    {'id': 1, 'cliente': 'Maria Santos', 'email': 'maria@email.com', 'telefone': '(11) 99999-1111', 'servico': 'Maquilhagem Noiva', 'data': DateTime(2025, 4, 26), 'hora': '14:00', 'duracao': '90 min', 'status': 'confirmado', 'imagem': 'M'},
    {'id': 2, 'cliente': 'João Silva', 'email': 'joao@email.com', 'telefone': '(11) 99999-2222', 'servico': 'Maquilhagem Festa', 'data': DateTime(2025, 4, 26), 'hora': '10:00', 'duracao': '60 min', 'status': 'pendente', 'imagem': 'J'},
    {'id': 3, 'cliente': 'Ana Costa', 'email': 'ana@email.com', 'telefone': '(11) 99999-3333', 'servico': 'Maquilhagem Editorial', 'data': DateTime(2025, 4, 25), 'hora': '09:00', 'duracao': '45 min', 'status': 'confirmado', 'imagem': 'A'},
    {'id': 4, 'cliente': 'Pedro Oliveira', 'email': 'pedro@email.com', 'telefone': '(11) 99999-4444', 'servico': 'Maquilhagem Natural', 'data': DateTime(2025, 4, 24), 'hora': '15:00', 'duracao': '30 min', 'status': 'cancelado', 'imagem': 'P'},
    {'id': 5, 'cliente': 'Carla Souza', 'email': 'carla@email.com', 'telefone': '(11) 99999-5555', 'servico': 'Sombra Olhos', 'data': DateTime(2025, 4, 27), 'hora': '11:00', 'duracao': '30 min', 'status': 'pendente', 'imagem': 'C'},
    {'id': 6, 'cliente': 'Lucas Ferreira', 'email': 'lucas@email.com', 'telefone': '(11) 99999-6666', 'servico': 'Maquilhagem Festa', 'data': DateTime(2025, 4, 27), 'hora': '16:00', 'duracao': '60 min', 'status': 'confirmado', 'imagem': 'L'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAgendamentos {
    var result = List<Map<String, dynamic>>.from(_agendamentos);
    if (_selectedFilter != 'todos') result = result.where((a) => a['status'] == _selectedFilter).toList();
    if (_selectedStartDate != null) result = result.where((a) => (a['data'] as DateTime).isAfter(_selectedStartDate!) || (a['data'] as DateTime).isAtSameMomentAs(_selectedStartDate!)).toList();
    if (_selectedEndDate != null) result = result.where((a) => (a['data'] as DateTime).isBefore(_selectedEndDate!) || (a['data'] as DateTime).isAtSameMomentAs(_selectedEndDate!)).toList();
    if (_searchQuery.isNotEmpty) result = result.where((a) => (a['cliente'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) || (a['email'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) || (a['servico'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    result.sort((a, b) => (b['data'] as DateTime).compareTo(a['data'] as DateTime));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    return Column(children: [_buildAppBar(isMobile), Expanded(child: _filteredAgendamentos.isEmpty ? _buildEmptyState() : _buildAgendamentosList(isMobile))]);
  }

  Widget _buildAppBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(hintText: 'Pesquisar cliente, serviço...', prefixIcon: const Icon(Icons.search, color: AppColors.grey), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: AppColors.grey), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null, filled: true, fillColor: AppColors.lightCreamBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14)),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          isMobile ? _buildFiltroDropdown() : Wrap(spacing: 8, runSpacing: 8, children: [_buildFilterChip('todos', 'Todos'), _buildFilterChip('pendente', 'Pendente'), _buildFilterChip('confirmado', 'Confirmado'), _buildFilterChip('concluido', 'Concluído'), _buildFilterChip('cancelado', 'Cancelado')]),
          SizedBox(height: isMobile ? 12 : 16),
          Row(
            children: [
              Expanded(child: _buildDatePicker(label: 'Data Início', date: _selectedStartDate, onSelect: (date) => setState(() => _selectedStartDate = date), isMobile: isMobile)),
              SizedBox(width: isMobile ? 8 : 16),
              Expanded(child: _buildDatePicker(label: 'Data Fim', date: _selectedEndDate, onSelect: (date) => setState(() => _selectedEndDate = date), isMobile: isMobile)),
              if (_selectedStartDate != null || _selectedEndDate != null) ...[const SizedBox(width: 8), IconButton(onPressed: () => setState(() { _selectedStartDate = null; _selectedEndDate = null; }), icon: const Icon(Icons.clear, color: Colors.redAccent), tooltip: 'Limpar datas')],
            ],
          ),
        ],
      ),
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
        items: const [DropdownMenuItem(value: 'todos', child: Text('Todos os status')), DropdownMenuItem(value: 'pendente', child: Text('Pendente')), DropdownMenuItem(value: 'confirmado', child: Text('Confirmado')), DropdownMenuItem(value: 'concluido', child: Text('Concluído')), DropdownMenuItem(value: 'cancelado', child: Text('Cancelado'))],
        onChanged: (value) { if (value != null) setState(() => _selectedFilter = value); },
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final bool isSelected = _selectedFilter == value;
    Color chipColor;
    switch (value) { case 'pendente': chipColor = Colors.orange; break; case 'confirmado': chipColor = Colors.green; break; case 'concluido': chipColor = Colors.blue; break; case 'cancelado': chipColor = Colors.red; break; default: chipColor = AppColors.pinkStrong; }
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isSelected ? chipColor : AppColors.lightCreamBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? chipColor : AppColors.grey.withValues(alpha: 0.3))),
        child: Text(label, style: TextStyle(color: isSelected ? AppColors.white : AppColors.brown, fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildDatePicker({required String label, required DateTime? date, required Function(DateTime) onSelect, required bool isMobile}) {
    return GestureDetector(
      onTap: () async { final selectedDate = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030)); if (selectedDate != null) onSelect(selectedDate); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.grey.withValues(alpha: 0.3))),
        child: Row(children: [const Icon(Icons.calendar_today, color: AppColors.grey, size: 18), const SizedBox(width: 8), Expanded(child: Text(date != null ? '${date.day}/${date.month}/${date.year}' : label, style: TextStyle(color: date != null ? AppColors.brown : AppColors.grey, fontSize: 13)))]),
      ),
    );
  }

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.event_busy, size: 64, color: AppColors.grey.withValues(alpha: 0.5)), const SizedBox(height: 16), const Text('Nenhum agendamento encontrado', style: TextStyle(color: AppColors.grey, fontSize: 16))]));

  Widget _buildAgendamentosList(bool isMobile) => ListView.builder(padding: EdgeInsets.all(isMobile ? 12 : 16), itemCount: _filteredAgendamentos.length, itemBuilder: (context, index) => _buildAgendamentoCard(_filteredAgendamentos[index], isMobile));

  Widget _buildAgendamentoCard(Map<String, dynamic> agendamento, bool isMobile) {
    final DateTime data = agendamento['data'] as DateTime;
    final String status = agendamento['status'] as String;
    Color statusColor;
    switch (status) { case 'pendente': statusColor = Colors.orange; break; case 'confirmado': statusColor = Colors.green; break; case 'concluido': statusColor = Colors.blue; break; case 'cancelado': statusColor = Colors.red; break; default: statusColor = AppColors.grey; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: isMobile ? 40 : 48, height: isMobile ? 40 : 48, decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), shape: BoxShape.circle), child: Center(child: Text(agendamento['imagem'] as String, style: const TextStyle(color: AppColors.pinkStrong, fontSize: 18, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(agendamento['cliente'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold)), Text(agendamento['email'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 13)), Text(agendamento['telefone'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 13))])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          isMobile
              ? Column(children: [Row(children: [const Icon(Icons.content_cut, color: AppColors.pinkStrong, size: 16), const SizedBox(width: 6), Expanded(child: Text(agendamento['servico'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 13), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 8), Row(children: [const Icon(Icons.calendar_today, color: AppColors.grey, size: 16), const SizedBox(width: 6), Text('${data.day}/${data.month}', style: const TextStyle(color: AppColors.brown, fontSize: 13)), const SizedBox(width: 16), const Icon(Icons.access_time, color: AppColors.grey, size: 16), const SizedBox(width: 6), Flexible(child: Text('${agendamento['hora']} (${agendamento['duracao']})', style: const TextStyle(color: AppColors.brown, fontSize: 13), overflow: TextOverflow.ellipsis))])])
              : Row(children: [Expanded(child: Row(children: [const Icon(Icons.content_cut, color: AppColors.pinkStrong, size: 18), const SizedBox(width: 6), Expanded(child: Text(agendamento['servico'] as String, style: const TextStyle(color: AppColors.brown, fontSize: 14), overflow: TextOverflow.ellipsis))])), Expanded(child: Row(children: [const Icon(Icons.calendar_today, color: AppColors.grey, size: 18), const SizedBox(width: 6), Text('${data.day}/${data.month}', style: const TextStyle(color: AppColors.brown, fontSize: 14))])), Expanded(child: Row(children: [const Icon(Icons.access_time, color: AppColors.grey, size: 18), const SizedBox(width: 6), Text('${agendamento['hora']} (${agendamento['duracao']})', style: const TextStyle(color: AppColors.brown, fontSize: 14))]))]),
          const SizedBox(height: 12),
          if (status != 'concluido' && status != 'cancelado')
            Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [if (status == 'pendente') ElevatedButton.icon(onPressed: () => _showConfirmDialog(agendamento, 'confirmado'), icon: const Icon(Icons.check, size: 18), label: const Text('Confirmar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: AppColors.white)), if (status == 'confirmado') ElevatedButton.icon(onPressed: () => _showConfirmDialog(agendamento, 'concluido'), icon: const Icon(Icons.check_circle, size: 18), label: const Text('Concluir'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: AppColors.white)), if (status != 'cancelado') ElevatedButton.icon(onPressed: () => _showConfirmDialog(agendamento, 'cancelar'), icon: const Icon(Icons.close, size: 18), label: const Text('Cancelar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: AppColors.white)), TextButton.icon(onPressed: () => _showEditDialog(agendamento), icon: const Icon(Icons.edit, size: 18), label: const Text('Editar'), style: TextButton.styleFrom(foregroundColor: AppColors.pinkStrong)), TextButton.icon(onPressed: () => _showDeleteDialog(agendamento), icon: const Icon(Icons.delete, size: 18), label: const Text('Eliminar'), style: TextButton.styleFrom(foregroundColor: Colors.redAccent))])
          else Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [TextButton.icon(onPressed: () => _showEditDialog(agendamento), icon: const Icon(Icons.edit, size: 18), label: const Text('Editar'), style: TextButton.styleFrom(foregroundColor: AppColors.pinkStrong)), TextButton.icon(onPressed: () => _showDeleteDialog(agendamento), icon: const Icon(Icons.delete, size: 18), label: const Text('Eliminar'), style: TextButton.styleFrom(foregroundColor: Colors.redAccent))]),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> agendamento) => showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Editar Agendamento'), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cliente: ${agendamento['cliente']}'), Text('Serviço: ${agendamento['servico']}'), Text('Data: ${agendamento['data']}'), Text('Hora: ${agendamento['hora']}')]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]));

  void _showDeleteDialog(Map<String, dynamic> agendamento) => showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Eliminar Agendamento'), content: Text('Tem certeza que deseja eliminar o agendamento de ${agendamento['cliente']}?'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), TextButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agendamento eliminado'))); }, child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)))]));

  void _showConfirmDialog(Map<String, dynamic> agendamento, String action) {
    String title, content, buttonText;
    IconData icon;
    Color buttonColor;
    if (action == 'confirmado') { title = 'Confirmar Agendamento'; content = 'Deseja confirmar o agendamento de ${agendamento['cliente']}?'; buttonText = 'Confirmar'; icon = Icons.check; buttonColor = Colors.green; }
    else if (action == 'concluido') { title = 'Concluir Agendamento'; content = 'Deseja marcar como concluído o agendamento de ${agendamento['cliente']}?'; buttonText = 'Concluir'; icon = Icons.check_circle; buttonColor = Colors.blue; }
    else { title = 'Cancelar Agendamento'; content = 'Deseja cancelar o agendamento de ${agendamento['cliente']}?'; buttonText = 'Cancelar'; icon = Icons.close; buttonColor = Colors.red; }
    showDialog(context: context, builder: (context) => AlertDialog(title: Row(children: [Icon(icon, color: buttonColor), const SizedBox(width: 8), Text(title)]), content: Text(content), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')), ElevatedButton(onPressed: () { Navigator.pop(context); _updateStatus(agendamento, action == 'confirmado' ? 'confirmado' : action == 'concluido' ? 'concluido' : 'cancelado'); }, style: ElevatedButton.styleFrom(backgroundColor: buttonColor, foregroundColor: AppColors.white), child: Text(buttonText))]));
  }

  void _updateStatus(Map<String, dynamic> agendamento, String newStatus) {
    setState(() { final index = _agendamentos.indexWhere((a) => a['id'] == agendamento['id']); if (index != -1) _agendamentos[index]['status'] = newStatus; });
    String message = newStatus == 'confirmado' ? 'Agendamento confirmado!' : newStatus == 'concluido' ? 'Agendamento concluído!' : 'Agendamento cancelado!';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}