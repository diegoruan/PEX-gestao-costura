import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pex_gestao_costura/core/errors/falha.dart';
import 'package:pex_gestao_costura/features/pedidos/bloc/pedidos_bloc.dart';
import 'package:pex_gestao_costura/features/pedidos/data/pedido_repository.dart';
import 'package:pex_gestao_costura/features/pedidos/domain/pedido.dart';

class MockPedidoRepository extends Mock implements PedidoRepository {}

void main() {
  late MockPedidoRepository repository;

  final vestido = Pedido(
    id: '1',
    clienteId: 'c1',
    clienteNome: 'Ana Clara',
    nome: 'Vestido Floral',
    valorUnitarioCentavos: 9000,
    quantidade: 2,
    dataEntrega: DateTime(2026, 9, 3),
    criadoEm: DateTime(2026, 8, 28),
  );
  final calca = Pedido(
    id: '2',
    clienteId: 'c2',
    clienteNome: 'Pedro Lima',
    nome: 'Calça Social',
    valorUnitarioCentavos: 9000,
    quantidade: 3,
    dataEntrega: DateTime(2026, 9, 10),
    criadoEm: DateTime(2026, 8, 29),
  );
  final lista = [vestido, calca];
  final foto = Uint8List.fromList([1, 2, 3]);

  setUpAll(() => registerFallbackValue(vestido));

  setUp(() {
    repository = MockPedidoRepository();
  });

  PedidosBloc criarBloc() => PedidosBloc(pedidoRepository: repository);

  When<Future<void>> quandoCadastrar() => when(
    () => repository.cadastrar(
      clienteId: any(named: 'clienteId'),
      clienteNome: any(named: 'clienteNome'),
      nome: any(named: 'nome'),
      valorUnitarioCentavos: any(named: 'valorUnitarioCentavos'),
      quantidade: any(named: 'quantidade'),
      dataEntrega: any(named: 'dataEntrega'),
      observacoes: any(named: 'observacoes'),
      foto: any(named: 'foto'),
    ),
  );

  test('estado inicial é PedidosCarregando', () {
    expect(criarBloc().state, const PedidosCarregando());
  });

  // O bloc sempre publica o primeiro emit, mesmo quando ele é igual ao estado
  // inicial; por isso PedidosCarregando aparece no começo dos `expect`.
  group('PedidosIniciado', () {
    blocTest<PedidosBloc, PedidosState>(
      'emite PedidosSucesso com os pendentes quando o stream emite',
      setUp: () =>
          when(() => repository.observarPendentes())
              .thenAnswer((_) => Stream.value(lista)),
      build: criarBloc,
      act: (bloc) => bloc.add(const PedidosIniciado()),
      expect: () => [const PedidosCarregando(), PedidosSucesso(lista)],
    );

    blocTest<PedidosBloc, PedidosState>(
      'emite PedidosSucesso com lista vazia quando não há pedidos',
      setUp: () =>
          when(() => repository.observarPendentes())
              .thenAnswer((_) => Stream.value(const [])),
      build: criarBloc,
      act: (bloc) => bloc.add(const PedidosIniciado()),
      expect: () => const [PedidosCarregando(), PedidosSucesso([])],
    );

    blocTest<PedidosBloc, PedidosState>(
      'acompanha as atualizações em tempo real',
      setUp: () => when(() => repository.observarPendentes()).thenAnswer(
        (_) => Stream.fromIterable([
          [vestido],
          lista,
        ]),
      ),
      build: criarBloc,
      act: (bloc) => bloc.add(const PedidosIniciado()),
      expect: () => [
        const PedidosCarregando(),
        PedidosSucesso([vestido]),
        PedidosSucesso(lista),
      ],
    );

    blocTest<PedidosBloc, PedidosState>(
      'emite PedidosErro com a mensagem da Falha',
      setUp: () =>
          when(() => repository.observarPendentes())
              .thenAnswer((_) => Stream.error(const Falha('Sem permissão.'))),
      build: criarBloc,
      act: (bloc) => bloc.add(const PedidosIniciado()),
      expect: () => const [PedidosCarregando(), PedidosErro('Sem permissão.')],
    );

    blocTest<PedidosBloc, PedidosState>(
      'usa a mensagem genérica para erros desconhecidos',
      setUp: () =>
          when(() => repository.observarPendentes())
              .thenAnswer((_) => Stream.error(Exception('boom'))),
      build: criarBloc,
      act: (bloc) => bloc.add(const PedidosIniciado()),
      expect: () => const [
        PedidosCarregando(),
        PedidosErro(Falha.mensagemGenerica),
      ],
    );

    blocTest<PedidosBloc, PedidosState>(
      'tentar de novo após erro volta a carregar e assina o stream outra vez',
      setUp: () =>
          when(() => repository.observarPendentes())
              .thenAnswer((_) => Stream.value(lista)),
      build: criarBloc,
      seed: () => const PedidosErro('Sem conexão.'),
      act: (bloc) => bloc.add(const PedidosIniciado()),
      expect: () => [const PedidosCarregando(), PedidosSucesso(lista)],
      verify: (_) => verify(() => repository.observarPendentes()).called(1),
    );
  });

  group('PedidoCadastroSolicitado', () {
    final evento = PedidoCadastroSolicitado(
      clienteId: 'c1',
      clienteNome: 'Ana Clara',
      nome: 'Blusa Bordada',
      valorUnitarioCentavos: 9550,
      quantidade: 1,
      dataEntrega: DateTime(2026, 9, 12),
      observacoes: 'Bordado azul',
      foto: foto,
    );

    blocTest<PedidosBloc, PedidosState>(
      'chama cadastrar com os dados e emite salvando -> salvo',
      setUp: () => quandoCadastrar().thenAnswer((_) async {}),
      build: criarBloc,
      seed: () => PedidosSucesso(lista),
      act: (bloc) => bloc.add(evento),
      expect: () => [
        PedidosSucesso(lista, acao: AcaoPedido.salvando),
        PedidosSucesso(lista, acao: AcaoPedido.salvo),
      ],
      verify: (_) => verify(
        () => repository.cadastrar(
          clienteId: 'c1',
          clienteNome: 'Ana Clara',
          nome: 'Blusa Bordada',
          valorUnitarioCentavos: 9550,
          quantidade: 1,
          dataEntrega: DateTime(2026, 9, 12),
          observacoes: 'Bordado azul',
          foto: foto,
        ),
      ).called(1),
    );

    blocTest<PedidosBloc, PedidosState>(
      'emite falhou com a mensagem quando o repository lança Falha',
      setUp: () => quandoCadastrar().thenThrow(const Falha('Sem permissão.')),
      build: criarBloc,
      seed: () => PedidosSucesso(lista),
      act: (bloc) => bloc.add(evento),
      expect: () => [
        PedidosSucesso(lista, acao: AcaoPedido.salvando),
        PedidosSucesso(
          lista,
          acao: AcaoPedido.falhou,
          mensagemErro: 'Sem permissão.',
        ),
      ],
    );

    blocTest<PedidosBloc, PedidosState>(
      'emite fotoFalhou quando só o envio da foto falha',
      setUp: () => quandoCadastrar().thenThrow(const FalhaEnvioFoto()),
      build: criarBloc,
      seed: () => PedidosSucesso(lista),
      act: (bloc) => bloc.add(evento),
      expect: () => [
        PedidosSucesso(lista, acao: AcaoPedido.salvando),
        PedidosSucesso(
          lista,
          acao: AcaoPedido.fotoFalhou,
          mensagemErro: const FalhaEnvioFoto().mensagem,
        ),
      ],
    );
  });

  group('PedidoEdicaoSolicitada', () {
    final editado = vestido.copyWith(quantidade: 4, observacoes: () => null);

    blocTest<PedidosBloc, PedidosState>(
      'chama atualizar com o pedido e a foto e emite salvando -> salvo',
      setUp: () => when(
        () => repository.atualizar(
          any(),
          novaFoto: any(named: 'novaFoto'),
          removerFoto: any(named: 'removerFoto'),
        ),
      ).thenAnswer((_) async {}),
      build: criarBloc,
      seed: () => PedidosSucesso(lista),
      act: (bloc) => bloc.add(PedidoEdicaoSolicitada(editado, novaFoto: foto)),
      expect: () => [
        PedidosSucesso(lista, acao: AcaoPedido.salvando),
        PedidosSucesso(lista, acao: AcaoPedido.salvo),
      ],
      verify: (_) => verify(
        () => repository.atualizar(editado, novaFoto: foto, removerFoto: false),
      ).called(1),
    );

    blocTest<PedidosBloc, PedidosState>(
      'repassa o pedido para remover a foto',
      setUp: () => when(
        () => repository.atualizar(
          any(),
          novaFoto: any(named: 'novaFoto'),
          removerFoto: any(named: 'removerFoto'),
        ),
      ).thenAnswer((_) async {}),
      build: criarBloc,
      seed: () => PedidosSucesso(lista),
      act: (bloc) =>
          bloc.add(PedidoEdicaoSolicitada(editado, removerFoto: true)),
      verify: (_) => verify(
        () => repository.atualizar(editado, novaFoto: null, removerFoto: true),
      ).called(1),
    );
  });

  group('PedidoFinalizacaoSolicitada', () {
    blocTest<PedidosBloc, PedidosState>(
      'chama finalizar com o id e emite finalizando -> finalizado',
      setUp: () =>
          when(() => repository.finalizar('1')).thenAnswer((_) async {}),
      build: criarBloc,
      seed: () => PedidosSucesso(lista),
      act: (bloc) => bloc.add(const PedidoFinalizacaoSolicitada('1')),
      expect: () => [
        PedidosSucesso(lista, acao: AcaoPedido.finalizando),
        PedidosSucesso(lista, acao: AcaoPedido.finalizado),
      ],
      verify: (_) {
        verify(() => repository.finalizar('1')).called(1);
        verifyNever(() => repository.excluir(any()));
      },
    );

    blocTest<PedidosBloc, PedidosState>(
      'emite falhou quando finalizar lança Falha',
      setUp: () =>
          when(() => repository.finalizar('1'))
              .thenThrow(const Falha('Registro não encontrado.')),
      build: criarBloc,
      seed: () => PedidosSucesso(lista),
      act: (bloc) => bloc.add(const PedidoFinalizacaoSolicitada('1')),
      expect: () => [
        PedidosSucesso(lista, acao: AcaoPedido.finalizando),
        PedidosSucesso(
          lista,
          acao: AcaoPedido.falhou,
          mensagemErro: 'Registro não encontrado.',
        ),
      ],
    );
  });

  group('PedidoExclusaoSolicitada', () {
    blocTest<PedidosBloc, PedidosState>(
      'chama excluir com o id e emite excluindo -> excluido',
      setUp: () => when(() => repository.excluir('2')).thenAnswer((_) async {}),
      build: criarBloc,
      seed: () => PedidosSucesso(lista),
      act: (bloc) => bloc.add(const PedidoExclusaoSolicitada('2')),
      expect: () => [
        PedidosSucesso(lista, acao: AcaoPedido.excluindo),
        PedidosSucesso(lista, acao: AcaoPedido.excluido),
      ],
      verify: (_) {
        verify(() => repository.excluir('2')).called(1);
        verifyNever(() => repository.finalizar(any()));
      },
    );

    blocTest<PedidosBloc, PedidosState>(
      'emite falhou quando excluir lança Falha',
      setUp: () =>
          when(() => repository.excluir('2')).thenThrow(const Falha('Erro.')),
      build: criarBloc,
      seed: () => PedidosSucesso(lista),
      act: (bloc) => bloc.add(const PedidoExclusaoSolicitada('2')),
      expect: () => [
        PedidosSucesso(lista, acao: AcaoPedido.excluindo),
        PedidosSucesso(lista, acao: AcaoPedido.falhou, mensagemErro: 'Erro.'),
      ],
    );
  });

  group('lista em tempo real + ações', () {
    final controller = StreamController<List<Pedido>>();

    blocTest<PedidosBloc, PedidosState>(
      'o pedido finalizado sai da lista e a ação concluída é mantida',
      setUp: () =>
          when(() => repository.observarPendentes())
              .thenAnswer((_) => controller.stream),
      build: () {
        when(() => repository.finalizar('1')).thenAnswer((_) async {});
        return criarBloc();
      },
      act: (bloc) async {
        bloc.add(const PedidosIniciado());
        controller.add(lista);
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PedidoFinalizacaoSolicitada('1'));
        await Future<void>.delayed(Duration.zero);
        controller.add([calca]);
      },
      tearDown: controller.close,
      expect: () => [
        const PedidosCarregando(),
        PedidosSucesso(lista),
        PedidosSucesso(lista, acao: AcaoPedido.finalizando),
        PedidosSucesso(lista, acao: AcaoPedido.finalizado),
        PedidosSucesso([calca], acao: AcaoPedido.finalizado),
      ],
    );
  });

  test('AcaoPedido.emAndamento só nas ações que estão rodando', () {
    expect(AcaoPedido.values.where((a) => a.emAndamento), [
      AcaoPedido.salvando,
      AcaoPedido.finalizando,
      AcaoPedido.excluindo,
    ]);
  });

  test('PedidosSucesso.buscarPorId encontra ou devolve null', () {
    final estado = PedidosSucesso(lista);
    expect(estado.buscarPorId('2'), calca);
    expect(estado.buscarPorId('x'), isNull);
  });
}
