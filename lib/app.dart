import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';

class App extends StatefulWidget {
  const App({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Criados uma única vez: o router depende do AuthBloc para o redirect, e
  // recriá-los num rebuild perderia a pilha de navegação e a sessão.
  late final AuthBloc _authBloc = AuthBloc(
    authRepository: widget.authRepository,
  )..add(const AuthIniciado());
  late final GoRouter _router = criarRouter(_authBloc);

  @override
  void dispose() {
    _router.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: widget.authRepository),
      ],
      child: MultiBlocProvider(
        providers: [BlocProvider<AuthBloc>.value(value: _authBloc)],
        child: MaterialApp.router(
          title: 'Ateliê',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          routerConfig: _router,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    );
  }
}
