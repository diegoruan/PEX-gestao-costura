import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class IndicadorCarregando extends StatelessWidget {
  const IndicadorCarregando({
    super.key,
    this.tamanho = 32,
    this.cor = AppColors.primaria,
  });

  final double tamanho;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: tamanho,
      child: CircularProgressIndicator(
        strokeWidth: tamanho / 10,
        valueColor: AlwaysStoppedAnimation(cor),
      ),
    );
  }
}
