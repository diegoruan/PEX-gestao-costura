import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';
import '../../domain/fechamento_mensal.dart';

/// Topo do fechamento: total do mês em destaque e os três cartõezinhos.
class ResumoFechamento extends StatelessWidget {
  const ResumoFechamento({super.key, required this.fechamento});

  final FechamentoMensal fechamento;

  @override
  Widget build(BuildContext context) {
    final clientes = fechamento.clientes.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Total do mês',
          style: AppTextStyles.legendaValor,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            Formatadores.moedaCentavos(fechamento.totalGeralCentavos),
            style: AppTextStyles.totalDestaque,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${Formatadores.pecas(fechamento.quantidadePecas)} · '
          '${Formatadores.clientes(clientes)}',
          style: AppTextStyles.legendaValor,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.md,
            children: [
              _Estatistica(
                icone: AppIcons.pacote,
                valor: '${fechamento.quantidadePecas}',
                rotulo: 'Peças entregues',
              ),
              _Estatistica(
                icone: AppIcons.pessoas,
                valor: '$clientes',
                rotulo: 'Clientes ativos',
              ),
              _Estatistica(
                icone: AppIcons.calendario,
                valor: Formatadores.mesAnoCurto(fechamento.mes),
                rotulo: 'Referência',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Estatistica extends StatelessWidget {
  const _Estatistica({
    required this.icone,
    required this.valor,
    required this.rotulo,
  });

  final IconData icone;
  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(AppRadius.item),
          boxShadow: AppShadows.cartao,
        ),
        child: Column(
          children: [
            Icon(icone, size: AppSizes.iconeResumo, color: AppColors.primaria),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valor,
                style: AppTextStyles.numeroEstatistica,
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
