import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import 'botao_icone.dart';

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
    // Fundo claro no topo: ícones da barra de status escuros.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Padding(
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
              icone: const Icon(
                AppIcons.voltar,
                size: AppSizes.iconeBotao,
                color: AppColors.textoPrincipal,
              ),
              onPressed: () => context.canPop()
                  ? context.pop()
                  : context.goNamed(AppRoutes.home),
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
      ),
    );
  }
}
