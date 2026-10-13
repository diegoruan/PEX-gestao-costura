import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';
import '../../../../shared/widgets/etiqueta.dart';
import '../../../../shared/widgets/foto_pedido.dart';
import '../../../pedidos/domain/pedido.dart';

/// Pedido nas listas "Pedidos em Aberto" e "Últimas Entregas" do detalhe
/// do cliente. Sem [onTap] (entregues não têm detalhe), não é clicável.
class PedidoClienteCard extends StatelessWidget {
  const PedidoClienteCard({
    super.key,
    required this.pedido,
    required this.agora,
    this.onTap,
  });

  final Pedido pedido;
  final DateTime agora;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final entregueEm = pedido.dataFinalizacao ?? pedido.criadoEm;

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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.cartao,
              vertical: AppSpacing.md,
            ),
            child: Row(
              spacing: AppSpacing.md,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.icone),
                  child: SizedBox.square(
                    dimension: AppSizes.miniaturaCliente,
                    child: FotoPedido(
                      pedido: pedido,
                      tamanhoIcone: AppSizes.iconeMiniaturaCliente,
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
                        pedido.finalizado
                            ? 'Entregue em ${Formatadores.data(entregueEm)}'
                            : 'Entrega: '
                                  '${Formatadores.diaMesAno(pedido.dataEntrega)}',
                        style: AppTextStyles.legendaPequena,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxs),
                        child: Row(
                          spacing: AppSpacing.xsm,
                          children: [
                            _etiqueta(),
                            if (!pedido.finalizado)
                              Flexible(
                                child: Text(
                                  Formatadores.pecas(pedido.quantidade),
                                  style: AppTextStyles.legendaPequena,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
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

  // Mesmas cores das etiquetas da lista de pedidos.
  Etiqueta _etiqueta() {
    if (pedido.finalizado) {
      return const Etiqueta(
        texto: 'Finalizado',
        fundo: AppColors.sucessoFundo,
        cor: AppColors.sucesso,
      );
    }
    return switch (pedido.prazo(agora)) {
      PrazoPedido.atrasado => const Etiqueta(
        texto: 'Atrasado',
        fundo: AppColors.primariaSuave,
        cor: AppColors.erro,
      ),
      PrazoPedido.hoje => const Etiqueta(
        texto: 'Hoje!',
        fundo: AppColors.primariaSuave,
        cor: AppColors.primaria,
      ),
      PrazoPedido.estaSemana || PrazoPedido.depois => const Etiqueta(
        texto: 'Em andamento',
        fundo: AppColors.alertaFundo,
        cor: AppColors.alerta,
      ),
    };
  }
}
