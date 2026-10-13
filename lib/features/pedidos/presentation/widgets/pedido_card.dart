import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';
import '../../../../shared/widgets/etiqueta.dart';
import '../../../../shared/widgets/icone_svg.dart';
import '../../domain/pedido.dart';
import '../../../../shared/widgets/foto_pedido.dart';

class PedidoCard extends StatelessWidget {
  const PedidoCard({
    super.key,
    required this.pedido,
    required this.prazo,
    required this.onTap,
  });

  final Pedido pedido;
  final PrazoPedido prazo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.cartao,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medio),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cartao),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.md,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pequeno),
                    child: SizedBox.square(
                      dimension: AppSizes.miniaturaPedido,
                      child: FotoPedido(
                        pedido: pedido,
                        tamanhoIcone: AppSizes.iconeMiniatura,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _Informacoes(pedido: pedido, prazo: prazo),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatadores.moedaCompacta(pedido.totalCentavos),
                        style: AppTextStyles.valorItem,
                      ),
                      Text(
                        '${Formatadores.moedaCompacta(pedido.valorUnitarioCentavos)}/un',
                        style: AppTextStyles.legenda,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Informacoes extends StatelessWidget {
  const _Informacoes({required this.pedido, required this.prazo});

  final Pedido pedido;
  final PrazoPedido prazo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xxs,
      children: [
        Text(
          pedido.nome,
          style: AppTextStyles.tituloItem,
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
          child: EtiquetaPrazo(prazo: prazo),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Row(
            spacing: AppSpacing.smd,
            children: [
              _Meta(
                icone: AppAssets.iconeQuantidade,
                texto: Formatadores.pecas(pedido.quantidade),
              ),
              _Meta(
                icone: AppAssets.iconeCalendarioPequeno,
                texto: Formatadores.diaMes(pedido.dataEntrega),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icone, required this.texto});

  final String icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        IconeSvg(
          icone,
          tamanho: AppSizes.iconeMeta,
          cor: AppColors.textoSecundario,
        ),
        Text(texto, style: AppTextStyles.legenda),
      ],
    );
  }
}

/// Etiqueta colorida do prazo ("Entrega hoje!", "Atrasado"...).
class EtiquetaPrazo extends StatelessWidget {
  const EtiquetaPrazo({super.key, required this.prazo});

  final PrazoPedido prazo;

  @override
  Widget build(BuildContext context) {
    final (texto, fundo, cor) = switch (prazo) {
      PrazoPedido.atrasado => (
        'Atrasado',
        AppColors.primariaSuave,
        AppColors.erro,
      ),
      PrazoPedido.hoje => (
        'Entrega hoje!',
        AppColors.primariaSuave,
        AppColors.primaria,
      ),
      PrazoPedido.estaSemana || PrazoPedido.depois => (
        'Em andamento',
        AppColors.alertaFundo,
        AppColors.alerta,
      ),
    };
    return Etiqueta(texto: texto, fundo: fundo, cor: cor);
  }
}
