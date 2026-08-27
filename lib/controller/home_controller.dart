import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:loahstudio/model/avaliacao_model.dart';
import 'package:loahstudio/model/produto_model.dart';
import 'package:loahstudio/model/servico_model.dart';
import 'package:loahstudio/model/site_config_model.dart';

class HomeController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SiteConfigModel config = const SiteConfigModel();
  List<Servico> servicosDestaque = [];
  List<Produto> produtosDestaque = [];
  List<Avaliacao> avaliacoes = [];

  bool isLoading = true;
  bool isSubmittingAvaliacao = false;
  String? errorMessage;

  Future<void> carregarDados() async {
    isLoading = true;
    notifyListeners();

    await Future.wait([
      _carregarConfig(),
      _carregarServicos(),
      _carregarProdutos(),
      _carregarAvaliacoes(),
    ]);

    isLoading = false;
    notifyListeners();
  }

  Future<void> _carregarConfig() async {
    try {
      final doc = await _firestore.collection('configuracoes').doc('site_config').get();
      if (doc.exists) {
        config = SiteConfigModel.fromMap(doc.data() ?? {});
      }
    } catch (e) {
      // Em caso de erro mantém-se o SiteConfigModel() por defeito;
      // cada widget aplica o texto estático de fallback (HomeDefaults).
      debugPrint('Erro ao carregar configuracoes: $e');
    }
  }

  Future<void> _carregarServicos() async {
    try {
      final snap = await _firestore
          .collection('servicos')
          .where('disponivel', isEqualTo: true)
          .limit(6)
          .get();
      servicosDestaque = snap.docs.map((d) => Servico.fromDoc(d)).toList();
    } catch (e) {
      debugPrint('Erro ao carregar servicos: $e');
      servicosDestaque = [];
    }
  }

  Future<void> _carregarProdutos() async {
    try {
      final snap = await _firestore
          .collection('produtos')
          .where('disponivel', isEqualTo: true)
          .limit(8)
          .get();
      produtosDestaque = snap.docs.map((d) => Produto.fromDoc(d)).toList();
    } catch (e) {
      debugPrint('Erro ao carregar produtos: $e');
      produtosDestaque = [];
    }
  }

  Future<void> _carregarAvaliacoes() async {
    try {
      final snap = await _firestore
          .collection('avaliacoes')
          .where('aprovado', isEqualTo: true)
          .orderBy('criadoEm', descending: true)
          .limit(10)
          .get();
      avaliacoes = snap.docs.map((d) => Avaliacao.fromDoc(d)).toList();
    } catch (e) {
      debugPrint('Erro ao carregar avaliacoes: $e');
      avaliacoes = [];
    }
  }

  Future<bool> enviarAvaliacao({
    required String nome,
    required String mensagem,
    required int nota,
  }) async {
    isSubmittingAvaliacao = true;
    notifyListeners();
    try {
      final novaAvaliacao = Avaliacao(
        nomeCliente: nome,
        mensagem: mensagem,
        nota: nota,
        aprovado: true,
        criadoEm: DateTime.now(),
      );
      final docRef = await _firestore.collection('avaliacoes').add(novaAvaliacao.toMap());
      avaliacoes = [novaAvaliacao.copyWith(id: docRef.id), ...avaliacoes];
      return true;
    } catch (e) {
      errorMessage = 'Erro ao enviar avaliação: $e';
      debugPrint(errorMessage);
      return false;
    } finally {
      isSubmittingAvaliacao = false;
      notifyListeners();
    }
  }
}