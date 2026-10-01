import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// Pergunta antes de uma ação irreversível. Devolve `true` só se o usuário
/// confirmar (fechar o diálogo tocando fora conta como cancelar).
Future<bool> confirmarAcao(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String textoConfirmar,
}) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medio),
      ),
      title: Text(titulo, style: AppTextStyles.tituloPagina),
      content: Text(mensagem, style: AppTextStyles.corpo),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textoSecundario,
          ),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.erro),
          child: Text(textoConfirmar),
        ),
      ],
    ),
  );
  return confirmou ?? false;
}
