import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const xsm = 6.0;
  static const sm = 8.0;
  static const smd = 10.0;
  static const md = 12.0;
  static const cartao = 14.0;
  static const lg = 16.0;
  static const campo = 18.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 64.0;
}

abstract final class AppRadius {
  static const icone = 10.0;
  static const pequeno = 12.0;
  static const item = 14.0;
  static const medio = 16.0;
  static const grande = 24.0;
}

abstract final class AppSizes {
  static const logo = 72.0;
  static const logoIcone = 36.0;
  static const indicadorBotao = 20.0;
  static const iconeCampo = 20.0;
  static const iconeMinimo = 12.0;
  static const iconeContato = 14.0;
  static const iconePequeno = 16.0;
  static const iconeBotao = 18.0;
  static const iconeEstado = 48.0;
  static const botaoIcone = 36.0;
  static const avatarLista = 50.0;
  static const avatarDestaque = 80.0;
  static const bordaAvatar = 4.0;
}

abstract final class AppShadows {
  static final cartao = [
    BoxShadow(
      color: AppColors.sombra.withValues(alpha: 0.07),
      offset: const Offset(0, 2),
      blurRadius: 10,
    ),
  ];

  static final botao = [
    BoxShadow(
      color: AppColors.primaria.withValues(alpha: 0.25),
      offset: const Offset(0, 4),
      blurRadius: 8,
    ),
  ];

  static final itemLista = [
    BoxShadow(
      color: AppColors.sombra.withValues(alpha: 0.06),
      offset: const Offset(0, 1),
      blurRadius: 4,
    ),
  ];

  static final botaoIcone = [
    BoxShadow(
      color: AppColors.sombra.withValues(alpha: 0.08),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  static final botaoIconePrimario = [
    BoxShadow(
      color: AppColors.primaria.withValues(alpha: 0.35),
      offset: const Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static final avatarDestaque = [
    BoxShadow(
      color: AppColors.primaria.withValues(alpha: 0.3),
      offset: const Offset(0, 4),
      blurRadius: 8,
    ),
  ];

  static final logo = [
    BoxShadow(
      color: AppColors.primaria.withValues(alpha: 0.25),
      offset: const Offset(0, 4),
      blurRadius: 6,
    ),
  ];
}
