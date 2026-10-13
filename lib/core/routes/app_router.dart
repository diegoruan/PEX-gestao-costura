import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/presentation/cadastro_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/recuperar_senha_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/clientes/bloc/clientes_bloc.dart';
import '../../features/clientes/data/cliente_repository.dart';
import '../../features/clientes/presentation/cliente_detalhe_page.dart';
import '../../features/clientes/presentation/cliente_form_page.dart';
import '../../features/clientes/presentation/clientes_page.dart';
import '../../features/fechamento/bloc/fechamento_bloc.dart';
import '../../features/fechamento/presentation/fechamento_page.dart';
import '../../features/historico/bloc/historico_bloc.dart';
import '../../features/historico/presentation/historico_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/pedidos/bloc/pedidos_bloc.dart';
import '../../features/pedidos/data/pedido_repository.dart';
import '../../features/pedidos/presentation/pedido_detalhe_page.dart';
import '../../features/pedidos/presentation/pedido_form_page.dart';
import '../../features/pedidos/presentation/pedidos_page.dart';
import 'app_routes.dart';

GoRouter criarRouter(AuthBloc authBloc) {
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
      GoRoute(
        name: AppRoutes.home,
        path: AppRoutes.homePath,
        builder: (context, state) => const HomePage(),
      ),
      _rotasClientes(),
      _rotasPedidos(),
      _rotaHistorico(),
      _rotaFechamento(),
    ],
  );
}

/// O ShellRoute cria um único ClientesBloc para lista, detalhe e formulário:
/// todas as telas compartilham a mesma assinatura do Firestore, e o bloc é
/// fechado quando o usuário sai da área de clientes.
ShellRoute _rotasClientes() {
  return ShellRoute(
    builder: (context, state, child) => BlocProvider(
      create: (context) =>
          ClientesBloc(clienteRepository: context.read<ClienteRepository>())
            ..add(const ClientesIniciado()),
      child: child,
    ),
    routes: [
      GoRoute(
        name: AppRoutes.clientes,
        path: AppRoutes.clientesPath,
        builder: (context, state) => const ClientesPage(),
        routes: [
          // "novo" precisa vir antes de ":id", senão seria lido como um id.
          GoRoute(
            name: AppRoutes.clienteNovo,
            path: AppRoutes.clienteNovoPath,
            builder: (context, state) => const ClienteFormPage(),
          ),
          GoRoute(
            name: AppRoutes.clienteDetalhe,
            path: AppRoutes.clienteDetalhePath,
            builder: (context, state) => ClienteDetalhePage(
              clienteId: state.pathParameters[AppRoutes.paramId]!,
            ),
            routes: [
              GoRoute(
                name: AppRoutes.clienteEditar,
                path: AppRoutes.clienteEditarPath,
                builder: (context, state) => ClienteFormPage(
                  clienteId: state.pathParameters[AppRoutes.paramId],
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Mesma ideia das rotas de clientes: um PedidosBloc para lista, detalhe e
/// formulário. O formulário também precisa da lista de clientes ativos, então
/// esta área ganha o seu próprio ClientesBloc (criado só quando o formulário
/// o lê, por ser lazy) em vez de um global: assim ele nasce depois do login e
/// é fechado ao sair, sem escutar o Firestore de uma sessão antiga.
ShellRoute _rotasPedidos() {
  return ShellRoute(
    builder: (context, state, child) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              PedidosBloc(pedidoRepository: context.read<PedidoRepository>())
                ..add(const PedidosIniciado()),
        ),
        BlocProvider(
          create: (context) =>
              ClientesBloc(clienteRepository: context.read<ClienteRepository>())
                ..add(const ClientesIniciado()),
        ),
      ],
      child: child,
    ),
    routes: [
      GoRoute(
        name: AppRoutes.pedidos,
        path: AppRoutes.pedidosPath,
        builder: (context, state) => const PedidosPage(),
        routes: [
          // "novo" precisa vir antes de ":id", senão seria lido como um id.
          GoRoute(
            name: AppRoutes.pedidoNovo,
            path: AppRoutes.pedidoNovoPath,
            builder: (context, state) => const PedidoFormPage(),
          ),
          GoRoute(
            name: AppRoutes.pedidoDetalhe,
            path: AppRoutes.pedidoDetalhePath,
            builder: (context, state) => PedidoDetalhePage(
              pedidoId: state.pathParameters[AppRoutes.paramId]!,
            ),
            routes: [
              GoRoute(
                name: AppRoutes.pedidoEditar,
                path: AppRoutes.pedidoEditarPath,
                builder: (context, state) => PedidoFormPage(
                  pedidoId: state.pathParameters[AppRoutes.paramId],
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Uma tela só, então o HistoricoBloc nasce na própria rota (sem ShellRoute)
/// e é fechado ao sair dela.
GoRoute _rotaHistorico() {
  return GoRoute(
    name: AppRoutes.historico,
    path: AppRoutes.historicoPath,
    builder: (context, state) => BlocProvider(
      create: (context) =>
          HistoricoBloc(pedidoRepository: context.read<PedidoRepository>())
            ..add(const HistoricoIniciado()),
      child: const HistoricoPage(),
    ),
  );
}

/// Mesma ideia do histórico: uma tela, um bloc criado na própria rota.
GoRoute _rotaFechamento() {
  return GoRoute(
    name: AppRoutes.fechamento,
    path: AppRoutes.fechamentoPath,
    builder: (context, state) => BlocProvider(
      create: (context) =>
          FechamentoBloc(pedidoRepository: context.read<PedidoRepository>())
            ..add(const FechamentoIniciado()),
      child: const FechamentoPage(),
    ),
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
      (naSplash || emRotaPublica) ? AppRoutes.homePath : null,
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
