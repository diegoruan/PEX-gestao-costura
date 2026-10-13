import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/icone_svg.dart';
import '../../bloc/home_state.dart';

/// Faixa amarela: entregas de hoje e atrasadas.
class AvisoEntregas extends StatelessWidget {
  const AvisoEntregas({super.key, required this.resumo});

  final ResumoHome resumo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.cartao,
      ),
      decoration: BoxDecoration(
        color: AppColors.alertaFundo,
        borderRadius: BorderRadius.circular(AppRadius.item),
      ),
      child: Row(
        spacing: AppSpacing.md,
        children: [
          const IconeSvg(
            AppAssets.iconeAlerta,
            tamanho: AppSizes.iconeAlerta,
            cor: AppColors.alerta,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xxs,
              children: [
                Text(resumo.tituloAviso, style: AppTextStyles.alertaTitulo),
                Text(resumo.textoAviso, style: AppTextStyles.alertaMensagem),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
