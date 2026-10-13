import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';

/// "‹  Agosto 2026  ›". [onProximo] nulo desabilita a seta da direita.
class SeletorMes extends StatelessWidget {
  const SeletorMes({
    super.key,
    required this.mes,
    required this.onAnterior,
    required this.onProximo,
  });

  final DateTime mes;
  final VoidCallback onAnterior;
  final VoidCallback? onProximo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppSpacing.lg,
      children: [
        _BotaoSeta(
          descricao: 'Mês anterior',
          icone: AppIcons.voltar,
          onPressed: onAnterior,
        ),
        Text(Formatadores.mesAnoTitulo(mes), style: AppTextStyles.tituloMes),
        _BotaoSeta(
          descricao: 'Próximo mês',
          icone: AppIcons.avancar,
          onPressed: onProximo,
        ),
      ],
    );
  }
}

class _BotaoSeta extends StatelessWidget {
  const _BotaoSeta({
    required this.descricao,
    required this.icone,
    required this.onPressed,
  });

  final String descricao;
  final IconData icone;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: descricao,
      child: Material(
        color: AppColors.superficieSutil,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: AppSizes.botaoIcone,
            child: Center(
              child: Icon(
                icone,
                size: AppSizes.iconePequeno,
                color: onPressed == null
                    ? AppColors.placeholder
                    : AppColors.textoPrincipal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
