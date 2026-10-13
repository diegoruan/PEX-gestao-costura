import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../errors/falha.dart';
import 'firestore_escrita.dart';

enum OrigemImagem { camera, galeria }

/// Tudo sobre fotos fica atrás desta interface: quem usa não sabe onde a
/// imagem é guardada (hoje no Firestore; amanhã pode ser outro lugar).
abstract interface class ImagemService {
  /// Abre a câmera ou a galeria e devolve a foto já comprimida (JPEG), ou
  /// `null` se o usuário desistir.
  Future<Uint8List?> escolher(OrigemImagem origem);

  /// Guarda a foto em [caminho], substituindo o que houver lá. [versao]
  /// identifica esta foto; quem for exibir passa a mesma versão para
  /// [carregar]. Lança [FalhaEnvioFoto] se não conseguir.
  Future<void> salvar({
    required String caminho,
    required int versao,
    required Uint8List bytes,
  });

  /// Devolve a foto em [caminho], ou `null` se ela não existir.
  Future<Uint8List?> carregar(String caminho, {required int versao});

  /// Apaga a foto em [caminho]. Não falha se ela não existir.
  Future<void> apagar(String caminho);
}

/// Guarda cada foto como um documento do Firestore com o JPEG em um campo
/// `Blob`. Escolhido no lugar do Firebase Storage porque o Storage exige o
/// plano pago (Blaze); o Firestore entra na cota gratuita e ainda funciona
/// offline como o resto dos dados.
class ImagemServiceFirestore implements ImagemService {
  ImagemServiceFirestore({FirebaseFirestore? firestore, ImagePicker? picker})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _picker = picker ?? ImagePicker();

  final FirebaseFirestore _firestore;
  final ImagePicker _picker;

  static const ladoMaximo = 800.0;

  /// Tentativas de qualidade JPEG, da melhor para a pior, até a foto caber.
  static const qualidades = [60, 45, 30];

  /// Um documento do Firestore tem no máximo 1 MiB; deixamos folga.
  static const tamanhoMaximoBytes = 800 * 1024;

  /// Fotos já lidas nesta sessão, por caminho + versão. Evita gastar uma
  /// leitura do Firestore toda vez que a lista é rolada.
  final _cache = <String, Uint8List>{};

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

    // Converte para JPEG (inclusive HEIC do iPhone), baixando a qualidade
    // até caber no limite do documento.
    for (final qualidade in qualidades) {
      final comprimida = await FlutterImageCompress.compressWithFile(
        arquivo.path,
        quality: qualidade,
        format: CompressFormat.jpeg,
      );
      if (comprimida != null && comprimida.length <= tamanhoMaximoBytes) {
        return comprimida;
      }
    }
    throw const Falha('A foto ficou grande demais. Tente outra foto.');
  }

  @override
  Future<void> salvar({
    required String caminho,
    required int versao,
    required Uint8List bytes,
  }) async {
    if (bytes.length > tamanhoMaximoBytes) throw const FalhaEnvioFoto();
    try {
      await aguardarEscrita(
        _firestore.doc(caminho).set({'versao': versao, 'bytes': Blob(bytes)}),
      );
    } on Falha {
      throw const FalhaEnvioFoto();
    }
    _limparCache(caminho);
    _cache[_chave(caminho, versao)] = bytes;
  }

  @override
  Future<Uint8List?> carregar(String caminho, {required int versao}) async {
    final chave = _chave(caminho, versao);
    final emCache = _cache[chave];
    if (emCache != null) return emCache;

    // Online lê do servidor; offline o Firestore devolve a cópia local.
    final documento = await _firestore.doc(caminho).get();
    final blob = documento.data()?['bytes'] as Blob?;
    if (blob == null) return null;
    final bytes = blob.bytes;
    // Só guarda em cache se for a versão pedida; uma versão antiga (foto
    // trocada em outro aparelho e ainda não sincronizada) é exibida, mas
    // será lida de novo na próxima vez.
    if (documento.data()?['versao'] == versao) _cache[chave] = bytes;
    return bytes;
  }

  @override
  Future<void> apagar(String caminho) async {
    _limparCache(caminho);
    await aguardarEscrita(_firestore.doc(caminho).delete());
  }

  String _chave(String caminho, int versao) => '$caminho#$versao';

  void _limparCache(String caminho) =>
      _cache.removeWhere((chave, _) => chave.startsWith('$caminho#'));
}
