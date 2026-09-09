import 'package:flutter/material.dart';
import 'package:loahstudio/controller/favoritos_controller.dart';
import 'package:loahstudio/model/favorito_model.dart';
import 'package:loahstudio/view/user_views/produtos/produtos_page.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  final FavoritosController _ctrl = FavoritosController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos'), backgroundColor: Colors.deepPurple),
      body: StreamBuilder<List<FavoritoModel>>(
        stream: _ctrl.streamFavoritos(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final lista = snap.data!;
          if (lista.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Ainda não tem favoritos.', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProdutosPage())),
                    child: const Text('Ver Produtos'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final f = lista[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: (f.imagemUrl != null && f.imagemUrl!.isNotEmpty)
                      ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(f.imagemUrl!, width: 60, height: 60, fit: BoxFit.cover))
                      : const Icon(Icons.image_not_supported, size: 50),
                  title: Text(f.nome),
                  subtitle: Text('${f.tipo.toUpperCase()} • €${f.preco?.toStringAsFixed(2) ?? '0.00'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          await _ctrl.remover(f.id);
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removido dos favoritos')));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => f.tipo == 'produto' ? const ProdutosPage() : const ServicosPage()));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
