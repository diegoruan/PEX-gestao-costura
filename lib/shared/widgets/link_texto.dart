import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

class LinkTexto extends StatelessWidget {
  const LinkTexto({
    super.key,
    required this.texto,
    required this.onPressed,
    this.secundario = false,
  });

  final String texto;
  final VoidCallback? onPressed;

  /// Versão discreta (cinza), para ações menos importantes.
  final bool secundario;

  @override
  Widget build(BuildContext context) {
    final estilo = secundario
        ? AppTextStyles.linkSecundario
        : AppTextStyles.link;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: estilo.color,
        textStyle: estilo,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(texto, textAlign: TextAlign.center),
    );
  }
}
