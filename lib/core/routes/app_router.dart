import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/presentation/cadastro_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/recuperar_senha_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/clientes/domain/cliente.dart';
import '../../features/clientes/presentation/cliente_detalhe_page.dart';
import '../../features/clientes/presentation/cliente_form_page.dart';
import '../../features/clientes/presentation/clientes_page.dart';
import '../../features/fechamento/presentation/fechamento_page.dart';
import '../../features/historico/presentation/historico_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/pedidos/presentation/pedido_detalhe_page.dart';
import '../../features/pedidos/presentation/pedido_form_page.dart';
import '../../features/pedidos/presentation/pedidos_page.dart';
import 'app_routes.dart';
import 'escopo_sessao.dart';
import 'navegacao_shell.dart';

GoRouter criarRouter(AuthBloc authBloc) {
  // Criadas aqui (e não globais) para cada router ter as suas: os testes
  // montam vários.
  final sessaoKey = GlobalKey<NavigatorState>(debugLabel: 'sessao');

  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    refreshListenable: _BlocRefreshListenable(authBloc.stream),
    redirect: (context, state) => _redirecionar(authBloc.state, state),
    routes: [
      GoRoute(
        name: AppRoutes.splash,
        path: AppRoutes.splashPath,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        name: AppRoutes.login,
        path: AppRoutes.loginPath,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: AppRoutes.cadastro,
        path: AppRoutes.cadastroPath,
        builder: (context, state) => const CadastroPage(),
      ),
      GoRoute(
        name: AppRoutes.recuperarSenha,
        path: AppRoutes.recuperarSenhaPath,
        builder: (context, state) =>
            RecuperarSenhaPage(emailInicial: state.extra as String?),
      ),
      // Tudo o que exige login fica dentro deste shell; ver EscopoSessao.
      // Ele tem navigator próprio ([sessaoKey]): detalhes e formulários abrem
      // nele, por cima da barra, e continuam enxergando os blocs da sessão.
      // No navigator raiz eles ficariam acima dos providers.
      ShellRoute(
        navigatorKey: sessaoKey,
        builder: (context, state, child) => EscopoSessao(child: child),
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) => NavegacaoShell(shell: shell),
            // Mesma ordem de AbasNavegacao.
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    name: AppRoutes.home,
                    path: AppRoutes.homePath,
                    builder: (context, state) => const HomePage(),
                  ),
                ],
              ),
              StatefulShellBranch(routes: [_rotasPedidos(sessaoKey)]),
              StatefulShellBranch(routes: [_rotasClientes(sessaoKey)]),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    name: AppRoutes.historico,
                    path: AppRoutes.historicoPath,
                    builder: (context, state) => const HistoricoPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    name: AppRoutes.fechamento,
                    path: AppRoutes.fechamentoPath,
                    builder: (context, state) => const FechamentoPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// /clientes, /clientes/novo, /clientes/:id e /clientes/:id/editar. Só a
/// lista fica na aba; o resto abre por cima da barra, como no Figma.
GoRoute _rotasClientes(GlobalKey<NavigatorState> sessaoKey) {
  return GoRoute(
    name: AppRoutes.clientes,
    path: AppRoutes.clientesPath,
    builder: (context, state) => const ClientesPage(),
    routes: [
      // "novo" precisa vir antes de ":id", senão seria lido como um id.
      GoRoute(
        parentNavigatorKey: sessaoKey,
        name: AppRoutes.clienteNovo,
        path: AppRoutes.clienteNovoPath,
        builder: (context, state) => const ClienteFormPage(),
      ),
      GoRoute(
        parentNavigatorKey: sessaoKey,
        name: AppRoutes.clienteDetalhe,
        path: AppRoutes.clienteDetalhePath,
        builder: (context, state) => ClienteDetalhePage(
          clienteId: state.pathParameters[AppRoutes.paramId]!,
        ),
        routes: [
          GoRoute(
            parentNavigatorKey: sessaoKey,
            name: AppRoutes.clienteEditar,
            path: AppRoutes.clienteEditarPath,
            builder: (context, state) => ClienteFormPage(
              clienteId: state.pathParameters[AppRoutes.paramId],
            ),
          ),
        ],
      ),
    ],
  );
}

/// /pedidos, /pedidos/novo, /pedidos/:id e /pedidos/:id/editar. Só a lista
/// fica na aba; o resto abre por cima da barra, como no Figma.
GoRoute _rotasPedidos(GlobalKey<NavigatorState> sessaoKey) {
  return GoRoute(
    name: AppRoutes.pedidos,
    path: AppRoutes.pedidosPath,
    builder: (context, state) => const PedidosPage(),
    routes: [
      // "novo" precisa vir antes de ":id", senão seria lido como um id.
      GoRoute(
        parentNavigatorKey: sessaoKey,
        name: AppRoutes.pedidoNovo,
        path: AppRoutes.pedidoNovoPath,
        // O detalhe do cliente pode mandar o cliente já escolhido.
        builder: (context, state) =>
            PedidoFormPage(clienteInicial: state.extra as Cliente?),
      ),
      GoRoute(
        parentNavigatorKey: sessaoKey,
        name: AppRoutes.pedidoDetalhe,
        path: AppRoutes.pedidoDetalhePath,
        builder: (context, state) => PedidoDetalhePage(
          pedidoId: state.pathParameters[AppRoutes.paramId]!,
        ),
        routes: [
          GoRoute(
            parentNavigatorKey: sessaoKey,
            name: AppRoutes.pedidoEditar,
            path: AppRoutes.pedidoEditarPath,
            builder: (context, state) => PedidoFormPage(
              pedidoId: state.pathParameters[AppRoutes.paramId],
            ),
          ),
        ],
      ),
    ],
  );
}

String? _redirecionar(AuthState auth, GoRouterState state) {
  final local = state.matchedLocation;
  final naSplash = local == AppRoutes.splashPath;
  final emRotaPublica = AppRoutes.publicas.contains(local);

  return switch (auth) {
    // Ainda verificando a sessão salva no dispositivo.
    AuthInicial() => naSplash ? null : AppRoutes.splashPath,
    // Não redireciona durante uma requisição para a tela não trocar no meio.
    AuthCarregando() => null,
    AuthAutenticado() =>
      (naSplash || emRotaPublica || local == '/') ? AppRoutes.homePath : null,
    AuthNaoAutenticado() ||
    AuthErro() ||
    AuthRecuperacaoEnviada() => emRotaPublica ? null : AppRoutes.loginPath,
  };
}

/// O go_router só reavalia o `redirect` quando um Listenable notifica;
/// este adaptador faz isso a cada novo estado do AuthBloc.
class _BlocRefreshListenable extends ChangeNotifier {
  _BlocRefreshListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
