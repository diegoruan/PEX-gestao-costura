import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import 'indicador_carregando.dart';

/// Botão compacto do cabeçalho, como o "Salvar" do formulário.
class BotaoPequeno extends StatelessWidget {
  const BotaoPequeno({
    super.key,
    required this.texto,
    required this.onPressed,
    this.carregando = false,
  });

  final String texto;
  final VoidCallback? onPressed;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.icone),
        boxShadow: AppShadows.botaoIconePrimario,
      ),
      child: ElevatedButton(
        onPressed: carregando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          textStyle: AppTextStyles.botaoPequeno,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.icone),
          ),
        ),
        child: carregando
            ? const IndicadorCarregando(
                tamanho: AppSizes.iconePequeno,
                cor: AppColors.textoSobrePrimaria,
              )
            : Text(texto),
      ),
    );
  }
}
