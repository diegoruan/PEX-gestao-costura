import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tipografia do Figma. Todas as telas usam a família Inter (em assets/fonts).
abstract final class AppTextStyles {
  static const fontFamily = 'Inter';

  static const marca = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: AppColors.primaria,
  );

  static const marcaSubtitulo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    color: AppColors.textoSecundario,
  );

  static const titulo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const subtitulo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSecundario,
  );

  static const rotuloCampo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.textoSecundario,
  );

  static const textoCampo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textoPrincipal,
  );

  static final placeholderCampo = textoCampo.copyWith(
    color: AppColors.placeholder,
  );

  static const erroCampo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.erro,
  );

  static const botao = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textoSobrePrimaria,
  );

  static const link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaria,
  );

  static const linkSecundario = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textoSecundario,
  );

  static const corpo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textoPrincipal,
  );

  static const tituloPagina = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  /// Cabeçalho de grupo em caixa alta ("DADOS PESSOAIS", letra da lista).
  static const rotuloSecao = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    color: AppColors.textoSecundario,
  );

  static const tituloItem = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const legenda = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSecundario,
  );

  static const tituloDestaque = TextStyle(
    fontFamily: fontFamily,
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const iniciais = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textoSobrePrimaria,
  );

  static final iniciaisDestaque = iniciais.copyWith(fontSize: 30);

  static const rotuloLinha = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSecundario,
  );

  static const valorLinha = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const textoLongo = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.7,
    color: AppColors.textoPrincipal,
  );

  static const botaoPequeno = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textoSobrePrimaria,
  );

  static const botaoSuave = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primaria,
  );

  static const snackbar = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textoSobrePrimaria,
  );
}
