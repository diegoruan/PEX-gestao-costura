import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/icone_svg.dart';
import '../../../../shared/widgets/link_texto.dart';

/// Faixa rosada com sino, como o "Entregas para hoje" da lista.
class AvisoPedido extends StatelessWidget {
  const AvisoPedido({
    super.key,
    required this.titulo,
    required this.mensagem,
    this.textoAcao,
    this.onAcao,
  });

  final String titulo;
  final String mensagem;
  final String? textoAcao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cartao,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.primariaSuave,
        borderRadius: BorderRadius.circular(AppRadius.pequeno),
      ),
      child: Row(
        spacing: AppSpacing.smd,
        children: [
          const IconeSvg(AppAssets.iconeSino, tamanho: AppSizes.iconeResumo),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xxs,
              children: [
                Text(titulo, style: AppTextStyles.avisoTitulo),
                Text(mensagem, style: AppTextStyles.avisoTexto),
                if (textoAcao != null)
                  LinkTexto(texto: textoAcao!, onPressed: onAcao),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
