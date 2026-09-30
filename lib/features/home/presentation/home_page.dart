import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/botao_primario.dart';
import '../../auth/bloc/auth_bloc.dart';

// TODO(grupo): tela provisória, só para provar o fluxo de autenticação.
// Substituir pela home do Figma (frame "home").
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final nome = state is AuthAutenticado ? state.usuario.nomeExibicao : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Ateliê')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bem-vinda de volta,', style: AppTextStyles.subtitulo),
            const SizedBox(height: AppSpacing.xs),
            Text(
              nome,
              style: AppTextStyles.titulo,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            BotaoPrimario(
              texto: 'Clientes',
              onPressed: () => context.pushNamed(AppRoutes.clientes),
            ),
            const SizedBox(height: AppSpacing.md),
            BotaoPrimario(
              texto: 'Sair',
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthLogoutSolicitado()),
            ),
          ],
        ),
      ),
    );
  }
}
