import 'package:flutter/material.dart';

import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import 'icone_svg.dart';

/// Linha clicável de uma lista (cliente, pedido...): [inicio] à esquerda,
/// título e conteúdo no meio e uma seta à direita.
class CartaoItemLista extends StatelessWidget {
  const CartaoItemLista({
    super.key,
    required this.inicio,
    required this.titulo,
    this.conteudo,
    required this.onTap,
  });

  final Widget inicio;
  final String titulo;

  /// Linhas extras abaixo do título (telefone, etiquetas...).
  final Widget? conteudo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.itemLista,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medio),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cartao),
            child: Row(
              spacing: AppSpacing.cartao,
              children: [
                inicio,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xxs,
                    children: [
                      Text(
                        titulo,
                        style: AppTextStyles.tituloItem,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ?conteudo,
                    ],
                  ),
                ),
                const IconeSvg(
                  AppAssets.iconeChevron,
                  tamanho: AppSizes.iconePequeno,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
