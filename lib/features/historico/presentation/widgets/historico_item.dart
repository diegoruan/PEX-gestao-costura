import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';
import '../../../../shared/widgets/etiqueta.dart';
import '../../../../shared/widgets/foto_pedido.dart';
import '../../../pedidos/domain/pedido.dart';
import '../../bloc/historico_state.dart';

/// Peça finalizada na lista do histórico. Não é clicável: o Figma não tem
/// tela de detalhe do histórico.
class HistoricoItem extends StatelessWidget {
  const HistoricoItem({super.key, required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cartao,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.item),
        boxShadow: AppShadows.itemLista,
      ),
      child: Row(
        spacing: AppSpacing.md,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pequeno),
            child: SizedBox.square(
              dimension: AppSizes.miniaturaHistorico,
              child: FotoPedido(
                pedido: pedido,
                tamanhoIcone: AppSizes.iconeMiniaturaHistorico,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xxs,
              children: [
                Text(
                  pedido.nome,
                  style: AppTextStyles.tituloItemCompacto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  pedido.clienteNome,
                  style: AppTextStyles.legenda,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Row(
                    spacing: AppSpacing.sm,
                    children: [
                      const Etiqueta(
                        texto: 'Entregue',
                        fundo: AppColors.sucessoFundo,
                        cor: AppColors.sucesso,
                      ),
                      Text(
                        Formatadores.data(pedido.finalizadoEm),
                        style: AppTextStyles.legendaPequena,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: AppSpacing.xxs,
            children: [
              Text(
                Formatadores.moedaCompacta(pedido.totalCentavos),
                style: AppTextStyles.valorItemCompacto,
              ),
              Text(
                '${pedido.quantidade} × '
                '${Formatadores.moedaCompacta(pedido.valorUnitarioCentavos)}',
                style: AppTextStyles.legenda,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
