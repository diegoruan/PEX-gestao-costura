import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';
import '../../../../shared/widgets/avatar_iniciais.dart';
import '../../../pedidos/domain/pedido.dart';
import '../../domain/fechamento_cliente.dart';

/// Cliente com o total a pagar e, abaixo, as peças que formam esse total.
class FechamentoClienteCard extends StatelessWidget {
  const FechamentoClienteCard({
    super.key,
    required this.cliente,
    required this.percentual,
  });

  final FechamentoCliente cliente;

  /// Fatia do cliente no total do mês ("34% do mês").
  final int percentual;

  @override
  Widget build(BuildContext context) {
    final pecas = cliente.quantidadePecas;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.cartao,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cartao),
            child: Row(
              spacing: AppSpacing.md,
              children: [
                AvatarIniciais(nome: cliente.clienteNome),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xxs,
                    children: [
                      Text(
                        cliente.clienteNome,
                        style: AppTextStyles.tituloItem,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        pecas == 1
                            ? '1 peça finalizada'
                            : '$pecas peças finalizadas',
                        style: AppTextStyles.legenda,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: AppSpacing.xxs,
                  children: [
                    Text(
                      Formatadores.moedaCentavos(cliente.totalCentavos),
                      style: AppTextStyles.valorItem,
                    ),
                    Text('$percentual% do mês', style: AppTextStyles.legenda),
                  ],
                ),
              ],
            ),
          ),
          for (final pedido in cliente.pedidos) ...[
            const Divider(height: 1, thickness: 1, color: AppColors.divisoria),
            _LinhaPeca(pedido: pedido),
          ],
        ],
      ),
    );
  }
}

class _LinhaPeca extends StatelessWidget {
  const _LinhaPeca({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cartao,
        vertical: AppSpacing.smd,
      ),
      child: Row(
        spacing: AppSpacing.md,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xxs,
              children: [
                Text(
                  pedido.nome,
                  style: AppTextStyles.textoDetalhe,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${pedido.quantidade} × '
                  '${Formatadores.moedaCompacta(pedido.valorUnitarioCentavos)}',
                  style: AppTextStyles.legenda,
                ),
              ],
            ),
          ),
          Text(
            Formatadores.moedaCompacta(pedido.totalCentavos),
            style: AppTextStyles.valorDetalhe,
          ),
        ],
      ),
    );
  }
}
