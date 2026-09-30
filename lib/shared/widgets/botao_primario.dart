import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'indicador_carregando.dart';

class BotaoPrimario extends StatelessWidget {
  const BotaoPrimario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.carregando = false,
  });

  final String texto;
  final VoidCallback? onPressed;

  /// Enquanto `true`, o botão fica desabilitado e mostra um indicador.
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.botao,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: carregando ? null : onPressed,
          child: carregando
              ? const IndicadorCarregando(
                  tamanho: AppSizes.indicadorBotao,
                  cor: AppColors.textoSobrePrimaria,
                )
              : Text(texto),
        ),
      ),
    );
  }
}
