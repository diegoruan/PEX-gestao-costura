import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_text_styles.dart';

class CampoBusca extends StatelessWidget {
  const CampoBusca({super.key, required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.item),
        boxShadow: AppShadows.itemLista,
      ),
      child: Row(
        spacing: AppSpacing.smd,
        children: [
          const Icon(
            AppIcons.busca,
            size: AppSizes.iconePequeno,
            color: AppColors.textoSecundario,
          ),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.textoCampo,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.subtitulo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
