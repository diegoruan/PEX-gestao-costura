import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pex_gestao_costura/core/errors/falha.dart';
import 'package:pex_gestao_costura/features/historico/bloc/historico_bloc.dart';
import 'package:pex_gestao_costura/features/pedidos/data/pedido_repository.dart';
import 'package:pex_gestao_costura/features/pedidos/domain/pedido.dart';

class MockPedidoRepository extends Mock implements PedidoRepository {}

void main() {
  late MockPedidoRepository repository;

  Pedido finalizado(
    String id,
    DateTime finalizadoEm, {
    String clienteId = 'c1',
    String clienteNome = 'Ana Clara',
  }) {
    return Pedido(
      id: id,
      clienteId: clienteId,
      clienteNome: clienteNome,
      nome: 'Peça $id',
      valorUnitarioCentavos: 9000,
      quantidade: 1,
      dataEntrega: DateTime(2026, 8, 1),
      status: StatusPedido.finalizado,
      dataFinalizacao: finalizadoEm,
      criadoEm: DateTime(2026, 7, 1),
    );
  }

  final agosto = finalizado('1', DateTime(2026, 8, 15));
  final setembro = finalizado(
    '2',
    DateTime(2026, 9, 1, 10),
    clienteId: 'c2',
    clienteNome: 'Pedro Lima',
  );
  final julho = finalizado('3', DateTime(2026, 7, 30));
  final ordenados = [setembro, agosto, julho];

  setUp(() {
    repository = MockPedidoRepository();
  });

  HistoricoBloc criarBloc() => HistoricoBloc(pedidoRepository: repository);

  test('estado inicial é HistoricoCarregando', () {
    expect(criarBloc().state, const HistoricoCarregando());
  });

  group('HistoricoIniciado', () {
    blocTest<HistoricoBloc, HistoricoState>(
      'emite a lista ordenada por dataFinalizacao decrescente',
      setUp: () =>
          when(() => repository.observarFinalizados())
              .thenAnswer((_) => Stream.value([agosto, julho, setembro])),
      build: criarBloc,
      act: (bloc) => bloc.add(const HistoricoIniciado()),
      expect: () => [const HistoricoCarregando(), HistoricoSucesso(ordenados)],
    );

    blocTest<HistoricoBloc, HistoricoState>(
      'emite HistoricoSucesso vazio quando ainda não há peças finalizadas',
      setUp: () =>
          when(() => repository.observarFinalizados())
              .thenAnswer((_) => Stream.value(const [])),
      build: criarBloc,
      act: (bloc) => bloc.add(const HistoricoIniciado()),
      expect: () => const [HistoricoCarregando(), HistoricoSucesso([])],
    );

    blocTest<HistoricoBloc, HistoricoState>(
      'emite HistoricoErro com a mensagem da Falha',
      setUp: () =>
          when(() => repository.observarFinalizados())
              .thenAnswer((_) => Stream.error(const Falha('Sem permissão.'))),
      build: criarBloc,
      act: (bloc) => bloc.add(const HistoricoIniciado()),
      expect: () => const [
        HistoricoCarregando(),
        HistoricoErro('Sem permissão.'),
      ],
    );

    blocTest<HistoricoBloc, HistoricoState>(
      'usa a mensagem genérica para erros desconhecidos',
      setUp: () =>
          when(() => repository.observarFinalizados())
              .thenAnswer((_) => Stream.error(Exception('boom'))),
      build: criarBloc,
      act: (bloc) => bloc.add(const HistoricoIniciado()),
      expect: () => const [
        HistoricoCarregando(),
        HistoricoErro(Falha.mensagemGenerica),
      ],
    );

    blocTest<HistoricoBloc, HistoricoState>(
      'tentar de novo após erro volta a carregar e assina o stream outra vez',
      setUp: () =>
          when(() => repository.observarFinalizados())
              .thenAnswer((_) => Stream.value(ordenados)),
      build: criarBloc,
      seed: () => const HistoricoErro('Sem conexão.'),
      act: (bloc) => bloc.add(const HistoricoIniciado()),
      expect: () => [const HistoricoCarregando(), HistoricoSucesso(ordenados)],
      verify: (_) => verify(() => repository.observarFinalizados()).called(1),
    );
  });

  group('HistoricoFiltroAlterado', () {
    const filtro = HistoricoFiltro(busca: 'pedro', clienteId: 'c2');

    blocTest<HistoricoBloc, HistoricoState>(
      'guarda o filtro e mantém a lista completa no estado',
      build: criarBloc,
      seed: () => HistoricoSucesso(ordenados),
      act: (bloc) => bloc.add(const HistoricoFiltroAlterado(filtro)),
      expect: () => [HistoricoSucesso(ordenados, filtro: filtro)],
      verify: (bloc) {
        final estado = bloc.state as HistoricoSucesso;
        expect(estado.filtrados, [setembro]);
      },
    );

    blocTest<HistoricoBloc, HistoricoState>(
      'é ignorado enquanto a lista não carregou',
      build: criarBloc,
      act: (bloc) => bloc.add(const HistoricoFiltroAlterado(filtro)),
      expect: () => const <HistoricoState>[],
    );

    final controller = StreamController<List<Pedido>>();
    blocTest<HistoricoBloc, HistoricoState>(
      'o filtro continua valendo quando chega uma peça nova pelo stream',
      setUp: () =>
          when(() => repository.observarFinalizados())
              .thenAnswer((_) => controller.stream),
      build: criarBloc,
      act: (bloc) async {
        bloc.add(const HistoricoIniciado());
        controller.add([agosto, julho]);
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HistoricoFiltroAlterado(filtro));
        await Future<void>.delayed(Duration.zero);
        controller.add([agosto, julho, setembro]);
      },
      tearDown: controller.close,
      expect: () => [
        const HistoricoCarregando(),
        HistoricoSucesso([agosto, julho]),
        HistoricoSucesso([agosto, julho], filtro: filtro),
        HistoricoSucesso(ordenados, filtro: filtro),
      ],
    );
  });
}
