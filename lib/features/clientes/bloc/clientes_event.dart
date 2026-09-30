import 'package:equatable/equatable.dart';

import '../domain/cliente.dart';

sealed class ClientesEvent extends Equatable {
  const ClientesEvent();

  @override
  List<Object?> get props => [];
}

/// Começa (ou recomeça, após um erro) a escutar a lista de clientes.
final class ClientesIniciado extends ClientesEvent {
  const ClientesIniciado();
}

final class ClienteCadastroSolicitado extends ClientesEvent {
  const ClienteCadastroSolicitado({
    required this.nome,
    this.telefone,
    this.observacoes,
  });

  final String nome;
  final String? telefone;
  final String? observacoes;

  @override
  List<Object?> get props => [nome, telefone, observacoes];
}

final class ClienteEdicaoSolicitada extends ClientesEvent {
  const ClienteEdicaoSolicitada(this.cliente);

  final Cliente cliente;

  @override
  List<Object?> get props => [cliente];
}

final class ClienteInativacaoSolicitada extends ClientesEvent {
  const ClienteInativacaoSolicitada(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
