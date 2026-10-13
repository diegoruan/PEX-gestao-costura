import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pex_gestao_costura/core/errors/falha.dart';
import 'package:pex_gestao_costura/features/fechamento/bloc/fechamento_bloc.dart';
import 'package:pex_gestao_costura/features/fechamento/domain/calculador_fechamento.dart';
import 'package:pex_gestao_costura/features/fechamento/domain/fechamento_mensal.dart';
import 'package:pex_gestao_costura/features/pedidos/data/pedido_repository.dart';
import 'package:pex_gestao_costura/features/pedidos/domain/pedido.dart';

class MockPedidoRepository extends Mock implements PedidoRepository {}

void main() {
  late MockPedidoRepository repository;

  final agosto = DateTime(2026, 8);
  final julho = DateTime(2026, 7);

  Pedido finalizado(String id, DateTime finalizadoEm, {int valor = 10000}) {
    return Pedido(
      id: id,
      clienteId: 'c1',
      clienteNome: 'Ana Clara',
      nome: 'Peça $id',
      valorUnitarioCentavos: valor,
      quantidade: 1,
      dataEntrega: DateTime(2026, 7, 1),
      status: StatusPedido.finalizado,
      dataFinalizacao: finalizadoEm,
      criadoEm: DateTime(2026, 6, 1),
    );
  }

  final deAgosto = finalizado('1', DateTime(2026, 8, 10), valor: 42000);
  final deJulho = finalizado('2', DateTime(2026, 7, 31, 23, 59), valor: 9000);
  final todos = [deAgosto, deJulho];

  setUp(() {
    repository = MockPedidoRepository();
  });

  // "Hoje" fixo em 20/08/2026 para o teste não depender do dia em que roda.
  FechamentoBloc criarBloc() => FechamentoBloc(
    pedidoRepository: repository,
    agora: () => DateTime(2026, 8, 20, 14, 30),
  );

  test('estado inicial é FechamentoCarregando no mês atual', () {
    expect(criarBloc().state, FechamentoCarregando(agosto));
  });

  // O bloc sempre publica o primeiro emit, mesmo quando ele é igual ao estado
  // inicial; por isso FechamentoCarregando aparece no começo dos `expect`.
  group('FechamentoIniciado', () {
    blocTest<FechamentoBloc, FechamentoState>(
      'abre no mês atual com o fechamento calculado',
      setUp: () =>
          when(() => repository.observarFinalizados())
              .thenAnswer((_) => Stream.value(todos)),
      build: criarBloc,
      act: (bloc) => bloc.add(const FechamentoIniciado()),
      expect: () => [
        FechamentoCarregando(agosto),
        FechamentoSucesso(agosto, calcularFechamento(todos, agosto)),
      ],
      verify: (bloc) {
        final fechamento = (bloc.state as FechamentoSucesso).fechamento;
        expect(fechamento.totalGeralCentavos, 42000);
        expect(fechamento.clientes.single.pedidos, [deAgosto]);
      },
    );

    blocTest<FechamentoBloc, FechamentoState>(
      'mês sem peças finalizadas emite sucesso vazio',
      setUp: () =>
          when(() => repository.observarFinalizados())
              .thenAnswer((_) => Stream.value([deJulho])),
      build: criarBloc,
      act: (bloc) => bloc.add(const FechamentoIniciado()),
      expect: () => [
        FechamentoCarregando(agosto),
        FechamentoSucesso(
          agosto,
          FechamentoMensal(mes: agosto, clientes: const []),
        ),
      ],
    );

    blocTest<FechamentoBloc, FechamentoState>(
      'emite FechamentoErro com a mensagem da Falha, mantendo o mês',
      setUp: () =>
          when(() => repository.observarFinalizados())
              .thenAnswer((_) => Stream.error(const Falha('Sem permissão.'))),
      build: criarBloc,
      act: (bloc) => bloc.add(const FechamentoIniciado()),
      expect: () => [
        FechamentoCarregando(agosto),
        FechamentoErro(agosto, 'Sem permissão.'),
      ],
    );

    blocTest<FechamentoBloc, FechamentoState>(
      'usa a mensagem genérica para erros desconhecidos',
      setUp: () =>
          when(() => repository.observarFinalizados())
              .thenAnswer((_) => Stream.error(Exception('boom'))),
      build: criarBloc,
      act: (bloc) => bloc.add(const FechamentoIniciado()),
      expect: () => [
        FechamentoCarregando(agosto),
        FechamentoErro(agosto, Falha.mensagemGenerica),
      ],
    );
  });

  group('FechamentoMesAlterado', () {
    blocTest<FechamentoBloc, FechamentoState>(
      'recalcula para o mês escolhido, aceitando qualquer dia dele',
      setUp: () =>
          when(() => repository.observarFinalizados())
              .thenAnswer((_) => Stream.value(todos)),
      build: criarBloc,
      act: (bloc) => bloc.add(FechamentoMesAlterado(DateTime(2026, 7, 15))),
      expect: () => [
        FechamentoCarregando(julho),
        FechamentoSucesso(julho, calcularFechamento(todos, julho)),
      ],
    );

    final doMesAtual = StreamController<List<Pedido>>();
    final doMesAnterior = StreamController<List<Pedido>>();
    blocTest<FechamentoBloc, FechamentoState>(
      'trocar de mês cancela a assinatura anterior',
      setUp: () {
        final streams = [doMesAtual.stream, doMesAnterior.stream];
        when(() => repository.observarFinalizados())
            .thenAnswer((_) => streams.removeAt(0));
      },
      build: criarBloc,
      act: (bloc) async {
        bloc.add(const FechamentoIniciado());
        await Future<void>.delayed(Duration.zero);
        doMesAtual.add(todos);
        await Future<void>.delayed(Duration.zero);

        bloc.add(FechamentoMesAlterado(julho));
        await Future<void>.delayed(Duration.zero);
        expect(doMesAtual.hasListener, isFalse);

        // Chega depois da troca: não pode virar estado.
        doMesAtual.add([deAgosto, deAgosto]);
        doMesAnterior.add(todos);
      },
      tearDown: () async {
        await doMesAtual.close();
        await doMesAnterior.close();
      },
      expect: () => [
        FechamentoCarregando(agosto),
        FechamentoSucesso(agosto, calcularFechamento(todos, agosto)),
        FechamentoCarregando(julho),
        FechamentoSucesso(julho, calcularFechamento(todos, julho)),
      ],
      verify: (_) => verify(() => repository.observarFinalizados()).called(2),
    );

    blocTest<FechamentoBloc, FechamentoState>(
      'tentar de novo após erro assina o stream do mesmo mês outra vez',
      setUp: () =>
          when(() => repository.observarFinalizados())
              .thenAnswer((_) => Stream.value(todos)),
      build: criarBloc,
      seed: () => FechamentoErro(julho, 'Sem conexão.'),
      act: (bloc) => bloc.add(FechamentoMesAlterado(julho)),
      expect: () => [
        FechamentoCarregando(julho),
        FechamentoSucesso(julho, calcularFechamento(todos, julho)),
      ],
    );
  });
}
