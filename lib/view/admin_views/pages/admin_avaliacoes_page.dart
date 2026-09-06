import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/avaliacao_controller.dart';
import 'package:loahstudio/model/avaliacao_model.dart';

class AdminAvaliacoesPage extends StatefulWidget {
  const AdminAvaliacoesPage({super.key});

  @override
  State<AdminAvaliacoesPage> createState() => _AdminAvaliacoesPageState();
}

class _AdminAvaliacoesPageState extends State<AdminAvaliacoesPage> {
  String _selectedFilter = 'todos'; // 'todos' | 'aprovadas' | 'ocultas'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final AvaliacaoController _avaliacaoController = AvaliacaoController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Avaliacao> _filterAvaliacoes(List<Avaliacao> avaliacoes) {
    var result = List<Avaliacao>.from(avaliacoes);
    if (_selectedFilter == 'aprovadas') {
      result = result.where((a) => a.aprovado).toList();
    } else if (_selectedFilter == 'ocultas') {
      result = result.where((a) => !a.aprovado).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((a) =>
          a.nomeCliente.toLowerCase().contains(query) ||
          a.mensagem.toLowerCase().contains(query)).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    return StreamBuilder<List<Avaliacao>>(
      stream: _avaliacaoController.streamTodasAvaliacoes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar avaliações: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.reviews_outlined, size: 64, color: AppColors.grey),
                SizedBox(height: 16),
                Text('Carregando avaliações...', style: TextStyle(color: AppColors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        final total = snapshot.data!.length;
        final filtered = _filterAvaliacoes(snapshot.data!);

        return Column(
          children: [
            _buildAppBar(isMobile, total: total, filtrado: filtered.length),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _buildAvaliacaoCard(filtered[index], isMobile),
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
                  ? '$total avaliaç${total == 1 ? 'ão' : 'ões'}'
                  : 'A mostrar $filtrado de $total avaliações',
              style: TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: isMobile ? 10 : 12),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Pesquisar por nome ou mensagem...',
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
          Wrap(spacing: 8, runSpacing: 8, children: [
            _buildFilterChip('todos', 'Todas'),
            _buildFilterChip('aprovadas', 'Aprovadas'),
            _buildFilterChip('ocultas', 'Ocultas'),
          ]),
        ],
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
          color: isSelected ? AppColors.pinkStrong : AppColors.lightCreamBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.pinkStrong : AppColors.grey.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? AppColors.white : AppColors.brown, fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.reviews_outlined, size: 64, color: AppColors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('Nenhuma avaliação encontrada', style: TextStyle(color: AppColors.grey, fontSize: 16)),
          ],
        ),
      );

  Widget _buildEstrelas(int nota) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < nota ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 18,
      )),
    );
  }

  Widget _buildAvaliacaoCard(Avaliacao avaliacao, bool isMobile) {
    final String inicial = avaliacao.nomeCliente.isNotEmpty ? avaliacao.nomeCliente[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: isMobile ? 40 : 48,
              height: isMobile ? 40 : 48,
              decoration: BoxDecoration(color: AppColors.pinkNude.withValues(alpha: 0.3), shape: BoxShape.circle),
              child: Center(child: Text(inicial, style: const TextStyle(color: AppColors.pinkStrong, fontSize: 18, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(avaliacao.nomeCliente, style: const TextStyle(color: AppColors.brown, fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildEstrelas(avaliacao.nota),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (avaliacao.aprovado ? Colors.green : AppColors.grey).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                avaliacao.aprovado ? 'VISÍVEL' : 'OCULTA',
                style: TextStyle(color: avaliacao.aprovado ? Colors.green : AppColors.grey, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(avaliacao.mensagem, style: const TextStyle(color: AppColors.brown, fontSize: 14)),
          if (avaliacao.criadoEm != null) ...[
            const SizedBox(height: 8),
            Text(
              '${avaliacao.criadoEm!.day}/${avaliacao.criadoEm!.month}/${avaliacao.criadoEm!.year}',
              style: const TextStyle(color: AppColors.grey, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [
            TextButton.icon(
              onPressed: () => _alternarAprovacao(avaliacao),
              icon: Icon(avaliacao.aprovado ? Icons.visibility_off : Icons.visibility, size: 18),
              label: Text(avaliacao.aprovado ? 'Ocultar' : 'Mostrar'),
              style: TextButton.styleFrom(foregroundColor: avaliacao.aprovado ? Colors.orange : Colors.green),
            ),
            TextButton.icon(
              onPressed: () => _showEditDialog(avaliacao),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Editar'),
              style: TextButton.styleFrom(foregroundColor: AppColors.pinkStrong),
            ),
            TextButton.icon(
              onPressed: () => _showDeleteDialog(avaliacao),
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Eliminar'),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _alternarAprovacao(Avaliacao avaliacao) async {
    if (avaliacao.id == null) return;
    final sucesso = await _avaliacaoController.alternarAprovacao(avaliacao.id!, !avaliacao.aprovado);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sucesso
          ? (avaliacao.aprovado ? 'Avaliação ocultada.' : 'Avaliação agora visível no site.')
          : 'Não foi possível alterar. Tente novamente.'),
      backgroundColor: sucesso ? null : Colors.redAccent,
    ));
  }

  void _showDeleteDialog(Avaliacao avaliacao) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Avaliação'),
        content: Text('Tem certeza que deseja eliminar definitivamente a avaliação de ${avaliacao.nomeCliente}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (avaliacao.id == null) return;
              final sucesso = await _avaliacaoController.deletarAvaliacao(avaliacao.id!);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(sucesso ? 'Avaliação eliminada.' : 'Não foi possível eliminar. Tente novamente.'),
                backgroundColor: sucesso ? null : Colors.redAccent,
              ));
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Avaliacao avaliacao) {
    final nomeController = TextEditingController(text: avaliacao.nomeCliente);
    final mensagemController = TextEditingController(text: avaliacao.mensagem);
    int notaSelecionada = avaliacao.nota;
    bool salvando = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Editar Avaliação'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(labelText: 'Nome do cliente'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: mensagemController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Mensagem'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Nota:', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (i) => IconButton(
                      onPressed: salvando ? null : () => setDialogState(() => notaSelecionada = i + 1),
                      icon: Icon(
                        i < notaSelecionada ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: salvando ? null : () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: salvando
                  ? null
                  : () async {
                      final nome = nomeController.text.trim();
                      final mensagem = mensagemController.text.trim();
                      if (nome.isEmpty || mensagem.isEmpty || avaliacao.id == null) return;

                      setDialogState(() => salvando = true);
                      final sucesso = await _avaliacaoController.atualizarAvaliacao(
                        avaliacao.id!,
                        nomeCliente: nome,
                        mensagem: mensagem,
                        nota: notaSelecionada,
                      );
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(sucesso ? 'Avaliação atualizada.' : 'Não foi possível atualizar. Tente novamente.'),
                        backgroundColor: sucesso ? null : Colors.redAccent,
                      ));
                    },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, foregroundColor: AppColors.white),
              child: salvando
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}