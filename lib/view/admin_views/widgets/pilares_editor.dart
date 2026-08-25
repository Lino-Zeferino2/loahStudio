import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/model/site_config_model.dart';

class PilaresEditor extends StatelessWidget {
  final List<Pilar> pilares;
  final ValueChanged<List<Pilar>> onChanged;

  const PilaresEditor({
    super.key,
    required this.pilares,
    required this.onChanged,
  });

  Future<void> _abrirFormulario(BuildContext context, {Pilar? pilarExistente, int? index}) async {
    final tituloCtrl = TextEditingController(text: pilarExistente?.titulo ?? '');
    final descricaoCtrl = TextEditingController(text: pilarExistente?.descricao ?? '');

    final resultado = await showModalBottomSheet<Pilar>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  pilarExistente == null ? 'Adicionar Pilar' : 'Editar Pilar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tituloCtrl,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    labelStyle: TextStyle(color: AppColors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.pinkStrong),
                    ),
                  ),
                  style: TextStyle(color: AppColors.brown),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descricaoCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    labelStyle: TextStyle(color: AppColors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.pinkStrong),
                    ),
                  ),
                  style: TextStyle(color: AppColors.brown),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.grey.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Cancelar', style: TextStyle(color: AppColors.brown)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (tituloCtrl.text.trim().isEmpty) return;
                          Navigator.pop(
                            ctx,
                            Pilar(
                              titulo: tituloCtrl.text.trim(),
                              descricao: descricaoCtrl.text.trim(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pinkStrong,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Guardar', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (resultado == null) return;

    final novaLista = List<Pilar>.from(pilares);
    if (index != null) {
      novaLista[index] = resultado;
    } else {
      novaLista.add(resultado);
    }
    onChanged(novaLista);
  }

  Future<void> _confirmarRemocao(BuildContext context, int index) async {
    final confirmar = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 36),
              const SizedBox(height: 12),
              Text(
                'Remover este pilar?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.brown),
              ),
              const SizedBox(height: 4),
              Text(
                pilares[index].titulo,
                style: TextStyle(color: AppColors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: Text('Cancelar', style: TextStyle(color: AppColors.brown)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Remover', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmar == true) {
      final novaLista = List<Pilar>.from(pilares)..removeAt(index);
      onChanged(novaLista);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pilares.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                'Ainda não há pilares. Adiciona o primeiro.',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pilares.length,
            onReorder: (oldIndex, newIndex) {
              final novaLista = List<Pilar>.from(pilares);
              if (newIndex > oldIndex) newIndex -= 1;
              final item = novaLista.removeAt(oldIndex);
              novaLista.insert(newIndex, item);
              onChanged(novaLista);
            },
            itemBuilder: (context, index) {
              final pilar = pilares[index];
              return Container(
                key: ValueKey('pilar_$index${pilar.titulo}'),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.drag_indicator, color: AppColors.grey.withValues(alpha: 0.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pilar.titulo.isEmpty ? '(sem título)' : pilar.titulo,
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.brown),
                          ),
                          if (pilar.descricao.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              pilar.descricao,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: AppColors.grey),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _abrirFormulario(context, pilarExistente: pilar, index: index),
                      icon: Icon(Icons.edit_outlined, color: AppColors.pinkStrong, size: 20),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      onPressed: () => _confirmarRemocao(context, index),
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      tooltip: 'Remover',
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _abrirFormulario(context),
          icon: Icon(Icons.add, color: AppColors.pinkStrong),
          label: Text('Adicionar Pilar', style: TextStyle(color: AppColors.pinkStrong)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            side: BorderSide(color: AppColors.pinkStrong),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}