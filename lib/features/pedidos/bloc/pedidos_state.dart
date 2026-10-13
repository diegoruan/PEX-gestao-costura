import 'package:equatable/equatable.dart';

import '../domain/pedido.dart';

/// Situação da última ação de escrita. Fica dentro de [PedidosSucesso] para
/// a lista continuar na tela enquanto a ação roda.
enum AcaoPedido {
  nenhuma,
  salvando,
  salvo,
  finalizando,
  finalizado,
  excluindo,
  excluido,

  /// Só a foto não foi salva; nada foi gravado. A tela oferece tentar de
  /// novo ou salvar sem foto.
  fotoFalhou,
  falhou;

  bool get emAndamento =>
      this == salvando || this == finalizando || this == excluindo;
}

sealed class PedidosState extends Equatable {
  const PedidosState();

  @override
  List<Object?> get props => [];
}

final class PedidosCarregando extends PedidosState {
  const PedidosCarregando();
}

final class PedidosSucesso extends PedidosState {
  const PedidosSucesso(
    this.pedidos, {
    this.acao = AcaoPedido.nenhuma,
    this.mensagemErro,
  });

  /// Só os pendentes, entrega mais próxima primeiro.
  final List<Pedido> pedidos;
  final AcaoPedido acao;

  /// Preenchida quando [acao] é [AcaoPedido.falhou] ou
  /// [AcaoPedido.fotoFalhou].
  final String? mensagemErro;

  Pedido? buscarPorId(String id) =>
      pedidos.where((p) => p.id == id).firstOrNull;

  PedidosSucesso copyWith({List<Pedido>? pedidos}) {
    return PedidosSucesso(
      pedidos ?? this.pedidos,
      acao: acao,
      mensagemErro: mensagemErro,
    );
  }

  @override
  List<Object?> get props => [pedidos, acao, mensagemErro];
}

final class PedidosErro extends PedidosState {
  const PedidosErro(this.mensagem);

  final String mensagem;

  @override
  List<Object?> get props => [mensagem];
}
