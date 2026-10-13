import 'package:flutter_test/flutter_test.dart';
import 'package:pex_gestao_costura/features/fechamento/domain/calculador_fechamento.dart';
import 'package:pex_gestao_costura/features/fechamento/domain/fechamento_cliente.dart';
import 'package:pex_gestao_costura/features/fechamento/domain/fechamento_mensal.dart';
import 'package:pex_gestao_costura/features/pedidos/domain/pedido.dart';

void main() {
  final agosto = DateTime(2026, 8);
  var proximoId = 0;

  Pedido pedido({
    String clienteId = 'c1',
    String clienteNome = 'Ana Clara',
    String nome = 'Vestido',
    int valorUnitarioCentavos = 10000,
    int quantidade = 1,
    DateTime? finalizadoEm,
    StatusPedido status = StatusPedido.finalizado,
  }) {
    return Pedido(
      id: 'p${proximoId++}',
      clienteId: clienteId,
      clienteNome: clienteNome,
      nome: nome,
      valorUnitarioCentavos: valorUnitarioCentavos,
      quantidade: quantidade,
      dataEntrega: DateTime(2026, 8, 10),
      status: status,
      dataFinalizacao: finalizadoEm,
      criadoEm: DateTime(2026, 7, 1),
    );
  }

  group('casos vazios', () {
    test('sem pedidos devolve lista vazia e total 0', () {
      final fechamento = calcularFechamento(const [], agosto);
      expect(fechamento, FechamentoMensal(mes: agosto, clientes: const []));
      expect(fechamento.totalGeralCentavos, 0);
      expect(fechamento.quantidadePecas, 0);
    });

    test('ignora pendentes, mesmo com data de finalização no mês', () {
      final fechamento = calcularFechamento([
        pedido(status: StatusPedido.pendente),
        pedido(
          status: StatusPedido.pendente,
          finalizadoEm: DateTime(2026, 8, 10),
        ),
      ], agosto);
      expect(fechamento.clientes, isEmpty);
      expect(fechamento.totalGeralCentavos, 0);
    });

    test('ignora finalizado sem data de finalização', () {
      expect(calcularFechamento([pedido()], agosto).clientes, isEmpty);
    });
  });

  group('agrupamento por cliente', () {
    test('um cliente com vários pedidos vira um só, mais recente primeiro', () {
      final vestido = pedido(
        nome: 'Vestido Festa',
        valorUnitarioCentavos: 14000,
        quantidade: 2,
        finalizadoEm: DateTime(2026, 8, 28),
      );
      final blusa = pedido(
        nome: 'Blusa Rendada',
        valorUnitarioCentavos: 7000,
        quantidade: 2,
        finalizadoEm: DateTime(2026, 8, 30),
      );

      final fechamento = calcularFechamento([vestido, blusa], agosto);

      expect(fechamento.clientes, [
        FechamentoCliente(
          clienteId: 'c1',
          clienteNome: 'Ana Clara',
          totalCentavos: 42000,
          quantidadePecas: 4,
          pedidos: [blusa, vestido],
        ),
      ]);
      expect(fechamento.clientes.single.quantidadePedidos, 2);
    });

    test(
      'vários clientes em ordem alfabética, sem ligar para acento e caixa',
      () {
        final fechamento = calcularFechamento([
          pedido(
            clienteId: 'c3',
            clienteNome: 'carla',
            finalizadoEm: DateTime(2026, 8, 3),
          ),
          pedido(
            clienteId: 'c2',
            clienteNome: 'Bruna',
            finalizadoEm: DateTime(2026, 8, 2),
          ),
          pedido(
            clienteId: 'c1',
            clienteNome: 'Ângela',
            finalizadoEm: DateTime(2026, 8, 1),
          ),
        ], agosto);

        expect(fechamento.clientes.map((c) => c.clienteNome), [
          'Ângela',
          'Bruna',
          'carla',
        ]);
      },
    );

    test('agrupa pelo clienteId, não pelo nome', () {
      final fechamento = calcularFechamento([
        pedido(clienteId: 'c1', finalizadoEm: DateTime(2026, 8, 1)),
        pedido(clienteId: 'c2', finalizadoEm: DateTime(2026, 8, 2)),
      ], agosto);
      expect(fechamento.clientes.map((c) => c.clienteId), ['c1', 'c2']);
    });

    test('cliente renomeado vira um só, com o nome do pedido mais recente', () {
      final fechamento = calcularFechamento([
        pedido(clienteNome: 'Ana Souza', finalizadoEm: DateTime(2026, 8, 25)),
        pedido(clienteNome: 'Ana', finalizadoEm: DateTime(2026, 8, 2)),
        pedido(clienteNome: 'Ana S.', finalizadoEm: DateTime(2026, 8, 10)),
      ], agosto);

      expect(fechamento.clientes, hasLength(1));
      expect(fechamento.clientes.single.clienteNome, 'Ana Souza');
      expect(fechamento.clientes.single.quantidadePedidos, 3);
    });

    test('cliente inativado continua aparecendo', () {
      // O fechamento só olha os pedidos: a cópia do nome gravada neles basta
      // e não importa se o cliente ainda está ativo no cadastro.
      final fechamento = calcularFechamento([
        pedido(
          clienteId: 'inativado',
          clienteNome: 'Regina Santos',
          valorUnitarioCentavos: 15000,
          finalizadoEm: DateTime(2026, 8, 5),
        ),
      ], agosto);

      expect(fechamento.clientes.single.clienteId, 'inativado');
      expect(fechamento.totalGeralCentavos, 15000);
    });
  });

  group('limites do mês', () {
    test('pedido finalizado em outro mês não entra', () {
      final fechamento = calcularFechamento([
        pedido(finalizadoEm: DateTime(2026, 7, 15)),
        pedido(finalizadoEm: DateTime(2026, 9, 15)),
        pedido(finalizadoEm: DateTime(2025, 8, 15)),
      ], agosto);
      expect(fechamento.clientes, isEmpty);
    });

    test('dia 1 às 00:00:00 e último dia às 23:59:59 entram', () {
      final fechamento = calcularFechamento([
        pedido(finalizadoEm: DateTime(2026, 8, 1)),
        pedido(finalizadoEm: DateTime(2026, 8, 31, 23, 59, 59)),
        pedido(finalizadoEm: DateTime(2026, 8, 31, 23, 59, 59, 999)),
      ], agosto);
      expect(fechamento.clientes.single.quantidadePedidos, 3);
    });

    test('00:00:00 do mês seguinte e 23:59:59 do mês anterior não entram', () {
      final fechamento = calcularFechamento([
        pedido(finalizadoEm: DateTime(2026, 9, 1)),
        pedido(finalizadoEm: DateTime(2026, 7, 31, 23, 59, 59)),
      ], agosto);
      expect(fechamento.clientes, isEmpty);
    });

    test('o mês pode vir com dia e hora: vale o mês inteiro', () {
      final fechamento = calcularFechamento([
        pedido(finalizadoEm: DateTime(2026, 8, 1)),
      ], DateTime(2026, 8, 20, 15, 30));
      expect(fechamento.mes, agosto);
      expect(fechamento.clientes, hasLength(1));
    });

    test('virada de ano: dezembro e janeiro não se misturam', () {
      final ultimoDeDezembro = pedido(
        finalizadoEm: DateTime(2026, 12, 31, 23, 59, 59),
      );
      final primeiroDeJaneiro = pedido(finalizadoEm: DateTime(2027, 1, 1));
      final pedidos = [ultimoDeDezembro, primeiroDeJaneiro];

      final dezembro = calcularFechamento(pedidos, DateTime(2026, 12));
      final janeiro = calcularFechamento(pedidos, DateTime(2027, 1));

      expect(dezembro.clientes.single.pedidos, [ultimoDeDezembro]);
      expect(janeiro.clientes.single.pedidos, [primeiroDeJaneiro]);
    });
  });

  group('valores em centavos', () {
    test('1050 centavos × 3 = 3150', () {
      final fechamento = calcularFechamento([
        pedido(
          valorUnitarioCentavos: 1050,
          quantidade: 3,
          finalizadoEm: DateTime(2026, 8, 1),
        ),
      ], agosto);
      expect(fechamento.clientes.single.totalCentavos, 3150);
      expect(fechamento.clientes.single.quantidadePecas, 3);
    });

    test('muitos pedidos somam sem erro de arredondamento', () {
      // Em double, 0.1 somado mil vezes não dá 100 exatos; em centavos, dá.
      final pedidos = [
        for (var i = 0; i < 1000; i++)
          pedido(valorUnitarioCentavos: 10, finalizadoEm: DateTime(2026, 8, 5)),
        for (var i = 0; i < 333; i++)
          pedido(
            clienteId: 'c2',
            clienteNome: 'Bruna',
            valorUnitarioCentavos: 1999,
            quantidade: 3,
            finalizadoEm: DateTime(2026, 8, 6),
          ),
      ];

      final fechamento = calcularFechamento(pedidos, agosto);

      expect(fechamento.clientes[0].totalCentavos, 10000);
      expect(fechamento.clientes[1].totalCentavos, 1997001);
      expect(fechamento.totalGeralCentavos, 2007001);
      expect(fechamento.quantidadePecas, 1999);
    });

    test('totalGeralCentavos é a soma exata dos totais por cliente', () {
      final fechamento = calcularFechamento([
        pedido(
          clienteId: 'c1',
          valorUnitarioCentavos: 14000,
          quantidade: 2,
          finalizadoEm: DateTime(2026, 8, 1),
        ),
        pedido(
          clienteId: 'c2',
          clienteNome: 'Fernanda',
          valorUnitarioCentavos: 12000,
          quantidade: 3,
          finalizadoEm: DateTime(2026, 8, 2),
        ),
        pedido(
          clienteId: 'c3',
          clienteNome: 'Juliana',
          valorUnitarioCentavos: 6550,
          quantidade: 1,
          finalizadoEm: DateTime(2026, 8, 3),
        ),
      ], agosto);

      final soma = fechamento.clientes.fold(0, (s, c) => s + c.totalCentavos);
      expect(fechamento.totalGeralCentavos, soma);
      expect(fechamento.totalGeralCentavos, 28000 + 36000 + 6550);
    });
  });

  group('percentualDe', () {
    test('arredonda para o inteiro mais próximo, como no Figma', () {
      final fechamento = calcularFechamento([
        pedido(
          clienteId: 'c1',
          valorUnitarioCentavos: 42000,
          finalizadoEm: DateTime(2026, 8, 1),
        ),
        pedido(
          clienteId: 'c2',
          clienteNome: 'Fernanda',
          valorUnitarioCentavos: 36000,
          finalizadoEm: DateTime(2026, 8, 1),
        ),
        pedido(
          clienteId: 'c3',
          clienteNome: 'Juliana',
          valorUnitarioCentavos: 31000,
          finalizadoEm: DateTime(2026, 8, 1),
        ),
        pedido(
          clienteId: 'c4',
          clienteNome: 'Regina',
          valorUnitarioCentavos: 15000,
          finalizadoEm: DateTime(2026, 8, 1),
        ),
      ], agosto);

      expect(fechamento.clientes.map(fechamento.percentualDe), [
        34,
        29,
        25,
        12,
      ]);
    });
  });

  group('navegação entre meses', () {
    test('inicioDoMes zera dia e hora', () {
      expect(inicioDoMes(DateTime(2026, 8, 31, 23, 59)), agosto);
    });

    test('mesAnterior e mesSeguinte atravessam a virada do ano', () {
      expect(mesAnterior(DateTime(2027, 1, 15)), DateTime(2026, 12));
      expect(mesSeguinte(DateTime(2026, 12, 31)), DateTime(2027, 1));
      expect(mesSeguinte(agosto), DateTime(2026, 9));
      expect(mesAnterior(agosto), DateTime(2026, 7));
    });
  });
}
