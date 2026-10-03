import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/falha.dart';
import '../../../core/services/firestore_escrita.dart';
import '../../../core/services/imagem_service.dart';
import '../domain/pedido.dart';

/// Único ponto do app que acessa os pedidos, em
/// `usuarios/{uid}/pedidos/{pedidoId}`. A foto fica à parte, em
/// `usuarios/{uid}/fotos/{pedidoId}` (via [ImagemService]), para a lista de
/// pedidos não baixar todas as imagens de uma vez.
class PedidoRepository {
  PedidoRepository({
    required this._imagemService,
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final ImagemService _imagemService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  // Lido a cada chamada (e não guardado no construtor) porque o repository
  // vive o app inteiro e o usuário pode sair e entrar com outra conta.
  String get _uid {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) throw Falha.sessaoExpirada;
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _pedidos =>
      _firestore.collection('usuarios').doc(_uid).collection('pedidos');

  String _caminhoFoto(String pedidoId) => 'usuarios/$_uid/fotos/$pedidoId';

  /// Pedidos pendentes, entrega mais próxima primeiro.
  Stream<List<Pedido>> observarPendentes() =>
      _observar(StatusPedido.pendente, Pedido.compararPorEntrega);

  /// Pedidos finalizados, mais recentes primeiro. Base do histórico e do
  /// fechamento mensal.
  Stream<List<Pedido>> observarFinalizados() =>
      _observar(StatusPedido.finalizado, Pedido.compararPorFinalizacao);

  // Filtra por um único campo e ordena em memória: where + orderBy em campos
  // diferentes exigiria um índice composto no Firestore.
  Stream<List<Pedido>> _observar(
    StatusPedido status,
    Comparator<Pedido> ordem,
  ) {
    final Query<Map<String, dynamic>> query;
    try {
      query = _pedidos.where('status', isEqualTo: status.name);
    } on Falha catch (e) {
      return Stream.error(e);
    }

    return query
        .snapshots()
        .map(
          (snap) =>
              [for (final doc in snap.docs) Pedido.fromMap(doc.id, doc.data())]
                ..sort(ordem),
        )
        .transform(
          StreamTransformer.fromHandlers(
            handleError: (erro, stackTrace, sink) => sink.addError(
              erro is FirebaseException ? Falha.firestore(erro) : erro,
              stackTrace,
            ),
          ),
        );
  }

  /// Foto do pedido, ou `null` se ele não tiver.
  Future<Uint8List?> carregarFoto(Pedido pedido) async {
    final versao = pedido.fotoVersao;
    if (versao == null) return null;
    return _imagemService.carregar(_caminhoFoto(pedido.id), versao: versao);
  }

  /// A foto é salva antes do pedido: se ela falhar ([FalhaEnvioFoto]), nada
  /// é gravado e a tela pode tentar de novo ou salvar sem foto.
  Future<void> cadastrar({
    required String clienteId,
    required String clienteNome,
    required String nome,
    required int valorUnitarioCentavos,
    required int quantidade,
    required DateTime dataEntrega,
    String? observacoes,
    Uint8List? foto,
  }) async {
    final documento = _pedidos.doc();
    final fotoVersao = foto == null
        ? null
        : await _salvarFoto(documento.id, foto);
    final pedido = Pedido(
      id: documento.id,
      clienteId: clienteId,
      clienteNome: clienteNome.trim(),
      nome: nome.trim(),
      valorUnitarioCentavos: valorUnitarioCentavos,
      quantidade: quantidade,
      dataEntrega: _soData(dataEntrega),
      observacoes: _textoOuNulo(observacoes),
      fotoVersao: fotoVersao,
      criadoEm: DateTime.now(),
    );
    try {
      await aguardarEscrita(documento.set(pedido.toMap()));
    } on Falha {
      if (fotoVersao != null) _apagarFotoSemEsperar(documento.id);
      rethrow;
    }
  }

  /// Atualiza os campos editáveis. Com [novaFoto], substitui a foto; com
  /// [removerFoto], apaga a foto atual.
  Future<void> atualizar(
    Pedido pedido, {
    Uint8List? novaFoto,
    bool removerFoto = false,
  }) async {
    var fotoVersao = pedido.fotoVersao;
    if (novaFoto != null) {
      fotoVersao = await _salvarFoto(pedido.id, novaFoto);
    } else if (removerFoto) {
      fotoVersao = null;
      _apagarFotoSemEsperar(pedido.id);
    }

    await aguardarEscrita(
      _pedidos.doc(pedido.id).update({
        'clienteId': pedido.clienteId,
        'clienteNome': pedido.clienteNome.trim(),
        'nome': pedido.nome.trim(),
        'valorUnitarioCentavos': pedido.valorUnitarioCentavos,
        'quantidade': pedido.quantidade,
        'dataEntrega': Timestamp.fromDate(_soData(pedido.dataEntrega)),
        'observacoes': _textoOuNulo(pedido.observacoes),
        'fotoVersao': fotoVersao,
      }),
    );
  }

  // Usa a hora do aparelho (e não serverTimestamp): offline, o pedido já sai
  // da lista e entra no histórico com a data certa na hora, sem ficar com
  // dataFinalizacao nula até sincronizar.
  Future<void> finalizar(String id) {
    return aguardarEscrita(
      _pedidos.doc(id).update({
        'status': StatusPedido.finalizado.name,
        'dataFinalizacao': Timestamp.fromDate(DateTime.now()),
      }),
    );
  }

  /// Exclusão definitiva (só para pendentes). A foto é apagada depois, sem
  /// bloquear: se falhar, o pedido já foi excluído do mesmo jeito.
  Future<void> excluir(String id) async {
    await aguardarEscrita(_pedidos.doc(id).delete());
    _apagarFotoSemEsperar(id);
  }

  Future<int> _salvarFoto(String pedidoId, Uint8List bytes) async {
    final versao = DateTime.now().millisecondsSinceEpoch;
    await _imagemService.salvar(
      caminho: _caminhoFoto(pedidoId),
      versao: versao,
      bytes: bytes,
    );
    return versao;
  }

  void _apagarFotoSemEsperar(String pedidoId) {
    unawaited(
      Future(() => _imagemService.apagar(_caminhoFoto(pedidoId)))
          .catchError((_) {}),
    );
  }

  DateTime _soData(DateTime data) => DateTime(data.year, data.month, data.day);

  String? _textoOuNulo(String? valor) {
    final texto = valor?.trim();
    return (texto == null || texto.isEmpty) ? null : texto;
  }
}
