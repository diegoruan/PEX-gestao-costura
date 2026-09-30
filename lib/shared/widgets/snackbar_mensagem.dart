import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

void mostrarSnackbarErro(BuildContext context, String mensagem) =>
    _mostrar(context, mensagem, AppColors.erro);

void mostrarSnackbarSucesso(BuildContext context, String mensagem) =>
    _mostrar(context, mensagem, AppColors.sucesso);

void _mostrar(BuildContext context, String mensagem, Color cor) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensagem), backgroundColor: cor));
}
