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
    this.icone,
  });

  final String texto;
  final VoidCallback? onPressed;

  /// Enquanto `true`, o botão fica desabilitado e mostra um indicador.
  final bool carregando;

  /// Ícone opcional antes do texto, como o disquete de "Salvar Pedido".
  final Widget? icone;

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
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.sm,
                  // Flexible: textos com nome ("Novo Pedido para ...") podem
                  // não caber e ganham reticências em vez de estourar.
                  children: [
                    ?icone,
                    Flexible(
                      child: Text(
                        texto,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
