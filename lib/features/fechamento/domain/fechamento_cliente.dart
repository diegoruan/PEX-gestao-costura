import 'package:equatable/equatable.dart';

import '../../pedidos/domain/pedido.dart';

/// Quanto um cliente deve no mês, somando as peças finalizadas nele.
class FechamentoCliente extends Equatable {
  const FechamentoCliente({
    required this.clienteId,
    required this.clienteNome,
    required this.totalCentavos,
    required this.quantidadePecas,
    required this.pedidos,
  });

  final String clienteId;

  /// Nome gravado no pedido mais recente do mês: o cliente pode ter sido
  /// renomeado ou inativado depois e continua aparecendo.
  final String clienteNome;
  final int totalCentavos;

  /// Soma das quantidades, não o número de pedidos.
  final int quantidadePecas;

  /// Pedidos que compõem o total, mais recente primeiro (detalhe do cartão).
  final List<Pedido> pedidos;

  int get quantidadePedidos => pedidos.length;

  @override
  List<Object?> get props => [
    clienteId,
    clienteNome,
    totalCentavos,
    quantidadePecas,
    pedidos,
  ];
}
