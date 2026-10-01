import 'package:flutter/material.dart';

/// Paleta extraída do Figma (arquivo PEX). Nenhuma tela deve usar `Color(...)`
/// diretamente: se precisar de uma cor nova, adicione aqui.
abstract final class AppColors {
  static const primaria = Color(0xFFC9788A);
  static const primariaClara = Color(0xFFF2D7DD);
  static const primariaSuave = Color(0xFFFCE4E8);

  static const fundo = Color(0xFFF2EBE3);
  static const superficie = Color(0xFFFFFFFF);
  static const superficieTranslucida = Color(0x99FFFFFF);
  static const bege = Color(0xFFEDE3D8);
  static const begeEscuro = Color(0xFFE8D5C4);

  static const textoPrincipal = Color(0xFF3D2B23);
  static const textoSecundario = Color(0xFF9E8880);
  static const textoValor = Color(0xFF7A5C4F);
  static const placeholder = Color(0xFFC8B8B0);
  static const textoSobrePrimaria = Color(0xFFFFFFFF);

  static const divisoria = Color(0xFFF5EDE7);
  static const borda = Color(0xFFEEE7E0);

  static const sucesso = Color(0xFF6A9E7F);
  static const sucessoFundo = Color(0xFFD4EBDD);
  static const alerta = Color(0xFFC9973A);
  static const alertaTexto = Color(0xFF8B6520);
  static const alertaFundo = Color(0xFFFFF3D8);
  static const erro = Color(0xFFB3424A);

  static const sombra = textoPrincipal;

  /// Fundos dos avatares de iniciais, na ordem usada no Figma.
  static const avatares = [primaria, textoValor, alerta, sucesso];
}
