import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import 'icone_svg.dart';

class ItemNavegacao {
  const ItemNavegacao({required this.icone, required this.rotulo});

  /// Constante de `AppAssets`.
  final String icone;
  final String rotulo;
}

/// Barra inferior do Figma: ícone e rótulo, com o item ativo em rosa e um
/// pontinho embaixo. Própria porque o NavigationBar do Material 3 usa uma
/// pílula atrás do ícone, que o design não tem.
class BarraNavegacao extends StatelessWidget {
  const BarraNavegacao({
    super.key,
    required this.itens,
    required this.indiceAtual,
    required this.onSelecionar,
  });

  final List<ItemNavegacao> itens;
  final int indiceAtual;
  final ValueChanged<int> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.superficie,
        border: Border(top: BorderSide(color: AppColors.borda)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.smd,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            children: [
              for (final (i, item) in itens.indexed)
                Expanded(
                  child: _Item(
                    item: item,
                    ativo: i == indiceAtual,
                    onTap: () => onSelecionar(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.ativo, required this.onTap});

  final ItemNavegacao item;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: ativo,
      child: InkResponse(
        onTap: onTap,
        radius: AppSizes.botaoAcao,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xxs,
          children: [
            IconeSvg(
              item.icone,
              tamanho: AppSizes.iconeNavegacao,
              cor: ativo ? AppColors.primaria : AppColors.textoSecundario,
            ),
            Text(
              item.rotulo,
              style: ativo
                  ? AppTextStyles.rotuloNavegacaoAtivo
                  : AppTextStyles.rotuloNavegacao,
            ),
            // Espaço reservado mesmo sem o ponto, para os rótulos não pularem
            // ao trocar de aba.
            Container(
              width: AppSizes.pontoNavegacao,
              height: AppSizes.pontoNavegacao,
              decoration: BoxDecoration(
                color: ativo ? AppColors.primaria : AppColors.transparente,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
