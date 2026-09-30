import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import 'link_texto.dart';

/// Mensagem centralizada para listas vazias, erros e itens não encontrados.
class EstadoMensagem extends StatelessWidget {
  const EstadoMensagem({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    this.textoAcao,
    this.onAcao,
  });

  final IconData icone;
  final String titulo;
  final String mensagem;
  final String? textoAcao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: AppSizes.iconeEstado,
              color: AppColors.placeholder,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              titulo,
              style: AppTextStyles.tituloItem,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              mensagem,
              style: AppTextStyles.subtitulo,
              textAlign: TextAlign.center,
            ),
            if (textoAcao != null) ...[
              const SizedBox(height: AppSpacing.md),
              LinkTexto(texto: textoAcao!, onPressed: onAcao),
            ],
          ],
        ),
      ),
    );
  }
}
