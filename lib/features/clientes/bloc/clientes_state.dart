import 'package:equatable/equatable.dart';

import '../domain/cliente.dart';

/// Situação da última ação de escrita (salvar ou excluir). Fica dentro de
/// [ClientesSucesso] para a lista continuar na tela enquanto a ação roda.
enum AcaoCliente {
  nenhuma,
  salvando,
  salvo,
  inativando,
  inativado,
  falhou;

  bool get emAndamento => this == salvando || this == inativando;
}

sealed class ClientesState extends Equatable {
  const ClientesState();

  @override
  List<Object?> get props => [];
}

final class ClientesCarregando extends ClientesState {
  const ClientesCarregando();
}

final class ClientesSucesso extends ClientesState {
  const ClientesSucesso(
    this.clientes, {
    this.acao = AcaoCliente.nenhuma,
    this.mensagemErro,
  });

  final List<Cliente> clientes;
  final AcaoCliente acao;

  /// Preenchida quando [acao] é [AcaoCliente.falhou].
  final String? mensagemErro;

  Cliente? buscarPorId(String id) =>
      clientes.where((c) => c.id == id).firstOrNull;

  ClientesSucesso copyWith({List<Cliente>? clientes}) {
    return ClientesSucesso(
      clientes ?? this.clientes,
      acao: acao,
      mensagemErro: mensagemErro,
    );
  }

  @override
  List<Object?> get props => [clientes, acao, mensagemErro];
}

final class ClientesErro extends ClientesState {
  const ClientesErro(this.mensagem);

  final String mensagem;

  @override
  List<Object?> get props => [mensagem];
}
