import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// Cartão branco com números lado a lado, separados por linhas verticais
/// ("18 Pedidos total | 3 Em aberto | R$2.180 Total faturado").
class CartaoNumeros extends StatelessWidget {
  const CartaoNumeros({super.key, required this.itens});

  final List<({String valor, String rotulo})> itens;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.cartao,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (final (i, item) in itens.indexed) ...[
              if (i > 0)
                const VerticalDivider(width: 1, color: AppColors.divisoria),
              Expanded(
                child: _Numero(valor: item.valor, rotulo: item.rotulo),
              ),
            ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.cartao,
      ),
      child: Column(
        spacing: AppSpacing.xxs,
        children: [
          // softWrap: false para o IntrinsicHeight medir uma linha só; sem
          // isso ele conta o valor quebrado e sobra espaço no cartão.
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
    );
  }
}
