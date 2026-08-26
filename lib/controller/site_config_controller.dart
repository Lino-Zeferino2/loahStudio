import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loahstudio/model/site_config_model.dart';

class SiteConfigController extends ChangeNotifier {
  static const String _collection = 'configuracoes';
  static const String _docId = 'site_config';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  SiteConfigModel config = const SiteConfigModel();

  bool isLoading = false;
  bool isSaving = false;
  bool isUploadingHeroImage = false;
  bool isUploadingGaleriaImagens = false;
  String? errorMessage;

  DocumentReference<Map<String, dynamic>> get _docRef =>
      _firestore.collection(_collection).doc(_docId);

  Future<void> carregarConfiguracoes() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final doc = await _docRef.get();
      if (doc.exists) {
        config = SiteConfigModel.fromMap(doc.data() ?? {});
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar configurações: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> salvarConfiguracoes(SiteConfigModel novaConfig) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _docRef.set(novaConfig.toMap(), SetOptions(merge: true));
      config = novaConfig;
      return true;
    } catch (e) {
      errorMessage = 'Erro ao guardar configurações: $e';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<String> _enviarArquivo(XFile arquivo, String pastaStorage) async {
    final nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}_${arquivo.name}';
    final ref = _storage.ref().child('site_config/$pastaStorage/$nomeArquivo');

    if (kIsWeb) {
      final Uint8List bytes = await arquivo.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      await ref.putFile(File(arquivo.path));
    }

    return await ref.getDownloadURL();
  }

  /// Upload de imagem única (usado no Hero).
  Future<String?> selecionarEEnviarHeroImagem() async {
    isUploadingHeroImage = true;
    errorMessage = null;
    notifyListeners();
    try {
      final XFile? arquivo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (arquivo == null) return null;

      final url = await _enviarArquivo(arquivo, 'hero');
      config = config.copyWith(heroImagemUrl: url);
      return url;
    } catch (e) {
      errorMessage = 'Erro ao enviar imagem: $e';
      return null;
    } finally {
      isUploadingHeroImage = false;
      notifyListeners();
    }
  }

  /// Upload de múltiplas imagens (usado na Galeria). Adiciona à lista existente.
  Future<void> selecionarEEnviarGaleriaImagens() async {
    isUploadingGaleriaImagens = true;
    errorMessage = null;
    notifyListeners();
    try {
      final List<XFile> arquivos = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (arquivos.isEmpty) return;

      final List<String> novasUrls = [];
      for (final arquivo in arquivos) {
        final url = await _enviarArquivo(arquivo, 'galeria');
        novasUrls.add(url);
      }

      config = config.copyWith(
        galeriaImagens: [...config.galeriaImagens, ...novasUrls],
      );
    } catch (e) {
      errorMessage = 'Erro ao enviar imagens: $e';
    } finally {
      isUploadingGaleriaImagens = false;
      notifyListeners();
    }
  }

  /// Remove uma imagem da galeria (da lista e, se possível, do Storage).
  Future<void> removerGaleriaImagem(String url) async {
    final novaLista = List<String>.from(config.galeriaImagens)..remove(url);
    config = config.copyWith(galeriaImagens: novaLista);
    notifyListeners();
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {
      // Ignora falha ao apagar do Storage (ex: ficheiro já não existe).
    }
  }
}