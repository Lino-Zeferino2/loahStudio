import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/pedido_controller.dart';
import 'package:loahstudio/model/pedido_model.dart';

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

  final PedidoController _pedidoController = PedidoController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Pedido> _filterPedidos(List<Pedido> pedidos) {
    var result = List<Pedido>.from(pedidos);
    if (_selectedFilter != 'todos') {
      result = result.where((p) => p.status == _selectedFilter).toList();
    }
    if (_selectedStartDate != null) {
      result = result.where((p) {
        final criadoEm = p.criadoEm;
        if (criadoEm == null) return false;
        return criadoEm.isAfter(_selectedStartDate!) || criadoEm.isAtSameMomentAs(_selectedStartDate!);
      }).toList();
    }
    if (_selectedEndDate != null) {
      result = result.where((p) {
        final criadoEm = p.criadoEm;
        if (criadoEm == null) return false;
        return criadoEm.isBefore(_selectedEndDate!) || criadoEm.isAtSameMomentAs(_selectedEndDate!);
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.clienteNome.toLowerCase().contains(query) ||
            p.clienteEmail.toLowerCase().contains(query) ||
            p.clienteTelefone.contains(_searchQuery);
      }).toList();
    }
    result.sort((a, b) => (b.criadoEm ?? DateTime(2000)).compareTo(a.criadoEm ?? DateTime(2000)));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    return StreamBuilder<List<Pedido>>(
      stream: _pedidoController.streamTodosPedidos(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar pedidos: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.grey), SizedBox(height: 16), Text('Carregando pedidos...', style: TextStyle(color: AppColors.grey, fontSize: 16))]));
        }

        final filteredPedidos = _filterPedidos(snapshot.data!);

        if (filteredPedidos.isEmpty) {
          return Column(children: [_buildAppBar(isMobile), Expanded(child: _buildEmptyState())]);
        }

        return Column(children: [_buildAppBar(isMobile), Expanded(child: ListView.builder(padding: EdgeInsets.all(isMobile ? 12 : 16), itemCount: filteredPedidos.length, itemBuilder: (context, index) => _buildCompraCard(filteredPedidos[index], isMobile)))]);
      },
    );
  }

  Widget _buildAppBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Pesquisar cliente, email, telefone...',
            prefixIcon: const Icon(Icons.search, color: AppColors.grey),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.lightCreamBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        isMobile ? _buildFiltroDropdown() : Wrap(spacing: 8, runSpacing: 8, children: [
          _buildFilterChip('todos', 'Todos'),
          _buildFilterChip('pendente', 'Pendente'),
          _buildFilterChip('confirmado', 'Confirmado'),
          _buildFilterChip('preparando', 'Preparando'),
          _buildFilterChip('enviado', 'Enviado'),
          _buildFilterChip('entregue', 'Entregue'),
          _buildFilterChip('cancelado', 'Cancelado'),
        ]),
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
        items: const [
          DropdownMenuItem(value: 'todos', child: Text('Todos os status')),
          DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
          DropdownMenuItem(value: 'confirmado', child: Text('Confirmado')),
          DropdownMenuItem(value: 'preparando', child: Text('Preparando')),
          DropdownMenuItem(value: 'enviado', child: Text('Enviado')),
          DropdownMenuItem(value: 'entregue', child: Text('Entregue')),
          DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
        ],
        onChanged: (value) { if (value != null) setState(() => _selectedFilter = value); },
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final bool isSelected = _selectedFilter == value;
    Color chipColor;
    switch (value) {
      case 'pendente': chipColor = Colors.orange; break;
      case 'confirmado': chipColor = Colors.green; break;
      case 'preparando': chipColor = Colors.blue; break;
      case 'enviado': chipColor = Colors.purple; break;
      case 'entregue': chipColor = Colors.teal; break;
      case 'cancelado': chipColor = Colors.red; break;
      default: chipColor = AppColors.pinkStrong;
    }
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
      onTap: () async {
        final selectedDate = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
        if (selectedDate != null) onSelect(selectedDate);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.grey.withValues(alpha: 0.3))),
        child: Row(children: [const Icon(Icons.calendar_today, color: AppColors.grey, size: 18), const SizedBox(width: 8), Expanded(child: Text(date != null ? '${date.day}/${date.month}/${date.year}' : label, style: TextStyle(color: date != null ? AppColors.brown : AppColors.grey, fontSize: 13)))]),
      ),
    );
  }

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.grey.withValues(alpha: 0.5)), const SizedBox(height: 16), const Text('Nenhuma compra encontrada', style: TextStyle(color: AppColors.grey, fontSize: 16))]));

  String _getProdutosString(Pedido pedido, {int maxMostrar = 2}) {
    final produtos = pedido.itens;
    if (produtos.isEmpty) return 'Sem produtos';
    if (produtos.length <= maxMostrar) return produtos.map((p) => '${p.nome} x${p.quantidade}').join(', ');
    final primeiros = produtos.take(maxMostrar).map((p) => '${p.nome} x${p.quantidade}').join(', ');
    return '$primeiros +${produtos.length - maxMostrar} mais';
  }

  Widget _buildCompraCard(Pedido pedido, bool isMobile) {
    final String status = pedido.status;
    final double valor = pedido.valorTotal;

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'pendente': statusColor = Colors.orange; statusIcon = Icons.hourglass_empty; break;
      case 'confirmado': statusColor = Colors.green; statusIcon = Icons.payments; break;
      case 'preparando': statusColor = Colors.blue; statusIcon = Icons.inventory_2; break;
      case 'enviado': statusColor = Colors.purple; statusIcon = Icons.local_shipping; break;
      case 'entregue': statusColor = Colors.teal; statusIcon = Icons.check_circle; break;
      case 'cancelado': statusColor = Colors.red; statusIcon = Icons.cancel; break;
      default: statusColor = AppColors.grey; statusIcon = Icons.help;
    }

    final String inicial = pedido.clienteNome.isNotEmpty ? pedido.clienteNome[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: isMobile ? 40 : 48, height: isMobile ? 40 : 48, decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), shape: BoxShape.circle), child: Center(child: Text(inicial, style: const TextStyle(color: AppColors.pinkStrong, fontSize: 18, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pedido.clienteNome, style: const TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold)), Text(pedido.clienteEmail, style: const TextStyle(color: AppColors.grey, fontSize: 13)), Text(pedido.clienteTelefone, style: const TextStyle(color: AppColors.grey, fontSize: 13))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(statusIcon, color: statusColor, size: 16), const SizedBox(width: 4), Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold))])),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        isMobile
            ? Column(children: [Row(children: [const Icon(Icons.shopping_bag, color: AppColors.pinkStrong, size: 16), const SizedBox(width: 6), Expanded(child: Text(_getProdutosString(pedido), style: const TextStyle(color: AppColors.brown, fontSize: 13), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 8), Row(children: [const Icon(Icons.calendar_today, color: AppColors.grey, size: 16), const SizedBox(width: 6), Text(pedido.criadoEm != null ? '${pedido.criadoEm!.day}/${pedido.criadoEm!.month}' : '--/--', style: const TextStyle(color: AppColors.brown, fontSize: 13)), const SizedBox(width: 16), const Icon(Icons.access_time, color: AppColors.grey, size: 16), const SizedBox(width: 6), Text(pedido.metodoPagamento, style: const TextStyle(color: AppColors.brown, fontSize: 13))])])
            : Row(children: [Expanded(child: Row(children: [const Icon(Icons.shopping_bag, color: AppColors.pinkStrong, size: 18), const SizedBox(width: 6), Expanded(child: Text(_getProdutosString(pedido), style: const TextStyle(color: AppColors.brown, fontSize: 14), overflow: TextOverflow.ellipsis))])), Expanded(child: Row(children: [const Icon(Icons.calendar_today, color: AppColors.grey, size: 18), const SizedBox(width: 6), Text(pedido.criadoEm != null ? '${pedido.criadoEm!.day}/${pedido.criadoEm!.month}/${pedido.criadoEm!.year}' : '--/--/----', style: const TextStyle(color: AppColors.brown, fontSize: 14))])), Expanded(child: Row(children: [const Icon(Icons.payments, color: AppColors.grey, size: 18), const SizedBox(width: 6), Text(pedido.metodoPagamento, style: const TextStyle(color: AppColors.brown, fontSize: 14))]))]),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total:', style: TextStyle(color: AppColors.brown, fontSize: 14)), Text('R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppColors.pinkStrong, fontSize: 16, fontWeight: FontWeight.bold))])),
        if (pedido.aguardaComprovativo) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.warning_amber, color: Colors.orange, size: 16), const SizedBox(width: 8), const Expanded(child: Text('Aguardando comprovativo de pagamento', style: TextStyle(color: Colors.orange, fontSize: 12)))])),
        ],
        const SizedBox(height: 12),
        _buildActionButtons(pedido),
      ]),
    );
  }

  Widget _buildActionButtons(Pedido pedido) {
    final status = pedido.status;
    final podeCancelar = pedido.podeCancelar;
    final isFinalizado = pedido.isFinalizado;

    if (isFinalizado) {
      return Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [
        TextButton.icon(onPressed: () => _showDetailsDialog(pedido), icon: const Icon(Icons.visibility, size: 18), label: const Text('Detalhes'), style: TextButton.styleFrom(foregroundColor: AppColors.pinkStrong)),
      ]);
    }

    return Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [
      if (status == 'pendente')
        ElevatedButton.icon(onPressed: () => _showConfirmDialog(pedido, 'confirmado'), icon: const Icon(Icons.check, size: 18), label: const Text('Confirmar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: AppColors.white)),
      if (status == 'confirmado')
        ElevatedButton.icon(onPressed: () => _showConfirmDialog(pedido, 'preparando'), icon: const Icon(Icons.inventory_2, size: 18), label: const Text('Preparar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: AppColors.white)),
      if (status == 'preparando')
        ElevatedButton.icon(onPressed: () => _showConfirmDialog(pedido, 'enviado'), icon: const Icon(Icons.local_shipping, size: 18), label: const Text('Enviar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: AppColors.white)),
      if (status == 'enviado')
        ElevatedButton.icon(onPressed: () => _showConfirmDialog(pedido, 'entregue'), icon: const Icon(Icons.check_circle, size: 18), label: const Text('Confirmar Entrega'), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: AppColors.white)),
      if (podeCancelar)
        ElevatedButton.icon(onPressed: () => _showConfirmDialog(pedido, 'cancelar'), icon: const Icon(Icons.close, size: 18), label: const Text('Cancelar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: AppColors.white)),
      TextButton.icon(onPressed: () => _showDetailsDialog(pedido), icon: const Icon(Icons.visibility, size: 18), label: const Text('Detalhes'), style: TextButton.styleFrom(foregroundColor: AppColors.pinkStrong)),
    ]);
  }

  void _showDetailsDialog(Pedido pedido) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalhes do PED #${pedido.id != null ? pedido.id!.substring(0, 6).toUpperCase() : '---'}'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Cliente: ${pedido.clienteNome}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Email: ${pedido.clienteEmail}'),
            Text('Telefone: ${pedido.clienteTelefone}'),
            const Divider(),
            const Text('Morada:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${pedido.morada}, ${pedido.codigoPostal} ${pedido.cidade}'),
            const Divider(),
            const Text('Produtos:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...pedido.itens.map((p) => Text('• ${p.nome} x${p.quantidade} - R\$ ${p.subtotal.toStringAsFixed(2)}')),
            const Divider(),
            Text('Método: ${pedido.metodoPagamento}'),
            Text('Total: R\$ ${pedido.valorTotal.toStringAsFixed(2)}'),
            Text('Status: ${pedido.status}'),
            if (pedido.criadoEm != null) Text('Criado em: ${pedido.criadoEm!.day}/${pedido.criadoEm!.month}/${pedido.criadoEm!.year} às ${pedido.criadoEm!.hour}:${pedido.criadoEm!.minute.toString().padLeft(2, '0')}'),
            if (pedido.comprovativoUrl != null && pedido.comprovativoUrl!.isNotEmpty) ...[
              const Divider(),
              const Text('Comprovativo:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(pedido.comprovativoUrl!, style: const TextStyle(fontSize: 10, color: Colors.blue)),
            ],
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
      ),
    );
  }

  void _showConfirmDialog(Pedido pedido, String action) {
    String title, content, buttonText;
    IconData icon;
    Color buttonColor;

    switch (action) {
      case 'confirmado': title = 'Confirmar Pedido'; content = 'Confirmar o pagamento e aceitar o pedido?'; buttonText = 'Confirmar'; icon = Icons.check; buttonColor = Colors.green; break;
      case 'preparando': title = 'Iniciar Preparação'; content = 'Marcar o pedido como em preparação?'; buttonText = 'Preparar'; icon = Icons.inventory_2; buttonColor = Colors.blue; break;
      case 'enviado': title = 'Enviar Pedido'; content = 'Marcar o pedido como enviado?'; buttonText = 'Enviar'; icon = Icons.local_shipping; buttonColor = Colors.purple; break;
      case 'entregue': title = 'Confirmar Entrega'; content = 'Confirmar que o pedido foi entregue?'; buttonText = 'Confirmar'; icon = Icons.check_circle; buttonColor = Colors.teal; break;
      default: title = 'Cancelar Pedido'; content = 'Tem certeza que deseja cancelar este pedido?'; buttonText = 'Cancelar'; icon = Icons.close; buttonColor = Colors.red;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [Icon(icon, color: buttonColor), const SizedBox(width: 8), Text(title)]),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(pedido, action);
            },
            style: ElevatedButton.styleFrom(backgroundColor: buttonColor, foregroundColor: AppColors.white),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  void _updateStatus(Pedido pedido, String newStatus) {
    if (pedido.id == null) return;
    _pedidoController.atualizarStatusPedido(pedido.id!, newStatus);

    String message;
    switch (newStatus) {
      case 'confirmado': message = 'Pedido confirmado!'; break;
      case 'preparando': message = 'Pedido em preparação!'; break;
      case 'enviado': message = 'Pedido enviado!'; break;
      case 'entregue': message = 'Pedido entregue!'; break;
      case 'cancelado': message = 'Pedido cancelado!'; break;
      default: message = 'Status atualizado!';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
