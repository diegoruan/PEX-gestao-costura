import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../domain/pedido.dart';

sealed class PedidosEvent extends Equatable {
  const PedidosEvent();

  @override
  List<Object?> get props => [];
}

/// Começa (ou recomeça, após um erro) a escutar os pedidos pendentes.
final class PedidosIniciado extends PedidosEvent {
  const PedidosIniciado();
}

final class PedidoCadastroSolicitado extends PedidosEvent {
  const PedidoCadastroSolicitado({
    required this.clienteId,
    required this.clienteNome,
    required this.nome,
    required this.valorUnitarioCentavos,
    required this.quantidade,
    required this.dataEntrega,
    this.observacoes,
    this.foto,
  });

  final String clienteId;
  final String clienteNome;
  final String nome;
  final int valorUnitarioCentavos;
  final int quantidade;
  final DateTime dataEntrega;
  final String? observacoes;

  /// JPEG já comprimido pelo ImagemService.
  final Uint8List? foto;

  @override
  List<Object?> get props => [
    clienteId,
    clienteNome,
    nome,
    valorUnitarioCentavos,
    quantidade,
    dataEntrega,
    observacoes,
    foto,
  ];
}

final class PedidoEdicaoSolicitada extends PedidosEvent {
  const PedidoEdicaoSolicitada(
    this.pedido, {
    this.novaFoto,
    this.removerFoto = false,
  });

  final Pedido pedido;
  final Uint8List? novaFoto;
  final bool removerFoto;

  @override
  List<Object?> get props => [pedido, novaFoto, removerFoto];
}

final class PedidoFinalizacaoSolicitada extends PedidosEvent {
  const PedidoFinalizacaoSolicitada(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class PedidoExclusaoSolicitada extends PedidosEvent {
  const PedidoExclusaoSolicitada(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
