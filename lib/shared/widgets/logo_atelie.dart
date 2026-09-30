import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

class LogoAtelie extends StatelessWidget {
  const LogoAtelie({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.logo,
      height: AppSizes.logo,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaria,
        borderRadius: BorderRadius.circular(AppRadius.grande),
        boxShadow: AppShadows.logo,
      ),
      child: SvgPicture.asset(
        AppAssets.logoCarretel,
        width: AppSizes.logoIcone,
        height: AppSizes.logoIcone,
      ),
    );
  }
}
