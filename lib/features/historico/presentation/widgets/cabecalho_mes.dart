import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';
import '../../../../shared/widgets/icone_svg.dart';
import '../../bloc/historico_state.dart';

/// "Setembro 2026 ............ R$ 270,00" acima das peças de cada mês.
class CabecalhoMes extends StatelessWidget {
  const CabecalhoMes({super.key, required this.mes});

  final MesHistorico mes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Os itens abaixo já começam com AppSpacing.lg de margem.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xxl + AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.smd,
      ),
      child: Row(
        children: [
          const IconeSvg(
            AppAssets.iconeCalendarioPequeno,
            tamanho: AppSizes.iconeMes,
            cor: AppColors.textoValor,
          ),
          const SizedBox(width: AppSpacing.xsm),
          Expanded(
            child: Text(
              Formatadores.mesAnoTitulo(mes.mes),
              style: AppTextStyles.rotuloMes,
            ),
          ),
          Text(
            Formatadores.moedaCentavos(mes.totalCentavos),
            style: AppTextStyles.totalMes,
          ),
        ],
      ),
    );
  }
}
