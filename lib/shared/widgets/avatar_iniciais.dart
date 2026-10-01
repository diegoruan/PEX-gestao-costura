import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/texto.dart';

/// Círculo com as iniciais do nome. A cor sai do próprio nome, então a mesma
/// pessoa tem sempre a mesma cor em qualquer tela.
class AvatarIniciais extends StatelessWidget {
  const AvatarIniciais({super.key, required this.nome, this.destaque = false});

  final String nome;

  /// Versão grande (80px, com borda branca e sombra) do topo do detalhe.
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final soma = Texto.normalizar(nome).codeUnits.fold(0, (a, b) => a + b);
    final cor = AppColors.avatares[soma % AppColors.avatares.length];
    final tamanho = destaque ? AppSizes.avatarDestaque : AppSizes.avatarLista;

    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cor,
        shape: BoxShape.circle,
        border: destaque
            ? Border.all(
                color: AppColors.superficie,
                width: AppSizes.bordaAvatar,
              )
            : null,
        boxShadow: destaque ? AppShadows.avatarDestaque : null,
      ),
      child: Text(
        Texto.iniciais(nome),
        style: destaque
            ? AppTextStyles.iniciaisDestaque
            : AppTextStyles.iniciais,
      ),
    );
  }
}
