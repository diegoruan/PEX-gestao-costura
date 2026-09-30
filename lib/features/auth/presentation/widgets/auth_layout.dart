import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/logo_atelie.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.formulario,
    required this.acoes,
  });

  final String titulo;
  final String subtitulo;
  final Widget formulario;

  /// Botão principal seguido dos links secundários.
  final List<Widget> acoes;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg + AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.lg + AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            child: Column(
              children: [
                const _Marca(),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  titulo,
                  style: AppTextStyles.titulo,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitulo,
                  style: AppTextStyles.subtitulo,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                formulario,
                const SizedBox(height: AppSpacing.xxl),
                for (var i = 0; i < acoes.length; i++) ...[
                  if (i == 1) const SizedBox(height: AppSpacing.lg),
                  acoes[i],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: AppSpacing.xxl, bottom: AppSpacing.md),
      child: Column(
        children: [
          LogoAtelie(),
          SizedBox(height: AppSpacing.md),
          Text('Ateliê', style: AppTextStyles.marca),
          SizedBox(height: AppSpacing.xs),
          Text('GESTÃO DE COSTURAS', style: AppTextStyles.marcaSubtitulo),
        ],
      ),
    );
  }
}
