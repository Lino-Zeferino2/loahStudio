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
  bool isUploadingGaleriaImage = false;
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

  Future<String?> _pickAndUploadImagem({required String pastaStorage}) async {
    final XFile? arquivo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (arquivo == null) return null;

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

  Future<String?> selecionarEEnviarHeroImagem() async {
    isUploadingHeroImage = true;
    errorMessage = null;
    notifyListeners();
    try {
      final url = await _pickAndUploadImagem(pastaStorage: 'hero');
      if (url != null) {
        config = config.copyWith(heroImagemUrl: url);
      }
      return url;
    } catch (e) {
      errorMessage = 'Erro ao enviar imagem: $e';
      return null;
    } finally {
      isUploadingHeroImage = false;
      notifyListeners();
    }
  }

  Future<String?> selecionarEEnviarGaleriaImagem() async {
    isUploadingGaleriaImage = true;
    errorMessage = null;
    notifyListeners();
    try {
      final url = await _pickAndUploadImagem(pastaStorage: 'galeria');
      if (url != null) {
        config = config.copyWith(galeriaImagemUrl: url);
      }
      return url;
    } catch (e) {
      errorMessage = 'Erro ao enviar imagem: $e';
      return null;
    } finally {
      isUploadingGaleriaImage = false;
      notifyListeners();
    }
  }
}