import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';
import '../../bloc/home_state.dart';

/// Os três cartões do topo. Sem [resumo] (carregando ou erro), mostra "–".
class EstatisticasHome extends StatelessWidget {
  const EstatisticasHome({super.key, required this.resumo});

  final ResumoHome? resumo;

  @override
  Widget build(BuildContext context) {
    final resumo = this.resumo;
    const vazio = '–';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          _Cartao(
            icone: AppIcons.agenda,
            cor: AppColors.primaria,
            valor: resumo == null ? vazio : '${resumo.pedidosEmAberto}',
            rotulo: 'Em aberto',
          ),
          _Cartao(
            icone: AppIcons.check,
            cor: AppColors.sucesso,
            valor: resumo == null ? vazio : '${resumo.pecasFinalizadasNoMes}',
            rotulo: 'Finalizadas',
          ),
          _Cartao(
            icone: AppIcons.dolar,
            cor: AppColors.alerta,
            valor: resumo == null
                ? vazio
                : Formatadores.moedaCompacta(resumo.totalMesCentavos),
            rotulo: 'Este mês',
          ),
        ],
      ),
    );
  }
}

class _Cartao extends StatelessWidget {
  const _Cartao({
    required this.icone,
    required this.cor,
    required this.valor,
    required this.rotulo,
  });

  final IconData icone;
  final Color cor;
  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.cartao,
        ),
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(AppRadius.medio),
          boxShadow: AppShadows.cartao,
        ),
        child: Column(
          spacing: AppSpacing.xxs,
          children: [
            Icon(icone, size: AppSizes.iconeEstatistica, color: cor),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              // "R$ 12.345" encolhe em vez de quebrar. O softWrap: false é o
              // que importa: sem ele o IntrinsicHeight mede o texto quebrado
              // em duas linhas e todos os cartões ganham um espaço vazio.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  valor,
                  style: AppTextStyles.numeroDestaque,
                  softWrap: false,
                ),
              ),
            ),
            Text(rotulo, style: AppTextStyles.legenda),
          ],
        ),
      ),
    );
  }
}
