import 'package:loahstudio/model/carrinho_item_model.dart';

/// Regras de negócio do carrinho. Propositadamente sem nada de UI
/// (sem BuildContext, sem widgets) para poder ser testado isoladamente
/// e reutilizado por qualquer tela que precise dos totais do carrinho.
class CarrinhoController {
  /// Soma os subtotais reais (preço da BD x quantidade) de todos os itens.
  double calcularTotal(List<CarrinhoItem> itens) {
    return itens.fold(0.0, (soma, item) => soma + item.subtotal);
  }

  /// Número total de artigos (soma das quantidades, não do nº de linhas).
  int totalArtigos(List<CarrinhoItem> itens) {
    return itens.fold(0, (soma, item) => soma + item.quantidade);
  }

  String formatarPreco(double valor) => '€${valor.toStringAsFixed(2)}';
}