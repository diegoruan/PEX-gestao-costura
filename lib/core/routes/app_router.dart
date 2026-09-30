import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/presentation/cadastro_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/recuperar_senha_page.dart';
import '../../features/auth/presentation/splash_page.dart';
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
