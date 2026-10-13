import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Grade 2×2 de atalhos da Home.
class AcessoRapido extends StatelessWidget {
  const AcessoRapido({super.key});

  @override
  Widget build(BuildContext context) {
    // goNamed nas abas troca de aba; o formulário abre por cima (push).
    final atalhos = [
      _Atalho(
        icone: AppIcons.adicionar,
        cor: AppColors.primaria,
        fundo: AppColors.primariaClara,
        titulo: 'Novo Pedido',
        subtitulo: 'Cadastrar peça',
        onTap: () => context.pushNamed(AppRoutes.pedidoNovo),
      ),
      _Atalho(
        icone: AppIcons.pessoas,
        cor: AppColors.textoValor,
        fundo: AppColors.bege,
        titulo: 'Clientes',
        subtitulo: 'Gerenciar lista',
        onTap: () => context.goNamed(AppRoutes.clientes),
      ),
      _Atalho(
        icone: AppIcons.documentoTexto,
        cor: AppColors.sucesso,
        fundo: AppColors.sucessoFundo,
        titulo: 'Histórico',
        subtitulo: 'Peças concluídas',
        onTap: () => context.goNamed(AppRoutes.historico),
      ),
      _Atalho(
        icone: AppIcons.grafico,
        cor: AppColors.alerta,
        fundo: AppColors.alertaSuave,
        titulo: 'Fechamento',
        subtitulo: 'Relatório mensal',
        onTap: () => context.goNamed(AppRoutes.fechamento),
      ),
    ];

    // Duas linhas em vez de uma grade com altura fixa: o conteúdo define a
    // altura e nada estoura com fonte maior.
    return Column(
      spacing: AppSpacing.md,
      children: [
        for (var i = 0; i < atalhos.length; i += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md,
              children: [
                Expanded(child: atalhos[i]),
                Expanded(child: atalhos[i + 1]),
              ],
            ),
          ),
      ],
    );
  }
}

class _Atalho extends StatelessWidget {
  const _Atalho({
    required this.icone,
    required this.cor,
    required this.fundo,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  final IconData icone;
  final Color cor;
  final Color fundo;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.cartao,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medio),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.cartao,
              vertical: AppSpacing.campo,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.sm,
              children: [
                Container(
                  width: AppSizes.caixaAtalho,
                  height: AppSizes.caixaAtalho,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: fundo,
                    borderRadius: BorderRadius.circular(AppRadius.pequeno),
                  ),
                  child: Icon(icone, size: AppSizes.iconeResumo, color: cor),
                ),
                Text(titulo, style: AppTextStyles.tituloItemCompacto),
                Text(subtitulo, style: AppTextStyles.legendaPequena),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
