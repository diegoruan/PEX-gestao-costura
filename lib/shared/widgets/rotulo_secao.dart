import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// Título de grupo em caixa alta ("DADOS PESSOAIS", letra "A" da lista).
class RotuloSecao extends StatelessWidget {
  const RotuloSecao(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(texto.toUpperCase(), style: AppTextStyles.rotuloSecao),
    );
  }
}
