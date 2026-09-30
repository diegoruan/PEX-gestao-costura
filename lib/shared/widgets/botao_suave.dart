import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import 'indicador_carregando.dart';

/// Botão largo de fundo rosado, para ações secundárias como "Excluir cliente".
class BotaoSuave extends StatelessWidget {
  const BotaoSuave({
    super.key,
    required this.texto,
    required this.icone,
    required this.onPressed,
    this.carregando = false,
  });

  final String texto;
  final Widget icone;
  final VoidCallback? onPressed;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: carregando ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primariaSuave,
          foregroundColor: AppColors.primaria,
          disabledForegroundColor: AppColors.primaria,
          textStyle: AppTextStyles.botaoSuave,
          padding: const EdgeInsets.all(AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.item),
          ),
        ),
        child: carregando
            ? const IndicadorCarregando(tamanho: AppSizes.indicadorBotao)
            : Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.sm,
                children: [icone, Text(texto)],
              ),
      ),
    );
  }
}
