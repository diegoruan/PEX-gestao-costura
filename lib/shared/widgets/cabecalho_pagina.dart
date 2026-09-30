import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import 'botao_icone.dart';
import 'icone_svg.dart';

/// Barra do topo das telas internas: voltar à esquerda, título ao centro e
/// ações à direita. Substitui o AppBar para seguir o Figma.
class CabecalhoPagina extends StatelessWidget {
  const CabecalhoPagina({
    super.key,
    this.titulo,
    this.acoes = const [],
    this.estiloBotoes = EstiloBotaoIcone.claro,
  });

  final String? titulo;
  final List<Widget> acoes;
  final EstiloBotaoIcone estiloBotoes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SizedBox(
        height: AppSizes.botaoIcone,
        child: NavigationToolbar(
          leading: BotaoIcone(
            descricao: 'Voltar',
            estilo: estiloBotoes,
            icone: const IconeSvg(
              AppAssets.iconeVoltar,
              tamanho: AppSizes.iconeBotao,
              cor: AppColors.textoPrincipal,
            ),
            onPressed: () => context.pop(),
          ),
          middle: titulo == null
              ? null
              : Text(titulo!, style: AppTextStyles.tituloPagina),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.sm,
            children: acoes,
          ),
        ),
      ),
    );
  }
}
