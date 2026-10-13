import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/dialogo_confirmacao.dart';
import '../../../../shared/widgets/icone_svg.dart';
import '../../../auth/bloc/auth_bloc.dart';

/// Faixa rosa do topo: marca, saudação e o botão de sair.
class CabecalhoHome extends StatelessWidget {
  const CabecalhoHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final nome = auth is AuthAutenticado ? auth.usuario.nomeExibicao : '';

    // Fundo rosa até a barra de status: ícones claros.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: AppColors.primaria,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: AppSpacing.smd,
                  children: [
                    const _CaixaTranslucida(
                      child: IconeSvg(
                        AppAssets.iconeCarretel,
                        tamanho: AppSizes.iconeResumo,
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ateliê', style: AppTextStyles.marcaCabecalho),
                          Text(
                            'Gestão de Costuras',
                            style: AppTextStyles.subtituloCabecalho,
                          ),
                        ],
                      ),
                    ),
                    // O Figma não mostra onde sair; fica aqui, discreto.
                    Tooltip(
                      message: 'Sair',
                      child: _CaixaTranslucida(
                        onTap: () => _sair(context),
                        child: const Icon(
                          Icons.logout,
                          size: AppSizes.iconeBotao,
                          color: AppColors.textoSobrePrimaria,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg + AppSpacing.xs),
                const Text(
                  'Bem-vindo de volta,',
                  style: AppTextStyles.saudacao,
                ),
                Text(
                  nome,
                  style: AppTextStyles.nomeUsuario,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sair(BuildContext context) async {
    final confirmou = await confirmarAcao(
      context,
      titulo: 'Sair da conta?',
      mensagem: 'Você vai precisar entrar de novo para ver seus pedidos.',
      textoConfirmar: 'Sair',
      destrutiva: false,
    );
    if (confirmou && context.mounted) {
      context.read<AuthBloc>().add(const AuthLogoutSolicitado());
    }
  }
}

class _CaixaTranslucida extends StatelessWidget {
  const _CaixaTranslucida({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.superficieSobrePrimaria,
      borderRadius: BorderRadius.circular(AppRadius.icone),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.icone),
        child: SizedBox.square(
          dimension: AppSizes.botaoIcone,
          child: Center(child: child),
        ),
      ),
    );
  }
}
