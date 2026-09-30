import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get claro {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaria,
      primary: AppColors.primaria,
      onPrimary: AppColors.textoSobrePrimaria,
      surface: AppColors.superficie,
      onSurface: AppColors.textoPrincipal,
      error: AppColors.erro,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: AppColors.fundo,
      dividerColor: AppColors.divisoria,
      textTheme: const TextTheme(
        headlineSmall: AppTextStyles.titulo,
        bodyMedium: AppTextStyles.corpo,
        bodySmall: AppTextStyles.subtitulo,
        labelLarge: AppTextStyles.botao,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaria,
        foregroundColor: AppColors.textoSobrePrimaria,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        hintStyle: AppTextStyles.placeholderCampo,
        errorStyle: AppTextStyles.erroCampo,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primaria,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaria,
          foregroundColor: AppColors.textoSobrePrimaria,
          disabledBackgroundColor: AppColors.primaria,
          disabledForegroundColor: AppColors.textoSobrePrimaria,
          elevation: 0,
          textStyle: AppTextStyles.botao,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medio),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaria,
          textStyle: AppTextStyles.link,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaria,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        contentTextStyle: AppTextStyles.snackbar,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pequeno),
        ),
      ),
    );
  }
}
