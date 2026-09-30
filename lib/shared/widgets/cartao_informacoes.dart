import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import 'cartao_formulario.dart';

/// Cartão de leitura com um título e linhas "rótulo ... valor", como o
/// "Dados de contato" do detalhe do cliente.
class CartaoInformacoes extends StatelessWidget {
  const CartaoInformacoes({
    super.key,
    required this.titulo,
    required this.linhas,
  });

  final String titulo;
  final List<LinhaInformacao> linhas;

  @override
  Widget build(BuildContext context) {
    return CartaoFormulario(
      campos: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.cartao,
            AppSpacing.lg,
            AppSpacing.smd,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Text(titulo.toUpperCase(), style: AppTextStyles.rotuloSecao),
          ),
        ),
        ...linhas,
      ],
    );
  }
}

class LinhaInformacao extends StatelessWidget {
  const LinhaInformacao({
    super.key,
    required this.icone,
    required this.rotulo,
    required this.valor,
    this.destacar = false,
  });

  final Widget icone;
  final String rotulo;
  final String valor;

  /// Mostra o valor na cor principal (ex.: telefone, que é "acionável").
  final bool destacar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        spacing: AppSpacing.xsm,
        children: [
          icone,
          Text(rotulo, style: AppTextStyles.rotuloLinha),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: destacar
                  ? AppTextStyles.valorLinha.copyWith(color: AppColors.primaria)
                  : AppTextStyles.valorLinha,
            ),
          ),
        ],
      ),
    );
  }
}
