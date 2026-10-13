import 'package:flutter_test/flutter_test.dart';
import 'package:pex_gestao_costura/features/clientes/domain/resumo_cliente.dart';
import 'package:pex_gestao_costura/features/pedidos/domain/pedido.dart';

void main() {
  Pedido pedido(
    String id, {
    String clienteId = 'ana',
    DateTime? dataEntrega,
    DateTime? finalizadoEm,
    int valorUnitarioCentavos = 10000,
    int quantidade = 1,
  }) {
    return Pedido(
      id: id,
      clienteId: clienteId,
      clienteNome: 'Ana Clara',
      nome: 'Peça $id',
      valorUnitarioCentavos: valorUnitarioCentavos,
      quantidade: quantidade,
      dataEntrega: dataEntrega ?? DateTime(2026, 9, 1),
      status: finalizadoEm == null
          ? StatusPedido.pendente
          : StatusPedido.finalizado,
      dataFinalizacao: finalizadoEm,
      criadoEm: DateTime(2026, 7, 1),
    );
  }

  test('sem pedidos do cliente, tudo vazio e zerado', () {
    final resumo = ResumoCliente.de(
      'ana',
      pendentes: [pedido('1', clienteId: 'pedro')],
      finalizados: [
        pedido('2', clienteId: 'pedro', finalizadoEm: DateTime(2026, 8, 1)),
      ],
    );
    expect(
      resumo,
      const ResumoCliente(
        emAberto: [],
        entregues: [],
        totalFaturadoCentavos: 0,
      ),
    );
    expect(resumo.pedidosTotal, 0);
  });

  test('separa só os pedidos do cliente, em aberto pela entrega', () {
    final dia15 = pedido('1', dataEntrega: DateTime(2026, 9, 15));
    final dia3 = pedido('2', dataEntrega: DateTime(2026, 9, 3));
    final resumo = ResumoCliente.de(
      'ana',
      pendentes: [
        dia15,
        pedido('3', clienteId: 'pedro'),
        dia3,
      ],
      finalizados: const [],
    );
    expect(resumo.emAberto, [dia3, dia15]);
  });

  test('últimas entregas: mais recente primeiro, no máximo três', () {
    final finalizados = [
      for (var dia = 1; dia <= 5; dia++)
        pedido('f$dia', finalizadoEm: DateTime(2026, 8, dia)),
    ];
    final resumo = ResumoCliente.de(
      'ana',
      pendentes: const [],
      finalizados: finalizados,
    );
    expect(resumo.entregues.map((p) => p.id), ['f5', 'f4', 'f3', 'f2', 'f1']);
    expect(resumo.ultimasEntregas.map((p) => p.id), ['f5', 'f4', 'f3']);
  });

  test('total faturado soma só os finalizados, em centavos', () {
    final resumo = ResumoCliente.de(
      'ana',
      pendentes: [pedido('p', valorUnitarioCentavos: 99999)],
      finalizados: [
        pedido(
          'f1',
          valorUnitarioCentavos: 14000,
          quantidade: 2,
          finalizadoEm: DateTime(2026, 8, 28),
        ),
        pedido(
          'f2',
          valorUnitarioCentavos: 1050,
          quantidade: 3,
          finalizadoEm: DateTime(2026, 8, 10),
        ),
      ],
    );
    expect(resumo.totalFaturadoCentavos, 28000 + 3150);
    expect(resumo.pedidosTotal, 3);
  });
}
