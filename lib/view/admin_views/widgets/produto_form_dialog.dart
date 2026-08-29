import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/controller/produtos_controller.dart';
import 'package:loahstudio/model/produto_model.dart';

Future<void> showProdutoFormDialog(
  BuildContext context, {
  Produto? produto,
  required List<String> categoriasExistentes,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => ProdutoFormDialog(
      produto: produto,
      categoriasExistentes: categoriasExistentes,
    ),
  );
}

class ProdutoFormDialog extends StatefulWidget {
  final Produto? produto;
  final List<String> categoriasExistentes;

  const ProdutoFormDialog({
    super.key,
    this.produto,
    required this.categoriasExistentes,
  });

  @override
  State<ProdutoFormDialog> createState() => _ProdutoFormDialogState();
}

class _ProdutoFormDialogState extends State<ProdutoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ProdutosController();
  late final TextEditingController _marcaController;
  final _picker = ImagePicker();
  
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _precoController;
  late final TextEditingController _estoqueController;
  late final TextEditingController _estoqueMinimoController;
  late final TextEditingController _categoriaController;

  XFile? _imagemSelecionada;
  String? _imagemUrlAtual;
  bool _disponivel = true;
  bool _isSaving = false;
  bool _destaque = false;
  bool get _isEdicao => widget.produto != null;

  @override
  void initState() {
    super.initState();
    final p = widget.produto;
    _nomeController = TextEditingController(text: p?.nome ?? '');
    _descricaoController = TextEditingController(text: p?.descricao ?? '');
    _precoController = TextEditingController(text: p != null ? p.preco.toStringAsFixed(2) : '');
    _estoqueController = TextEditingController(text: p != null ? '${p.estoque}' : '');
    _estoqueMinimoController = TextEditingController(text: p != null ? '${p.estoqueMinimo}' : '5');
    _categoriaController = TextEditingController(text: p?.categoria ?? '');
    _imagemUrlAtual = p?.imagemUrl;
    _disponivel = p?.disponivel ?? true;
    _marcaController = TextEditingController(text: p?.marca ?? '');
    _disponivel = p?.disponivel ?? true;
    _destaque = p?.destaque ?? false;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _estoqueController.dispose();
    _estoqueMinimoController.dispose();
    _categoriaController.dispose();
    _marcaController.dispose();
    super.dispose();
  }

  Future<void> _escolherImagem() async {
    try {
      final imagem = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (imagem != null) {
        setState(() => _imagemSelecionada = imagem);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final preco = double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0.0;
    final estoque = int.tryParse(_estoqueController.text) ?? 0;
    final estoqueMinimo = int.tryParse(_estoqueMinimoController.text) ?? 5;

    bool sucesso;
    if (_isEdicao) {
    sucesso = await _controller.updateProduto(
  widget.produto!.id!,
  {
    'nome': _nomeController.text.trim(),
    'marca': _marcaController.text.trim(),
    'descricao': _descricaoController.text.trim(),
    'categoria': _categoriaController.text.trim(),
    'preco': preco,
    'estoque': estoque,
    'estoqueMinimo': estoqueMinimo,
    'disponivel': _disponivel,
    'destaque': _destaque,
  },
  imagem: _imagemSelecionada,
);
    } else {
      final novoProduto = Produto(
  nome: _nomeController.text.trim(),
  marca: _marcaController.text.trim(),
  descricao: _descricaoController.text.trim(),
  categoria: _categoriaController.text.trim(),
  preco: preco,
  estoque: estoque,
  estoqueMinimo: estoqueMinimo,
  disponivel: _disponivel,
  destaque: _destaque,
);
      sucesso = await _controller.addProduto(novoProduto, imagem: _imagemSelecionada);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (sucesso) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdicao ? 'Produto atualizado!' : 'Produto criado!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao guardar produto. Tenta novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 80, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePicker(isMobile),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nomeController,
                        decoration: _inputDecoration('Nome do produto', Icons.shopping_bag_outlined),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Insere o nome do produto' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _marcaController,
                        decoration: _inputDecoration('Marca (opcional)', Icons.local_offer_outlined),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descricaoController,

                        maxLines: 3,
                        decoration: _inputDecoration('Descrição', Icons.description_outlined),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Insere uma descrição' : null,
                      ),
                      const SizedBox(height: 14),
                      Autocomplete<String>(
                        optionsBuilder: (value) {
                          if (value.text.isEmpty) return widget.categoriasExistentes;
                          return widget.categoriasExistentes.where((c) =>
                              c.toLowerCase().contains(value.text.toLowerCase()));
                        },
                        initialValue: TextEditingValue(text: _categoriaController.text),
                        onSelected: (v) => _categoriaController.text = v,
                        fieldViewBuilder: (context, fieldController, focusNode, onSubmit) {
                          fieldController.text = _categoriaController.text;
                          fieldController.addListener(() {
                            _categoriaController.text = fieldController.text;
                          });
                          return TextFormField(
                            controller: fieldController,
                            focusNode: focusNode,
                            decoration: _inputDecoration('Categoria', Icons.category_outlined),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Insere a categoria' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _precoController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _inputDecoration('Preço', Icons.euro).copyWith(prefixText: '€ '),
                              validator: (v) {
                                final parsed = double.tryParse((v ?? '').replaceAll(',', '.'));
                                if (parsed == null || parsed <= 0) return 'Preço inválido';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _estoqueController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('Estoque', Icons.inventory_2_outlined),
                              validator: (v) {
                                final parsed = int.tryParse(v ?? '');
                                if (parsed == null || parsed < 0) return 'Estoque inválido';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _estoqueMinimoController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Estoque mínimo (alerta)', Icons.warning_amber_outlined),
                        validator: (v) {
                          final parsed = int.tryParse(v ?? '');
                          if (parsed == null || parsed < 0) return 'Valor inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                    SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Disponível para venda',
                            style: TextStyle(color: AppColors.brown, fontSize: 14)),
                        value: _disponivel,
                        activeThumbColor: Colors.green,
                        onChanged: (v) => setState(() => _disponivel = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Mostrar em "Em Destaque"',
                            style: TextStyle(color: AppColors.brown, fontSize: 14)),
                        subtitle: const Text('Aparece na secção de destaque da loja',
                            style: TextStyle(color: AppColors.grey, fontSize: 12)),
                        value: _destaque,
                        activeThumbColor: AppColors.pinkStrong,
                        onChanged: (v) => setState(() => _destaque = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.pinkNude.withValues(alpha: 0.25),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(_isEdicao ? Icons.edit_outlined : Icons.add_box_outlined, color: AppColors.pinkStrong),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isEdicao ? 'Editar Produto' : 'Novo Produto',
              style: const TextStyle(color: AppColors.brown, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.grey),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(bool isMobile) {
    return Center(
      child: GestureDetector(
        onTap: _isSaving ? null : _escolherImagem,
        child: Container(
          width: double.infinity,
          height: isMobile ? 160 : 200,
          decoration: BoxDecoration(
            color: AppColors.lightCreamBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.25)),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildImagePreview(),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imagemSelecionada != null) {
      return FutureBuilder<Uint8List>(
        future: _imagemSelecionada!.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Image.memory(snapshot.data!, fit: BoxFit.cover, width: double.infinity);
        },
      );
    }
    if (_imagemUrlAtual != null && _imagemUrlAtual!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(_imagemUrlAtual!, fit: BoxFit.cover),
          _buildTrocarImagemOverlay(),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.grey.withValues(alpha: 0.6)),
        const SizedBox(height: 8),
        Text('Toca para carregar uma imagem',
            style: TextStyle(color: AppColors.grey.withValues(alpha: 0.8), fontSize: 13)),
      ],
    );
  }

  Widget _buildTrocarImagemOverlay() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
        ),
      ),
      child: const Text('Toca para trocar a imagem',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.grey.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkStrong,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                  : Text(_isEdicao ? 'Guardar' : 'Criar Produto'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.grey),
      filled: true,
      fillColor: AppColors.lightCreamBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}