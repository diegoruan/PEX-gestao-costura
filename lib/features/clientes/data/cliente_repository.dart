import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/falha.dart';
import '../../../core/services/firestore_escrita.dart';
import '../../../core/utils/texto.dart';
import '../domain/cliente.dart';

/// Único ponto do app que acessa os clientes no Firestore, em
/// `usuarios/{uid}/clientes/{clienteId}`.
class ClienteRepository {
  ClienteRepository({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  // Lido a cada chamada (e não guardado no construtor) porque o repository
  // vive o app inteiro e o usuário pode sair e entrar com outra conta.
  CollectionReference<Map<String, dynamic>> get _clientes {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) throw Falha.sessaoExpirada;
    return _firestore.collection('usuarios').doc(uid).collection('clientes');
  }

  /// Clientes ativos em ordem alfabética, atualizados em tempo real.
  Stream<List<Cliente>> observarAtivos() {
    final Query<Map<String, dynamic>> query;
    try {
      query = _clientes.where('ativo', isEqualTo: true);
    } on Falha catch (e) {
      return Stream.error(e);
    }

    // A ordenação é feita aqui, em memória, e não com orderBy na query:
    // where + orderBy em campos diferentes exigiria um índice composto no
    // Firestore, e a lista de clientes de um MEI é pequena.
    return query
        .snapshots()
        .map(_paraListaOrdenada)
        .transform(
          StreamTransformer.fromHandlers(
            handleError: (erro, stackTrace, sink) => sink.addError(
              erro is FirebaseException ? Falha.firestore(erro) : erro,
              stackTrace,
            ),
          ),
        );
  }

  Future<void> cadastrar({
    required String nome,
    String? telefone,
    String? observacoes,
  }) {
    final documento = _clientes.doc();
    final cliente = Cliente(
      id: documento.id,
      nome: nome.trim(),
      telefone: _textoOuNulo(telefone),
      observacoes: _textoOuNulo(observacoes),
      criadoEm: DateTime.now(),
    );
    return aguardarEscrita(documento.set(cliente.toMap()));
  }

  /// Atualiza só os campos editáveis; `ativo` e `criadoEm` não são tocados.
  Future<void> atualizar(Cliente cliente) {
    return aguardarEscrita(
      _clientes.doc(cliente.id).update({
        'nome': cliente.nome.trim(),
        'telefone': _textoOuNulo(cliente.telefone),
        'observacoes': _textoOuNulo(cliente.observacoes),
      }),
    );
  }

  Future<void> inativar(String id) {
    return aguardarEscrita(_clientes.doc(id).update({'ativo': false}));
  }

  List<Cliente> _paraListaOrdenada(QuerySnapshot<Map<String, dynamic>> snap) {
    final clientes = [
      for (final doc in snap.docs) Cliente.fromMap(doc.id, doc.data()),
    ];
    return clientes..sort(
      (a, b) => Texto.normalizar(a.nome).compareTo(Texto.normalizar(b.nome)),
    );
  }

  String? _textoOuNulo(String? valor) {
    final texto = valor?.trim();
    return (texto == null || texto.isEmpty) ? null : texto;
  }
}
