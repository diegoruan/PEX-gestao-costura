import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../errors/falha.dart';

enum OrigemImagem { camera, galeria }

/// Tudo sobre fotos fica atrás desta interface: quem usa não sabe se a imagem
/// vai para o Firebase Storage ou para outro lugar.
abstract interface class ImagemService {
  /// Abre a câmera ou a galeria e devolve a foto já comprimida (JPEG), ou
  /// `null` se o usuário desistir.
  Future<Uint8List?> escolher(OrigemImagem origem);

  /// Envia a foto para [caminho], substituindo o que houver lá, e devolve a
  /// URL pública. Lança [FalhaEnvioFoto] se não conseguir.
  Future<String> enviar({required String caminho, required Uint8List bytes});

  /// Apaga a foto em [caminho]. Não falha se ela não existir.
  Future<void> apagar(String caminho);
}

class ImagemServiceFirebase implements ImagemService {
  ImagemServiceFirebase({FirebaseStorage? storage, ImagePicker? picker})
    : _storage = storage ?? FirebaseStorage.instance,
      _picker = picker ?? ImagePicker();

  final FirebaseStorage _storage;
  final ImagePicker _picker;

  static const ladoMaximo = 1024.0;
  static const qualidadeJpeg = 70;

  /// Sem internet o Storage fica tentando por vários minutos; preferimos
  /// desistir antes e deixar a pessoa salvar o pedido sem foto.
  static const limiteEnvio = Duration(seconds: 30);

  @override
  Future<Uint8List?> escolher(OrigemImagem origem) async {
    final XFile? arquivo;
    try {
      // O redimensionamento fica com o image_picker porque ele limita o
      // LADO MAIOR; o minWidth/minHeight do flutter_image_compress limita o
      // menor e deixaria a foto maior do que o necessário.
      arquivo = await _picker.pickImage(
        source: origem == OrigemImagem.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: ladoMaximo,
        maxHeight: ladoMaximo,
      );
    } on PlatformException catch (e) {
      throw Falha(switch (e.code) {
        'camera_access_denied' =>
          'Permita o acesso à câmera nas configurações do celular.',
        'photo_access_denied' =>
          'Permita o acesso às fotos nas configurações do celular.',
        _ => 'Não foi possível abrir a foto. Tente de novo.',
      });
    }
    if (arquivo == null) return null;

    // Converte para JPEG (inclusive HEIC do iPhone) com qualidade reduzida.
    final comprimida = await FlutterImageCompress.compressWithFile(
      arquivo.path,
      quality: qualidadeJpeg,
      format: CompressFormat.jpeg,
    );
    return comprimida ?? await arquivo.readAsBytes();
  }

  @override
  Future<String> enviar({
    required String caminho,
    required Uint8List bytes,
  }) async {
    final referencia = _storage.ref(caminho);
    final tarefa = referencia.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    try {
      await tarefa.timeout(limiteEnvio);
      return await referencia.getDownloadURL();
    } on TimeoutException {
      await tarefa.cancel();
      throw const FalhaEnvioFoto();
    } on FirebaseException {
      throw const FalhaEnvioFoto();
    }
  }

  @override
  Future<void> apagar(String caminho) async {
    try {
      await _storage.ref(caminho).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
