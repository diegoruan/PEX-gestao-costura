import 'package:flutter_test/flutter_test.dart';
import 'package:pex_gestao_costura/features/historico/bloc/historico_state.dart';
import 'package:pex_gestao_costura/features/pedidos/domain/pedido.dart';

void main() {
  Pedido finalizado(
    String id, {
    required DateTime? finalizadoEm,
    String nome = 'Vestido',
    String clienteId = 'c1',
    String clienteNome = 'Ana Clara',
    int valorUnitarioCentavos = 9000,
    int quantidade = 1,
  }) {
    return Pedido(
      id: id,
      clienteId: clienteId,
      clienteNome: clienteNome,
      nome: nome,
      valorUnitarioCentavos: valorUnitarioCentavos,
      quantidade: quantidade,
      dataEntrega: DateTime(2026, 1, 1),
      status: StatusPedido.finalizado,
      dataFinalizacao: finalizadoEm,
      criadoEm: DateTime(2025, 12, 1),
    );
  }

  group('finalizadoEm', () {
    test('usa a data de finalização ou, sem ela, a de cadastro', () {
      final comData = finalizado('1', finalizadoEm: DateTime(2026, 9, 1));
      final semData = finalizado('2', finalizadoEm: null);
      expect(comData.finalizadoEm, DateTime(2026, 9, 1));
      expect(semData.finalizadoEm, DateTime(2025, 12, 1));
    });
  });

  group('MesHistorico.agrupar', () {
    test('lista vazia não gera grupos', () {
      expect(MesHistorico.agrupar(const []), isEmpty);
    });

    test('separa a virada do mês, inclusive no último segundo do dia', () {
      final primeiroDeSetembro = finalizado(
        '1',
        finalizadoEm: DateTime(2026, 9, 1, 0, 0),
      );
      final fimDeAgosto = finalizado(
        '2',
        finalizadoEm: DateTime(2026, 8, 31, 23, 59, 59),
      );
      final grupos = MesHistorico.agrupar([primeiroDeSetembro, fimDeAgosto]);

      expect(grupos, [
        MesHistorico(mes: DateTime(2026, 9), pedidos: [primeiroDeSetembro]),
        MesHistorico(mes: DateTime(2026, 8), pedidos: [fimDeAgosto]),
      ]);
    });

    test(
      'separa a virada do ano e não junta o mesmo mês de anos diferentes',
      () {
        final janeiro2027 = finalizado('1', finalizadoEm: DateTime(2027, 1, 2));
        final dezembro2026 = finalizado(
          '2',
          finalizadoEm: DateTime(2026, 12, 31),
        );
        final janeiro2026 = finalizado(
          '3',
          finalizadoEm: DateTime(2026, 1, 20),
        );
        final grupos = MesHistorico.agrupar([
          janeiro2027,
          dezembro2026,
          janeiro2026,
        ]);

        expect(grupos.map((g) => g.mes), [
          DateTime(2027, 1),
          DateTime(2026, 12),
          DateTime(2026, 1),
        ]);
      },
    );

    test('mantém a ordem dos pedidos dentro do mês', () {
      final dia20 = finalizado('1', finalizadoEm: DateTime(2026, 8, 20));
      final dia5 = finalizado('2', finalizadoEm: DateTime(2026, 8, 5));
      final grupos = MesHistorico.agrupar([dia20, dia5]);
      expect(grupos.single.pedidos, [dia20, dia5]);
    });

    test('totalCentavos soma valor × quantidade, sem perder centavos', () {
      final mes = MesHistorico(
        mes: DateTime(2026, 8),
        pedidos: [
          finalizado(
            '1',
            finalizadoEm: DateTime(2026, 8, 1),
            valorUnitarioCentavos: 1999,
            quantidade: 3,
          ),
          finalizado(
            '2',
            finalizadoEm: DateTime(2026, 8, 2),
            valorUnitarioCentavos: 1,
            quantidade: 1,
          ),
        ],
      );
      expect(mes.totalCentavos, 5998);
    });
  });

  group('ResumoHistorico.de', () {
    test('lista vazia zera tudo', () {
      expect(
        ResumoHistorico.de(const []),
        const ResumoHistorico(pecas: 0, totalCentavos: 0, clientes: 0),
      );
    });

    test('soma peças e valores e conta clientes diferentes', () {
      final resumo = ResumoHistorico.de([
        finalizado(
          '1',
          finalizadoEm: DateTime(2026, 9, 1),
          valorUnitarioCentavos: 9050,
          quantidade: 3,
        ),
        finalizado(
          '2',
          finalizadoEm: DateTime(2026, 8, 1),
          valorUnitarioCentavos: 14000,
          quantidade: 2,
        ),
        finalizado(
          '3',
          finalizadoEm: DateTime(2026, 8, 1),
          clienteId: 'c2',
          valorUnitarioCentavos: 1,
          quantidade: 1,
        ),
      ]);
      expect(
        resumo,
        const ResumoHistorico(pecas: 6, totalCentavos: 55151, clientes: 2),
      );
    });
  });

  group('HistoricoFiltro.aplicar', () {
    final vestido = finalizado(
      '1',
      nome: 'Vestido Festa',
      finalizadoEm: DateTime(2026, 9, 1, 18),
    );
    final calca = finalizado(
      '2',
      nome: 'Calça Social',
      clienteId: 'c2',
      clienteNome: 'José Lima',
      finalizadoEm: DateTime(2026, 8, 31, 23, 59),
    );
    final kimono = finalizado(
      '3',
      nome: 'Kimono Bordado',
      finalizadoEm: DateTime(2026, 8, 15),
    );
    final todos = [vestido, calca, kimono];

    test('sem filtro devolve tudo, na mesma ordem', () {
      expect(const HistoricoFiltro().aplicar(todos), todos);
      expect(const HistoricoFiltro().todos, isTrue);
    });

    test('busca por peça ou cliente ignora acentos e maiúsculas', () {
      expect(const HistoricoFiltro(busca: 'CALCA').aplicar(todos), [calca]);
      expect(const HistoricoFiltro(busca: 'jose').aplicar(todos), [calca]);
      expect(const HistoricoFiltro(busca: ' ana ').aplicar(todos), [
        vestido,
        kimono,
      ]);
    });

    test('filtra por cliente', () {
      const filtro = HistoricoFiltro(clienteId: 'c1');
      expect(filtro.aplicar(todos), [vestido, kimono]);
      expect(filtro.todos, isFalse);
    });

    test('período considera dias inteiros, com as duas pontas', () {
      final filtro = HistoricoFiltro(
        periodo: (inicio: DateTime(2026, 8, 31), fim: DateTime(2026, 9, 1)),
      );
      expect(filtro.aplicar(todos), [vestido, calca]);
    });

    test('combina busca, cliente e período', () {
      final filtro = HistoricoFiltro(
        busca: 'o',
        clienteId: 'c1',
        periodo: (inicio: DateTime(2026, 8, 1), fim: DateTime(2026, 8, 31)),
      );
      expect(filtro.aplicar(todos), [kimono]);
    });

    test('copyWith consegue limpar cliente e período', () {
      final filtro = HistoricoFiltro(
        busca: 'x',
        clienteId: 'c1',
        periodo: (inicio: DateTime(2026, 8, 1), fim: DateTime(2026, 8, 2)),
      );
      expect(
        filtro.copyWith(clienteId: () => null, periodo: () => null),
        const HistoricoFiltro(busca: 'x'),
      );
    });
  });

  group('HistoricoSucesso.clientes', () {
    test('um por cliente, em ordem alfabética, com o nome mais recente', () {
      final estado = HistoricoSucesso([
        finalizado(
          '1',
          clienteId: 'c1',
          clienteNome: 'Ana Clara Souza',
          finalizadoEm: DateTime(2026, 9, 2),
        ),
        finalizado(
          '2',
          clienteId: 'c2',
          clienteNome: 'Ângela',
          finalizadoEm: DateTime(2026, 9, 1),
        ),
        finalizado(
          '3',
          clienteId: 'c1',
          clienteNome: 'Ana Clara',
          finalizadoEm: DateTime(2026, 8, 1),
        ),
      ]);
      expect(estado.clientes, [
        (id: 'c1', nome: 'Ana Clara Souza'),
        (id: 'c2', nome: 'Ângela'),
      ]);
    });
  });
}
