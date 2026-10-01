import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

enum EstiloBotaoIcone { claro, translucido, primario }

/// Botão quadrado de 36px usado nos cabeçalhos (voltar, editar, adicionar...).
class BotaoIcone extends StatelessWidget {
  const BotaoIcone({
    super.key,
    required this.icone,
    required this.descricao,
    required this.onPressed,
    this.estilo = EstiloBotaoIcone.claro,
  });

  final Widget icone;

  /// Lido por leitores de tela e mostrado ao segurar o botão.
  final String descricao;
  final VoidCallback? onPressed;
  final EstiloBotaoIcone estilo;

  @override
  Widget build(BuildContext context) {
    final (cor, sombra) = switch (estilo) {
      EstiloBotaoIcone.claro => (AppColors.superficie, AppShadows.botaoIcone),
      EstiloBotaoIcone.translucido => (
        AppColors.superficieTranslucida,
        const <BoxShadow>[],
      ),
      EstiloBotaoIcone.primario => (
        AppColors.primaria,
        AppShadows.botaoIconePrimario,
      ),
    };

    return Tooltip(
      message: descricao,
      child: Container(
        width: AppSizes.botaoIcone,
        height: AppSizes.botaoIcone,
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(AppRadius.icone),
          boxShadow: sombra,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadius.icone),
            child: Center(child: icone),
          ),
        ),
      ),
    );
  }
}
