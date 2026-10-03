import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';
import '../../../../shared/widgets/icone_svg.dart';

/// Linha de um [CartaoFormulario] que abre uma escolha ao ser tocada
/// (cliente, data...). É um FormField para validar junto com os outros
/// campos e mostrar o erro embaixo, como o [CampoTexto].
class CampoSelecao<T> extends FormField<T> {
  CampoSelecao({
    super.key,
    required String rotulo,
    required T? valorInicial,
    required Widget Function(T? valor) conteudo,
    required Future<T?> Function(T? atual) escolher,
    Widget? fim,
    ValueChanged<T>? onChanged,
    super.validator,
    super.enabled,
  }) : super(
         initialValue: valorInicial,
         autovalidateMode: AutovalidateMode.onUserInteraction,
         builder: (field) {
           Future<void> abrir() async {
             final novo = await escolher(field.value);
             if (novo == null) return;
             field.didChange(novo);
             onChanged?.call(novo);
           }

           return InkWell(
             onTap: field.widget.enabled ? abrir : null,
             child: _LinhaCampo(
               rotulo: rotulo,
               fim: fim,
               erro: field.errorText,
               child: conteudo(field.value),
             ),
           );
         },
       );
}

/// Linha só de leitura, como a "Data de entrada".
class LinhaInformativa extends StatelessWidget {
  const LinhaInformativa({
    super.key,
    required this.rotulo,
    required this.valor,
  });

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return _LinhaCampo(
      rotulo: rotulo,
      child: Text(valor, style: AppTextStyles.textoCampo),
    );
  }
}

class _LinhaCampo extends StatelessWidget {
  const _LinhaCampo({
    required this.rotulo,
    required this.child,
    this.fim,
    this.erro,
  });

  final String rotulo;
  final Widget child;
  final Widget? fim;
  final String? erro;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.campo,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        spacing: AppSpacing.md,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xxs,
              children: [
                Text(rotulo.toUpperCase(), style: AppTextStyles.rotuloCampo),
                child,
                if (erro != null) Text(erro!, style: AppTextStyles.erroCampo),
              ],
            ),
          ),
          ?fim,
        ],
      ),
    );
  }
}

/// "Quantidade de peças" com os botões − e +.
class CampoQuantidade extends FormField<int> {
  CampoQuantidade({
    super.key,
    required int valorInicial,
    required ValueChanged<int> onChanged,
    super.validator,
    super.enabled,
    int maximo = 9999,
  }) : super(
         initialValue: valorInicial,
         builder: (field) {
           final valor = field.value ?? 1;
           void mudar(int novo) {
             field.didChange(novo);
             onChanged(novo);
           }

           final habilitado = field.widget.enabled;
           return _LinhaCampo(
             rotulo: 'Quantidade de peças *',
             erro: field.errorText,
             fim: Row(
               mainAxisSize: MainAxisSize.min,
               spacing: AppSpacing.lg,
               children: [
                 _BotaoQuantidade(
                   texto: '−',
                   descricao: 'Diminuir quantidade',
                   onPressed: habilitado && valor > 1
                       ? () => mudar(valor - 1)
                       : null,
                 ),
                 ConstrainedBox(
                   constraints: const BoxConstraints(
                     minWidth: AppSizes.avatarCompacto,
                   ),
                   child: Text(
                     '$valor',
                     style: AppTextStyles.quantidade,
                     textAlign: TextAlign.center,
                   ),
                 ),
                 _BotaoQuantidade(
                   texto: '+',
                   descricao: 'Aumentar quantidade',
                   onPressed: habilitado && valor < maximo
                       ? () => mudar(valor + 1)
                       : null,
                 ),
               ],
             ),
             child: const SizedBox.shrink(),
           );
         },
       );
}

class _BotaoQuantidade extends StatelessWidget {
  const _BotaoQuantidade({
    required this.texto,
    required this.descricao,
    required this.onPressed,
  });

  final String texto;
  final String descricao;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: descricao,
      excludeSemantics: true,
      child: Material(
        color: AppColors.primariaClara,
        borderRadius: BorderRadius.circular(AppRadius.icone),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.icone),
          child: SizedBox.square(
            dimension: AppSizes.botaoIcone,
            child: Center(
              child: Text(texto, style: AppTextStyles.botaoQuantidade),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão rosa "Valor total do pedido", recalculado a cada alteração.
class CartaoTotal extends StatelessWidget {
  const CartaoTotal({
    super.key,
    required this.valorUnitarioCentavos,
    required this.quantidade,
  });

  final int valorUnitarioCentavos;
  final int quantidade;

  @override
  Widget build(BuildContext context) {
    final unitario = Formatadores.moedaCentavos(valorUnitarioCentavos);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.campo,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaria,
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.botao,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xxs,
              children: [
                const Text(
                  'Valor total do pedido',
                  style: AppTextStyles.totalRotulo,
                ),
                Text(
                  Formatadores.moedaCentavos(
                    valorUnitarioCentavos * quantidade,
                  ),
                  style: AppTextStyles.totalValor,
                ),
                Text(
                  '$unitario × ${Formatadores.pecas(quantidade)}',
                  style: AppTextStyles.totalDetalhe,
                ),
              ],
            ),
          ),
          const IconeSvg(AppAssets.iconeAlvo, tamanho: AppSizes.iconeTotal),
        ],
      ),
    );
  }
}
