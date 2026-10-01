import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pex_gestao_costura/core/errors/falha.dart';
import 'package:pex_gestao_costura/features/clientes/bloc/clientes_bloc.dart';
import 'package:pex_gestao_costura/features/clientes/data/cliente_repository.dart';
import 'package:pex_gestao_costura/features/clientes/domain/cliente.dart';

class MockClienteRepository extends Mock implements ClienteRepository {}

void main() {
  late MockClienteRepository repository;

  final ana = Cliente(
    id: '1',
    nome: 'Ana Clara',
    telefone: '(11) 9 8765-4321',
    criadoEm: DateTime(2025, 3, 10),
  );
  final pedro = Cliente(id: '2', nome: 'Pedro Lima', criadoEm: DateTime(2025));
  final lista = [ana, pedro];

  setUp(() {
    repository = MockClienteRepository();
  });

  ClientesBloc criarBloc() => ClientesBloc(clienteRepository: repository);

  test('estado inicial é ClientesCarregando', () {
    expect(criarBloc().state, const ClientesCarregando());
  });

  // O bloc sempre publica o primeiro emit, mesmo quando ele é igual ao estado
  // inicial; por isso ClientesCarregando aparece no começo dos `expect`.
  group('ClientesIniciado', () {
    blocTest<ClientesBloc, ClientesState>(
      'emite ClientesSucesso com a lista quando o stream emite',
      setUp: () =>
          when(() => repository.observarAtivos())
              .thenAnswer((_) => Stream.value(lista)),
      build: criarBloc,
      act: (bloc) => bloc.add(const ClientesIniciado()),
      expect: () => [const ClientesCarregando(), ClientesSucesso(lista)],
    );

    blocTest<ClientesBloc, ClientesState>(
      'emite ClientesSucesso com lista vazia quando não há clientes',
      setUp: () =>
          when(() => repository.observarAtivos())
              .thenAnswer((_) => Stream.value(const [])),
      build: criarBloc,
      act: (bloc) => bloc.add(const ClientesIniciado()),
      expect: () => const [ClientesCarregando(), ClientesSucesso([])],
    );

    blocTest<ClientesBloc, ClientesState>(
      'acompanha as atualizações em tempo real',
      setUp: () => when(() => repository.observarAtivos()).thenAnswer(
        (_) => Stream.fromIterable([
          [ana],
          lista,
        ]),
      ),
      build: criarBloc,
      act: (bloc) => bloc.add(const ClientesIniciado()),
      expect: () => [
        const ClientesCarregando(),
        ClientesSucesso([ana]),
        ClientesSucesso(lista),
      ],
    );

    blocTest<ClientesBloc, ClientesState>(
      'emite ClientesErro com a mensagem da Falha',
      setUp: () =>
          when(() => repository.observarAtivos())
              .thenAnswer((_) => Stream.error(const Falha('Sem permissão.'))),
      build: criarBloc,
      act: (bloc) => bloc.add(const ClientesIniciado()),
      expect: () => const [
        ClientesCarregando(),
        ClientesErro('Sem permissão.'),
      ],
    );

    blocTest<ClientesBloc, ClientesState>(
      'usa a mensagem genérica para erros desconhecidos',
      setUp: () =>
          when(() => repository.observarAtivos())
              .thenAnswer((_) => Stream.error(Exception('boom'))),
      build: criarBloc,
      act: (bloc) => bloc.add(const ClientesIniciado()),
      expect: () => const [
        ClientesCarregando(),
        ClientesErro(Falha.mensagemGenerica),
      ],
    );

    blocTest<ClientesBloc, ClientesState>(
      'tentar de novo após erro volta a carregar e assina o stream outra vez',
      setUp: () =>
          when(() => repository.observarAtivos())
              .thenAnswer((_) => Stream.value(lista)),
      build: criarBloc,
      seed: () => const ClientesErro('Sem conexão.'),
      act: (bloc) => bloc.add(const ClientesIniciado()),
      expect: () => [const ClientesCarregando(), ClientesSucesso(lista)],
      verify: (_) => verify(() => repository.observarAtivos()).called(1),
    );
  });

  group('ClienteCadastroSolicitado', () {
    blocTest<ClientesBloc, ClientesState>(
      'chama cadastrar com os dados e emite salvando -> salvo',
      setUp: () => when(
        () => repository.cadastrar(
          nome: 'Carla',
          apelido: 'Carlinha',
          telefone: '11 99999-0000',
          email: 'carla@email.com',
          endereco: 'Centro, Joinville',
          observacoes: null,
        ),
      ).thenAnswer((_) async {}),
      build: criarBloc,
      seed: () => ClientesSucesso(lista),
      act: (bloc) => bloc.add(
        const ClienteCadastroSolicitado(
          nome: 'Carla',
          apelido: 'Carlinha',
          telefone: '11 99999-0000',
          email: 'carla@email.com',
          endereco: 'Centro, Joinville',
        ),
      ),
      expect: () => [
        ClientesSucesso(lista, acao: AcaoCliente.salvando),
        ClientesSucesso(lista, acao: AcaoCliente.salvo),
      ],
      verify: (_) => verify(
        () => repository.cadastrar(
          nome: 'Carla',
          apelido: 'Carlinha',
          telefone: '11 99999-0000',
          email: 'carla@email.com',
          endereco: 'Centro, Joinville',
          observacoes: null,
        ),
      ).called(1),
    );

    blocTest<ClientesBloc, ClientesState>(
      'emite falhou com a mensagem quando o repository lança Falha',
      setUp: () => when(
        () => repository.cadastrar(
          nome: any(named: 'nome'),
          apelido: any(named: 'apelido'),
          telefone: any(named: 'telefone'),
          email: any(named: 'email'),
          endereco: any(named: 'endereco'),
          observacoes: any(named: 'observacoes'),
        ),
      ).thenThrow(const Falha('Sem permissão.')),
      build: criarBloc,
      seed: () => ClientesSucesso(lista),
      act: (bloc) => bloc.add(const ClienteCadastroSolicitado(nome: 'Carla')),
      expect: () => [
        ClientesSucesso(lista, acao: AcaoCliente.salvando),
        ClientesSucesso(
          lista,
          acao: AcaoCliente.falhou,
          mensagemErro: 'Sem permissão.',
        ),
      ],
    );
  });

  group('ClienteEdicaoSolicitada', () {
    final anaEditada = ana.copyWith(
      nome: 'Ana Clara Souza',
      telefone: () => null,
    );

    blocTest<ClientesBloc, ClientesState>(
      'chama atualizar com o cliente editado e emite salvando -> salvo',
      setUp: () =>
          when(() => repository.atualizar(anaEditada)).thenAnswer((_) async {}),
      build: criarBloc,
      seed: () => ClientesSucesso(lista),
      act: (bloc) => bloc.add(ClienteEdicaoSolicitada(anaEditada)),
      expect: () => [
        ClientesSucesso(lista, acao: AcaoCliente.salvando),
        ClientesSucesso(lista, acao: AcaoCliente.salvo),
      ],
      verify: (_) => verify(() => repository.atualizar(anaEditada)).called(1),
    );
  });

  group('ClienteInativacaoSolicitada', () {
    blocTest<ClientesBloc, ClientesState>(
      'chama inativar com o id e emite inativando -> inativado',
      setUp: () =>
          when(() => repository.inativar('1')).thenAnswer((_) async {}),
      build: criarBloc,
      seed: () => ClientesSucesso(lista),
      act: (bloc) => bloc.add(const ClienteInativacaoSolicitada('1')),
      expect: () => [
        ClientesSucesso(lista, acao: AcaoCliente.inativando),
        ClientesSucesso(lista, acao: AcaoCliente.inativado),
      ],
      verify: (_) {
        verify(() => repository.inativar('1')).called(1);
        verifyNever(
          () => repository.cadastrar(
            nome: any(named: 'nome'),
            telefone: any(named: 'telefone'),
            observacoes: any(named: 'observacoes'),
          ),
        );
      },
    );
  });

  group('lista em tempo real + ações', () {
    final controller = StreamController<List<Cliente>>();

    blocTest<ClientesBloc, ClientesState>(
      'uma atualização do stream depois de salvar mantém a ação concluída',
      setUp: () =>
          when(() => repository.observarAtivos())
              .thenAnswer((_) => controller.stream),
      build: () {
        when(() => repository.inativar('2')).thenAnswer((_) async {});
        return criarBloc();
      },
      act: (bloc) async {
        bloc.add(const ClientesIniciado());
        controller.add(lista);
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ClienteInativacaoSolicitada('2'));
        await Future<void>.delayed(Duration.zero);
        controller.add([ana]);
      },
      tearDown: controller.close,
      expect: () => [
        const ClientesCarregando(),
        ClientesSucesso(lista),
        ClientesSucesso(lista, acao: AcaoCliente.inativando),
        ClientesSucesso(lista, acao: AcaoCliente.inativado),
        ClientesSucesso([ana], acao: AcaoCliente.inativado),
      ],
    );
  });

  test('ClientesSucesso.buscarPorId encontra ou devolve null', () {
    final estado = ClientesSucesso(lista);
    expect(estado.buscarPorId('2'), pedro);
    expect(estado.buscarPorId('x'), isNull);
  });
}
