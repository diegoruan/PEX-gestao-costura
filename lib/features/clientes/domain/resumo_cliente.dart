import 'package:equatable/equatable.dart';

import '../../pedidos/domain/pedido.dart';

/// Pedidos de um cliente para o detalhe: em aberto, últimas entregas e os
/// números do topo. Monta a partir das listas que os blocs de pedidos e de
/// histórico já carregam, sem consulta nova.
class ResumoCliente extends Equatable {
  const ResumoCliente({
    required this.emAberto,
    required this.entregues,
    required this.totalFaturadoCentavos,
  });

  factory ResumoCliente.de(
    String clienteId, {
    required List<Pedido> pendentes,
    required List<Pedido> finalizados,
  }) {
    final entregues = [
      for (final p in finalizados)
        if (p.clienteId == clienteId) p,
    ]..sort(Pedido.compararPorFinalizacao);

    return ResumoCliente(
      emAberto: [
        for (final p in pendentes)
          if (p.clienteId == clienteId) p,
      ]..sort(Pedido.compararPorEntrega),
      entregues: entregues,
      totalFaturadoCentavos: entregues.fold(
        0,
        (soma, p) => soma + p.totalCentavos,
      ),
    );
  }

  static const quantidadeUltimasEntregas = 3;

  /// Entrega mais próxima primeiro.
  final List<Pedido> emAberto;

  /// Todos os finalizados do cliente, mais recente primeiro.
  final List<Pedido> entregues;

  /// Soma dos finalizados: o que já foi entregue e cobrado.
  final int totalFaturadoCentavos;

  int get pedidosTotal => emAberto.length + entregues.length;

  List<Pedido> get ultimasEntregas =>
      entregues.take(quantidadeUltimasEntregas).toList();

  @override
  List<Object?> get props => [emAberto, entregues, totalFaturadoCentavos];
}
