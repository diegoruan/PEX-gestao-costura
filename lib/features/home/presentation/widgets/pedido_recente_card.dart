import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';
import '../../../../shared/widgets/etiqueta.dart';
import '../../../../shared/widgets/foto_pedido.dart';
import '../../../pedidos/domain/pedido.dart';

/// Pedido da lista "Pedidos Recentes", pendente ou já finalizado.
class PedidoRecenteCard extends StatelessWidget {
  const PedidoRecenteCard({
    super.key,
    required this.pedido,
    required this.agora,
    required this.onTap,
  });

  final Pedido pedido;
  final DateTime agora;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.item),
        boxShadow: AppShadows.itemLista,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.item),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cartao),
            child: Row(
              spacing: AppSpacing.md,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pequeno),
                  child: SizedBox.square(
                    dimension: AppSizes.miniaturaHistorico,
                    child: FotoPedido(
                      pedido: pedido,
                      tamanhoIcone: AppSizes.iconeMiniatura,
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
                        style: AppTextStyles.tituloItemPequeno,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${pedido.clienteNome} · '
                        '${Formatadores.pecas(pedido.quantidade)}',
                        style: AppTextStyles.legenda,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: _Situacao(pedido: pedido, agora: agora),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatadores.moedaCompacta(pedido.totalCentavos),
                  style: AppTextStyles.valorItemCompacto,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Etiqueta e data: "Atrasado · Entrega: hoje", "Finalizado · Entregue: 01/09".
class _Situacao extends StatelessWidget {
  const _Situacao({required this.pedido, required this.agora});

  final Pedido pedido;
  final DateTime agora;

  @override
  Widget build(BuildContext context) {
    final prazo = pedido.prazo(agora);
    final finalizadoEm = pedido.dataFinalizacao;

    // Mesmas cores das etiquetas da lista de pedidos e do histórico.
    final (texto, fundo, cor) = pedido.finalizado
        ? ('Finalizado', AppColors.sucessoFundo, AppColors.sucesso)
        : prazo == PrazoPedido.atrasado
        ? ('Atrasado', AppColors.primariaSuave, AppColors.erro)
        : ('Em aberto', AppColors.alertaFundo, AppColors.alerta);

    final data = pedido.finalizado
        ? 'Entregue: ${Formatadores.diaMesNumerico(finalizadoEm ?? pedido.criadoEm)}'
        : prazo == PrazoPedido.hoje
        ? 'Entrega: hoje'
        : 'Entrega: ${Formatadores.diaMesNumerico(pedido.dataEntrega)}';

    return Row(
      spacing: AppSpacing.sm,
      children: [
        Etiqueta(texto: texto, fundo: fundo, cor: cor),
        Flexible(
          child: Text(
            data,
            style: AppTextStyles.legendaPequena,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
