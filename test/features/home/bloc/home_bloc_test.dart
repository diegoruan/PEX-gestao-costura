import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pex_gestao_costura/core/errors/falha.dart';
import 'package:pex_gestao_costura/features/home/bloc/home_bloc.dart';
import 'package:pex_gestao_costura/features/pedidos/data/pedido_repository.dart';
import 'package:pex_gestao_costura/features/pedidos/domain/pedido.dart';

class MockPedidoRepository extends Mock implements PedidoRepository {}

void main() {
  late MockPedidoRepository repository;

  // "Hoje" fixo em 20/08/2026 para o teste não depender do dia em que roda.
  final agora = DateTime(2026, 8, 20, 10);

  Pedido pedido(
    String id, {
    String nome = 'Vestido',
    String clienteNome = 'Ana Clara',
    DateTime? dataEntrega,
    DateTime? finalizadoEm,
    int valorUnitarioCentavos = 10000,
    int quantidade = 1,
    DateTime? criadoEm,
  }) {
    return Pedido(
      id: id,
      clienteId: 'c-$clienteNome',
      clienteNome: clienteNome,
      nome: nome,
      valorUnitarioCentavos: valorUnitarioCentavos,
      quantidade: quantidade,
      dataEntrega: dataEntrega ?? DateTime(2026, 8, 30),
      status: finalizadoEm == null
          ? StatusPedido.pendente
          : StatusPedido.finalizado,
      dataFinalizacao: finalizadoEm,
      criadoEm: criadoEm ?? DateTime(2026, 8, 1),
    );
  }

  final atrasado = pedido(
    'p1',
    nome: 'Vestido Rosa',
    dataEntrega: DateTime(2026, 8, 18),
    criadoEm: DateTime(2026, 8, 10),
  );
  final hoje = pedido(
    'p2',
    nome: 'Calça Social',
    clienteNome: 'Pedro Lima',
    dataEntrega: DateTime(2026, 8, 20),
    criadoEm: DateTime(2026, 8, 12),
  );
  final daquiAUmaSemana = pedido('p3', criadoEm: DateTime(2026, 8, 19));
  final pendentes = [atrasado, hoje, daquiAUmaSemana];

  final finalizadoNoMes = pedido(
    'f1',
    finalizadoEm: DateTime(2026, 8, 19, 18),
    valorUnitarioCentavos: 14000,
    quantidade: 2,
  );
  final finalizadoNoMesPassado = pedido(
    'f2',
    finalizadoEm: DateTime(2026, 7, 31),
    valorUnitarioCentavos: 5000,
  );
  final finalizados = [finalizadoNoMes, finalizadoNoMesPassado];

  setUp(() {
    repository = MockPedidoRepository();
  });

  HomeBloc criarBloc() =>
      HomeBloc(pedidoRepository: repository, agora: () => agora);

  void quandoListar(
    Stream<List<Pedido>> pendentes,
    Stream<List<Pedido>> finalizados,
  ) {
    when(() => repository.observarPendentes()).thenAnswer((_) => pendentes);
    when(() => repository.observarFinalizados()).thenAnswer((_) => finalizados);
  }

  test('estado inicial é HomeCarregando', () {
    expect(criarBloc().state, const HomeCarregando());
  });

  // O bloc sempre publica o primeiro emit, mesmo quando ele é igual ao estado
  // inicial; por isso HomeCarregando aparece no começo dos `expect`.
  group('HomeIniciado', () {
    blocTest<HomeBloc, HomeState>(
      'emite o resumo quando as duas listas chegam',
      setUp: () =>
          quandoListar(Stream.value(pendentes), Stream.value(finalizados)),
      build: criarBloc,
      act: (bloc) => bloc.add(const HomeIniciado()),
      expect: () => [
        const HomeCarregando(),
        HomeSucesso(
          ResumoHome.calcular(
            pendentes: pendentes,
            finalizados: finalizados,
            agora: agora,
          ),
        ),
      ],
      verify: (bloc) {
        final resumo = (bloc.state as HomeSucesso).resumo;
        expect(resumo.pedidosEmAberto, 3);
        expect(resumo.pecasFinalizadasNoMes, 2);
        expect(resumo.totalMesCentavos, 28000);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'sem pedidos emite um resumo zerado',
      setUp: () => quandoListar(Stream.value([]), Stream.value([])),
      build: criarBloc,
      act: (bloc) => bloc.add(const HomeIniciado()),
      expect: () => const [
        HomeCarregando(),
        HomeSucesso(
          ResumoHome(
            pedidosEmAberto: 0,
            pecasFinalizadasNoMes: 0,
            totalMesCentavos: 0,
            atrasados: [],
            paraHoje: [],
            recentes: [],
          ),
        ),
      ],
    );

    final semFinalizados = StreamController<List<Pedido>>();
    blocTest<HomeBloc, HomeState>(
      'espera as duas listas antes de mostrar os números',
      setUp: () => quandoListar(Stream.value(pendentes), semFinalizados.stream),
      build: criarBloc,
      act: (bloc) => bloc.add(const HomeIniciado()),
      tearDown: semFinalizados.close,
      expect: () => const [HomeCarregando()],
    );

    blocTest<HomeBloc, HomeState>(
      'emite HomeErro com a mensagem da Falha',
      setUp: () => quandoListar(
        Stream.error(const Falha('Sem permissão.')),
        Stream.value(finalizados),
      ),
      build: criarBloc,
      act: (bloc) => bloc.add(const HomeIniciado()),
      expect: () => const [HomeCarregando(), HomeErro('Sem permissão.')],
    );

    blocTest<HomeBloc, HomeState>(
      'usa a mensagem genérica para erros desconhecidos e não volta ao sucesso',
      setUp: () => quandoListar(
        Stream.value(pendentes),
        Stream.error(Exception('boom')),
      ),
      build: criarBloc,
      act: (bloc) => bloc.add(const HomeIniciado()),
      expect: () => const [HomeCarregando(), HomeErro(Falha.mensagemGenerica)],
    );
  });

  group('ResumoHome.calcular', () {
    final resumo = ResumoHome.calcular(
      pendentes: pendentes,
      finalizados: finalizados,
      agora: agora,
    );

    test('separa atrasados e entregas de hoje', () {
      expect(resumo.atrasados, [atrasado]);
      expect(resumo.paraHoje, [hoje]);
      expect(resumo.temAviso, isTrue);
    });

    test('recentes juntam pendentes e finalizados, mais recente primeiro', () {
      expect(resumo.recentes, [finalizadoNoMes, daquiAUmaSemana, hoje]);
    });

    test('total do mês usa o calculador do fechamento, em centavos', () {
      expect(resumo.totalMesCentavos, 28000);
      expect(resumo.pecasFinalizadasNoMes, 2);
    });
  });

  group('textos do aviso', () {
    ResumoHome aviso({int hoje = 0, int atrasados = 0}) => ResumoHome(
      pedidosEmAberto: 0,
      pecasFinalizadasNoMes: 0,
      totalMesCentavos: 0,
      paraHoje: [
        for (var i = 0; i < hoje; i++)
          pedido('h$i', nome: 'Hoje $i', clienteNome: 'Ana Clara'),
      ],
      atrasados: [
        for (var i = 0; i < atrasados; i++)
          pedido('a$i', nome: 'Atrasado $i', clienteNome: 'Pedro Lima'),
      ],
      recentes: const [],
    );

    test('título como no Figma e nas outras combinações', () {
      expect(
        aviso(hoje: 2, atrasados: 1).tituloAviso,
        '2 entregas hoje e uma atrasada!',
      );
      expect(aviso(hoje: 1).tituloAviso, '1 entrega hoje!');
      expect(
        aviso(hoje: 1, atrasados: 3).tituloAviso,
        '1 entrega hoje e 3 atrasadas!',
      );
      expect(aviso(atrasados: 1).tituloAviso, '1 entrega atrasada!');
      expect(aviso(atrasados: 2).tituloAviso, '2 entregas atrasadas!');
      expect(aviso().temAviso, isFalse);
    });

    test('lista atrasados primeiro, com o primeiro nome do cliente', () {
      expect(
        aviso(hoje: 2, atrasados: 1).textoAviso,
        'Atrasado 0 (Pedro), Hoje 0 (Ana) e Hoje 1 (Ana)',
      );
      expect(aviso(hoje: 1).textoAviso, 'Hoje 0 (Ana)');
    });
  });
}
