import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';
import '../../bloc/historico_state.dart';

/// Cartão do topo: peças, total faturado e clientes do que está filtrado.
class ResumoHistoricoCard extends StatelessWidget {
  const ResumoHistoricoCard({super.key, required this.resumo});

  final ResumoHistorico resumo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.itemLista,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Numero(valor: '${resumo.pecas}', rotulo: 'Peças entregues'),
            const VerticalDivider(width: 1, color: AppColors.borda),
            _Numero(
              valor: Formatadores.moedaCompacta(resumo.totalCentavos),
              rotulo: 'Total faturado',
            ),
            const VerticalDivider(width: 1, color: AppColors.borda),
            _Numero(valor: '${resumo.clientes}', rotulo: 'Clientes ativos'),
          ],
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.valor, required this.rotulo});

  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          spacing: AppSpacing.xxs,
          children: [
            // Totais grandes ("R$ 12.345,50") encolhem em vez de quebrar.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valor,
                style: AppTextStyles.numeroResumo,
                softWrap: false,
              ),
            ),
            Text(
              rotulo,
              style: AppTextStyles.legendaMinima,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
