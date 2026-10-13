import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pex_gestao_costura/app.dart';
import 'package:pex_gestao_costura/core/routes/navegacao_shell.dart';
import 'package:pex_gestao_costura/core/services/imagem_service.dart';
import 'package:pex_gestao_costura/features/auth/data/auth_repository.dart';
import 'package:pex_gestao_costura/features/auth/data/usuario.dart';
import 'package:pex_gestao_costura/features/auth/presentation/login_page.dart';
import 'package:pex_gestao_costura/features/clientes/data/cliente_repository.dart';
import 'package:pex_gestao_costura/features/clientes/presentation/clientes_page.dart';
import 'package:pex_gestao_costura/features/fechamento/presentation/fechamento_page.dart';
import 'package:pex_gestao_costura/features/historico/presentation/historico_page.dart';
import 'package:pex_gestao_costura/features/home/presentation/home_page.dart';
import 'package:pex_gestao_costura/features/pedidos/data/pedido_repository.dart';
import 'package:pex_gestao_costura/features/pedidos/presentation/pedido_form_page.dart';
import 'package:pex_gestao_costura/features/pedidos/presentation/pedidos_page.dart';
import 'package:pex_gestao_costura/shared/widgets/barra_navegacao.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockClienteRepository extends Mock implements ClienteRepository {}

class MockPedidoRepository extends Mock implements PedidoRepository {}

class MockImagemService extends Mock implements ImagemService {}

void main() {
  late MockAuthRepository auth;
  late MockClienteRepository clientes;
  late MockPedidoRepository pedidos;
  late StreamController<Usuario?> sessao;

  const maria = Usuario(id: 'uid-a', email: 'maria@email.com', nome: 'Maria');
  const joana = Usuario(id: 'uid-b', email: 'joana@email.com', nome: 'Joana');

  setUpAll(() async {
    Intl.defaultLocale = 'pt_BR';
    await initializeDateFormatting('pt_BR');
  });

  setUp(() {
    auth = MockAuthRepository();
    clientes = MockClienteRepository();
    pedidos = MockPedidoRepository();
    sessao = StreamController<Usuario?>.broadcast();

    when(() => auth.usuarioAtual).thenAnswer((_) => sessao.stream);
    when(() => auth.sair()).thenAnswer((_) async => sessao.add(null));
    when(() => clientes.observarAtivos()).thenAnswer((_) => Stream.value([]));
    when(() => pedidos.observarPendentes()).thenAnswer((_) => Stream.value([]));
    when(() => pedidos.observarFinalizados())
        .thenAnswer((_) => Stream.value([]));
  });

  tearDown(() => sessao.close());

  Future<void> abrirApp(WidgetTester tester, {Usuario? usuario}) async {
    // Tela de celular, como no Figma.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      App(
        authRepository: auth,
        clienteRepository: clientes,
        pedidoRepository: pedidos,
        imagemService: MockImagemService(),
      ),
    );
    sessao.add(usuario);
    await tester.pumpAndSettle();
  }

  int abaAtual(WidgetTester tester) =>
      tester.widget<BarraNavegacao>(find.byType(BarraNavegacao)).indiceAtual;

  Future<void> tocarNaAba(WidgetTester tester, String rotulo) async {
    await tester.tap(
      find.descendant(
        of: find.byType(BarraNavegacao),
        matching: find.text(rotulo),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sem sessão vai para o login, sem barra de navegação', (
    tester,
  ) async {
    await abrirApp(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(BarraNavegacao), findsNothing);
  });

  testWidgets('com sessão abre a Home com a aba Início selecionada', (
    tester,
  ) async {
    await abrirApp(tester, usuario: maria);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Maria'), findsOneWidget);
    expect(abaAtual(tester), AbasNavegacao.inicio);
  });

  testWidgets('cada item da barra abre a sua aba e fica selecionado', (
    tester,
  ) async {
    await abrirApp(tester, usuario: maria);

    final abas = {
      'Pedidos': (AbasNavegacao.pedidos, PedidosPage),
      'Clientes': (AbasNavegacao.clientes, ClientesPage),
      'Histórico': (AbasNavegacao.historico, HistoricoPage),
      'Fechamento': (AbasNavegacao.fechamento, FechamentoPage),
      'Início': (AbasNavegacao.inicio, HomePage),
    };
    for (final MapEntry(key: rotulo, value: (indice, pagina)) in abas.entries) {
      await tocarNaAba(tester, rotulo);
      expect(abaAtual(tester), indice, reason: rotulo);
      expect(find.byType(pagina), findsOneWidget, reason: rotulo);
    }
  });

  testWidgets('voltar fora da Home leva para a Home', (tester) async {
    await abrirApp(tester, usuario: maria);
    await tocarNaAba(tester, 'Clientes');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(abaAtual(tester), AbasNavegacao.inicio);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('formulário abre por cima da barra e voltar retorna', (
    tester,
  ) async {
    await abrirApp(tester, usuario: maria);

    await tester.tap(find.text('Novo Pedido'));
    await tester.pumpAndSettle();
    expect(find.byType(PedidoFormPage), findsOneWidget);
    expect(find.byType(BarraNavegacao), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(BarraNavegacao), findsOneWidget);
  });

  testWidgets('logout volta ao login e a nova conta ganha blocs novos', (
    tester,
  ) async {
    await abrirApp(tester, usuario: maria);
    await tocarNaAba(tester, 'Pedidos');
    verify(() => pedidos.observarPendentes()).called(2); // Home + Pedidos

    sessao.add(null);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(BarraNavegacao), findsNothing);

    sessao.add(joana);
    await tester.pumpAndSettle();
    expect(find.text('Joana'), findsOneWidget);
    expect(find.text('Maria'), findsNothing);
    // Novo HomeBloc: assinou os pendentes de novo, já com a conta nova.
    verify(() => pedidos.observarPendentes()).called(1);
  });
}
