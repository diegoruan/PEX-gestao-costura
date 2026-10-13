import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pex_gestao_costura/app.dart';
import 'package:pex_gestao_costura/core/services/imagem_service.dart';
import 'package:pex_gestao_costura/features/auth/data/auth_repository.dart';
import 'package:pex_gestao_costura/features/auth/data/usuario.dart';
import 'package:pex_gestao_costura/features/clientes/data/cliente_repository.dart';
import 'package:pex_gestao_costura/features/clientes/domain/cliente.dart';
import 'package:pex_gestao_costura/features/clientes/presentation/cliente_detalhe_page.dart';
import 'package:pex_gestao_costura/features/pedidos/data/pedido_repository.dart';
import 'package:pex_gestao_costura/features/pedidos/domain/pedido.dart';
import 'package:pex_gestao_costura/features/pedidos/presentation/pedido_form_page.dart';
import 'package:pex_gestao_costura/shared/widgets/barra_navegacao.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockClienteRepository extends Mock implements ClienteRepository {}

class MockPedidoRepository extends Mock implements PedidoRepository {}

class MockImagemService extends Mock implements ImagemService {}

void main() {
  final ana = Cliente(
    id: 'ana',
    nome: 'Ana Clara',
    criadoEm: DateTime(2025, 3),
  );
  final pedro = Cliente(
    id: 'pedro',
    nome: 'Pedro Lima',
    criadoEm: DateTime(2025, 4),
  );

  Pedido pedido(
    String id,
    String nome, {
    String clienteId = 'ana',
    DateTime? finalizadoEm,
    int valorUnitarioCentavos = 9000,
    int quantidade = 2,
  }) {
    return Pedido(
      id: id,
      clienteId: clienteId,
      clienteNome: clienteId == 'ana' ? 'Ana Clara' : 'Pedro Lima',
      nome: nome,
      valorUnitarioCentavos: valorUnitarioCentavos,
      quantidade: quantidade,
      // Longe no futuro: o teste não depende da data em que roda.
      dataEntrega: DateTime(2099, 9, 3),
      status: finalizadoEm == null
          ? StatusPedido.pendente
          : StatusPedido.finalizado,
      dataFinalizacao: finalizadoEm,
      criadoEm: DateTime(2026, 7, 1),
    );
  }

  setUpAll(() async {
    Intl.defaultLocale = 'pt_BR';
    await initializeDateFormatting('pt_BR');
  });

  Future<void> abrirDetalheDaAna(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final auth = MockAuthRepository();
    final clientes = MockClienteRepository();
    final pedidos = MockPedidoRepository();
    registerFallbackValue(pedido('x', 'x'));
    when(() => pedidos.carregarFoto(any())).thenAnswer((_) async => null);
    when(() => auth.usuarioAtual).thenAnswer(
      (_) => Stream.value(const Usuario(id: 'uid', email: 'maria@email.com')),
    );
    when(() => clientes.observarAtivos())
        .thenAnswer((_) => Stream.value([ana, pedro]));
    when(() => pedidos.observarPendentes()).thenAnswer(
      (_) => Stream.value([
        pedido('p1', 'Vestido Floral'),
        pedido('p2', 'Calça Social', clienteId: 'pedro'),
      ]),
    );
    when(() => pedidos.observarFinalizados()).thenAnswer(
      (_) => Stream.value([
        pedido(
          'f1',
          'Vestido Festa',
          finalizadoEm: DateTime(2026, 8, 28),
          valorUnitarioCentavos: 14000,
        ),
        pedido(
          'f2',
          'Top de Alça',
          finalizadoEm: DateTime(2026, 8, 10),
          valorUnitarioCentavos: 4000,
        ),
      ]),
    );

    await tester.pumpWidget(
      App(
        authRepository: auth,
        clienteRepository: clientes,
        pedidoRepository: pedidos,
        imagemService: MockImagemService(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(BarraNavegacao),
        matching: find.text('Clientes'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana Clara'));
    await tester.pumpAndSettle();
  }

  testWidgets('mostra números, pedidos em aberto e últimas entregas', (
    tester,
  ) async {
    await abrirDetalheDaAna(tester);

    expect(find.byType(ClienteDetalhePage), findsOneWidget);
    expect(find.byType(BarraNavegacao), findsNothing);
    // 1 em aberto + 2 entregues; faturado = 2×140 + 2×40.
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    // O formatador separa "R$" do número com espaço não separável.
    expect(find.textContaining('360'), findsOneWidget);

    expect(find.text('Pedidos em Aberto'), findsOneWidget);
    expect(find.text('Vestido Floral'), findsOneWidget);
    expect(find.text('Calça Social'), findsNothing); // é do Pedro
    expect(find.text('Últimas Entregas'), findsOneWidget);
    expect(find.text('Vestido Festa'), findsOneWidget);
    expect(find.text('Entregue em 28/08/2026'), findsOneWidget);
  });

  testWidgets('"Novo Pedido para" abre o formulário com o cliente escolhido', (
    tester,
  ) async {
    await abrirDetalheDaAna(tester);

    await tester.tap(find.text('Novo Pedido para Ana Clara'));
    await tester.pumpAndSettle();

    expect(find.byType(PedidoFormPage), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(PedidoFormPage),
        matching: find.text('Ana Clara'),
      ),
      findsOneWidget,
    );
  });
}
