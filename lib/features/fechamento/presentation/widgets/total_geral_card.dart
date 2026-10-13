import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';
import '../../domain/fechamento_mensal.dart';

/// Cartão do fim da tela com o total geral do mês.
class TotalGeralCard extends StatelessWidget {
  const TotalGeralCard({
    super.key,
    required this.fechamento,
    required this.mesEncerrado,
  });

  final FechamentoMensal fechamento;

  /// Mostra o selo "Fechado": o mês já acabou e o total não muda mais.
  final bool mesEncerrado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.cartaoDestaque,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: AppSpacing.md,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                Text(
                  'Total geral — ${Formatadores.mesAnoTitulo(fechamento.mes)}',
                  style: AppTextStyles.legendaValor,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    Formatadores.moedaCentavos(fechamento.totalGeralCentavos),
                    style: AppTextStyles.totalGeral,
                  ),
                ),
                Text(
                  '${Formatadores.clientes(fechamento.clientes.length)} · '
                  '${Formatadores.pecas(fechamento.quantidadePecas)} '
                  '${fechamento.quantidadePecas == 1 ? 'finalizada' : 'finalizadas'}',
                  style: AppTextStyles.legendaValor,
                ),
              ],
            ),
          ),
          if (mesEncerrado) const _SeloFechado(),
        ],
      ),
    );
  }
}

class _SeloFechado extends StatelessWidget {
  const _SeloFechado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cartao,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.superficieSutil,
        borderRadius: BorderRadius.circular(AppRadius.icone),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xsm,
        children: [
          Icon(
            AppIcons.check,
            size: AppSizes.iconePequeno,
            color: AppColors.textoValor,
          ),
          Text('Fechado', style: AppTextStyles.selo),
        ],
      ),
    );
  }
}
