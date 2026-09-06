import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.grey),
                SizedBox(height: 16),
                Text('Carregando pedidos...', style: TextStyle(color: AppColors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        final total = snapshot.data!.length;
        final filteredPedidos = _filterPedidos(snapshot.data!);

        return Column(
          children: [
            _buildAppBar(isMobile, total: total, filtrado: filteredPedidos.length),
            Expanded(
              child: filteredPedidos.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      itemCount: filteredPedidos.length,
                      itemBuilder: (context, index) => _buildCompraCard(filteredPedidos[index], isMobile),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(bool isMobile, {required int total, required int filtrado}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              filtrado == total
                  ? '$total pedido${total == 1 ? '' : 's'}'
                  : 'A mostrar $filtrado de $total pedidos',
              style: TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: isMobile ? 10 : 12),
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
          isMobile
              ? _buildFiltroDropdown()
              : Wrap(spacing: 8, runSpacing: 8, children: [
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
            if (_selectedStartDate != null || _selectedEndDate != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() {
                  _selectedStartDate = null;
                  _selectedEndDate = null;
                }),
                icon: const Icon(Icons.clear, color: Colors.redAccent),
                tooltip: 'Limpar datas',
              ),
            ],
          ]),
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
        items: const [
          DropdownMenuItem(value: 'todos', child: Text('Todos os status')),
          DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
          DropdownMenuItem(value: 'confirmado', child: Text('Confirmado')),
          DropdownMenuItem(value: 'preparando', child: Text('Preparando')),
          DropdownMenuItem(value: 'enviado', child: Text('Enviado')),
          DropdownMenuItem(value: 'entregue', child: Text('Entregue')),
          DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
        ],
        onChanged: (value) {
          if (value != null) setState(() => _selectedFilter = value);
        },
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _corStatus(value) : AppColors.lightCreamBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _corStatus(value) : AppColors.grey.withValues(alpha: 0.3)),
        ),
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
        child: Row(children: [
          const Icon(Icons.calendar_today, color: AppColors.grey, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(date != null ? '${date.day}/${date.month}/${date.year}' : label, style: TextStyle(color: date != null ? AppColors.brown : AppColors.grey, fontSize: 13))),
        ]),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('Nenhuma compra encontrada', style: TextStyle(color: AppColors.grey, fontSize: 16)),
          ],
        ),
      );

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
    final statusColor = _corStatus(status);
    final statusIcon = _iconeStatus(status);
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
            ? Column(children: [
                Row(children: [const Icon(Icons.shopping_bag, color: AppColors.pinkStrong, size: 16), const SizedBox(width: 6), Expanded(child: Text(_getProdutosString(pedido), style: const TextStyle(color: AppColors.brown, fontSize: 13), overflow: TextOverflow.ellipsis))]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.calendar_today, color: AppColors.grey, size: 16),
                  const SizedBox(width: 6),
                  Text(pedido.criadoEm != null ? '${pedido.criadoEm!.day}/${pedido.criadoEm!.month}' : '--/--', style: const TextStyle(color: AppColors.brown, fontSize: 13)),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, color: AppColors.grey, size: 16),
                  const SizedBox(width: 6),
                  Text(pedido.metodoPagamento, style: const TextStyle(color: AppColors.brown, fontSize: 13)),
                ]),
              ])
            : Row(children: [
                Expanded(child: Row(children: [const Icon(Icons.shopping_bag, color: AppColors.pinkStrong, size: 18), const SizedBox(width: 6), Expanded(child: Text(_getProdutosString(pedido), style: const TextStyle(color: AppColors.brown, fontSize: 14), overflow: TextOverflow.ellipsis))])),
                Expanded(child: Row(children: [const Icon(Icons.calendar_today, color: AppColors.grey, size: 18), const SizedBox(width: 6), Text(pedido.criadoEm != null ? '${pedido.criadoEm!.day}/${pedido.criadoEm!.month}/${pedido.criadoEm!.year}' : '--/--/----', style: const TextStyle(color: AppColors.brown, fontSize: 14))])),
                Expanded(child: Row(children: [const Icon(Icons.payments, color: AppColors.grey, size: 18), const SizedBox(width: 6), Text(pedido.metodoPagamento, style: const TextStyle(color: AppColors.brown, fontSize: 14))])),
              ]),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total:', style: TextStyle(color: AppColors.brown, fontSize: 14)), Text('${valor.toStringAsFixed(2).replaceAll('.', ',')} €', style: const TextStyle(color: AppColors.pinkStrong, fontSize: 16, fontWeight: FontWeight.bold))])),
        if (pedido.aguardaComprovativo) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.warning_amber, color: Colors.orange, size: 16), const SizedBox(width: 8), const Expanded(child: Text('Aguardando comprovativo de pagamento', style: TextStyle(color: Colors.orange, fontSize: 12)))])),
        ],
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _abrirGestaoPedido(pedido),
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Gerir pedido'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, foregroundColor: AppColors.white),
          ),
        ),
      ]),
    );
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'confirmado':
        return Colors.green;
      case 'preparando':
        return Colors.blue;
      case 'enviado':
        return Colors.purple;
      case 'entregue':
        return Colors.teal;
      case 'cancelado':
        return Colors.red;
      default:
        return AppColors.grey;
    }
  }

  IconData _iconeStatus(String status) {
    switch (status) {
      case 'pendente':
        return Icons.hourglass_empty;
      case 'confirmado':
        return Icons.payments;
      case 'preparando':
        return Icons.inventory_2;
      case 'enviado':
        return Icons.local_shipping;
      case 'entregue':
        return Icons.check_circle;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _abrirGestaoPedido(Pedido pedido) {
    showDialog(
      context: context,
      builder: (_) => _PedidoManageDialog(pedido: pedido, controller: _pedidoController),
    );
  }
}

/// Dialog único de gestão de um pedido: detalhes, seleção de novo status
/// com confirmação, e comprovativo (visualizar em ecrã cheio ou carregar
/// se ainda não existir). O Firestore stream da tela principal atualiza-se
/// sozinho quando este dialog grava algo — não é preciso callback de volta.
class _PedidoManageDialog extends StatefulWidget {
  final Pedido pedido;
  final PedidoController controller;

  const _PedidoManageDialog({required this.pedido, required this.controller});

  @override
  State<_PedidoManageDialog> createState() => _PedidoManageDialogState();
}

class _PedidoManageDialogState extends State<_PedidoManageDialog> {
  late String _statusSelecionado;
  bool _salvandoStatus = false;
  bool _enviandoComprovativo = false;

  static const List<String> _todosStatus = ['pendente', 'confirmado', 'preparando', 'enviado', 'entregue', 'cancelado'];

  @override
  void initState() {
    super.initState();
    _statusSelecionado = widget.pedido.status;
  }

  List<String> get _opcoesStatus {
    return _todosStatus.where((s) {
      if (s == widget.pedido.status) return true;
      if (s == 'cancelado' && !widget.pedido.podeCancelar) return false;
      return true;
    }).toList();
  }

  Future<void> _confirmarMudancaStatus() async {
    final pedido = widget.pedido;
    if (_statusSelecionado == pedido.status || pedido.id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar alteração'),
        content: Text('Mudar o status de "${pedido.status}" para "$_statusSelecionado"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, foregroundColor: AppColors.white),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _salvandoStatus = true);
    final sucesso = await widget.controller.atualizarStatusPedido(pedido.id!, _statusSelecionado);
    if (!mounted) return;
    setState(() => _salvandoStatus = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sucesso ? 'Status atualizado para "$_statusSelecionado".' : 'Não foi possível atualizar o status. Tente novamente.'),
      backgroundColor: sucesso ? null : Colors.redAccent,
    ));

    // Se falhou, volta o dropdown para o status real para não mentir na UI.
    if (!sucesso) setState(() => _statusSelecionado = pedido.status);
  }

  Future<void> _carregarComprovativo() async {
    final pedido = widget.pedido;
    if (pedido.id == null) return;

    final picker = ImagePicker();
    final XFile? arquivo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (arquivo == null) return;

    final Uint8List bytes = await arquivo.readAsBytes();
    if (!mounted) return;

    setState(() => _enviandoComprovativo = true);
    final sucesso = await widget.controller.enviarComprovativoAdmin(pedido.id!, pedido.clienteId, bytes);
    if (!mounted) return;
    setState(() => _enviandoComprovativo = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sucesso ? 'Comprovativo carregado.' : 'Não foi possível carregar o comprovativo. Tente novamente.'),
      backgroundColor: sucesso ? null : Colors.redAccent,
    ));
  }

  void _abrirComprovativoEmEcraCheio(String url) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _FullScreenImageViewer(imageUrl: url)));
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;
    final bool bloqueado = pedido.isFinalizado;

    return AlertDialog(
      title: Text('Pedido #${pedido.id != null ? pedido.id!.substring(0, 6).toUpperCase() : '---'}'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pedido.clienteNome, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Email: ${pedido.clienteEmail}'),
              Text('Telefone: ${pedido.clienteTelefone}'),
              const Divider(),
              const Text('Morada:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${pedido.morada}, ${pedido.codigoPostal} ${pedido.cidade}'),
              const Divider(),
              const Text('Produtos:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...pedido.itens.map((p) => Text('• ${p.nome} x${p.quantidade} - ${p.subtotal.toStringAsFixed(2)} €')),
              const Divider(),
              Text('Método: ${pedido.metodoPagamento}'),
              Text('Total: ${pedido.valorTotal.toStringAsFixed(2)} €'),
              if (pedido.criadoEm != null)
                Text('Criado em: ${pedido.criadoEm!.day}/${pedido.criadoEm!.month}/${pedido.criadoEm!.year} às ${pedido.criadoEm!.hour}:${pedido.criadoEm!.minute.toString().padLeft(2, '0')}'),

              const Divider(),
              const Text('Alterar status:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (bloqueado)
                Text('Pedido finalizado ("${pedido.status}") — status não pode mais ser alterado.', style: const TextStyle(color: AppColors.grey, fontSize: 13))
              else
                Row(children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: AppColors.lightCreamBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.grey.withValues(alpha: 0.3))),
                      child: DropdownButton<String>(
                        value: _statusSelecionado,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: _opcoesStatus.map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1)))).toList(),
                        onChanged: _salvandoStatus ? null : (v) { if (v != null) setState(() => _statusSelecionado = v); },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (_salvandoStatus || _statusSelecionado == pedido.status) ? null : _confirmarMudancaStatus,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, foregroundColor: AppColors.white),
                    child: _salvandoStatus
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                        : const Text('Confirmar'),
                  ),
                ]),

              const Divider(),
              const Text('Comprovativo:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (pedido.comprovativoUrl != null && pedido.comprovativoUrl!.isNotEmpty)
                GestureDetector(
                  onTap: () => _abrirComprovativoEmEcraCheio(pedido.comprovativoUrl!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      pedido.comprovativoUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: 160, color: AppColors.lightCreamBg, alignment: Alignment.center, child: const Icon(Icons.broken_image, color: AppColors.grey)),
                    ),
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _enviandoComprovativo ? null : _carregarComprovativo,
                  icon: _enviandoComprovativo
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.upload_file),
                  label: Text(_enviandoComprovativo ? 'A carregar...' : 'Carregar comprovativo'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.pinkStrong, minimumSize: const Size(double.infinity, 44)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
      ],
    );
  }
}

/// Visualizador de imagem em ecrã cheio, com zoom (pinch/scroll) via
/// InteractiveViewer. Usado para mostrar o comprovativo bem visível.
class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white, size: 64),
          ),
        ),
      ),
    );
  }
}