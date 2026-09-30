import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// Cartão branco que agrupa campos separados por uma linha fina,
/// como no "Input Card" do Figma. Use com [CampoTexto].
class CartaoFormulario extends StatelessWidget {
  const CartaoFormulario({super.key, required this.campos});

  final List<Widget> campos;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.cartao,
      ),
      child: Column(
        children: [
          for (var i = 0; i < campos.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.divisoria,
              ),
            campos[i],
          ],
        ],
      ),
    );
  }
}
