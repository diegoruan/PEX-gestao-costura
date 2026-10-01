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
import '../../features/home/presentation/home_page.dart';
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
