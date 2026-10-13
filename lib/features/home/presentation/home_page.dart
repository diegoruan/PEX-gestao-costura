import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/estado_mensagem.dart';
import '../../../shared/widgets/indicador_carregando.dart';
import '../../pedidos/domain/pedido.dart';
import '../bloc/home_bloc.dart';
import 'widgets/acesso_rapido.dart';
import 'widgets/aviso_entregas.dart';
import 'widgets/cabecalho_home.dart';
import 'widgets/estatisticas_home.dart';
import 'widgets/pedido_recente_card.dart';

/// Tela inicial: resumo do dia e do mês, atalhos e pedidos recentes.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final resumo = state is HomeSucesso ? state.resumo : null;

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              const CabecalhoHome(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.lg,
                  children: [
                    EstatisticasHome(resumo: resumo),
                    if (resumo != null && resumo.temAviso)
                      AvisoEntregas(resumo: resumo),
                    const _Secao(
                      titulo: 'Acesso Rápido',
                      child: AcessoRapido(),
                    ),
                    _Secao(
                      titulo: 'Pedidos Recentes',
                      acao: TextButton(
                        onPressed: () => context.goNamed(AppRoutes.pedidos),
                        style: TextButton.styleFrom(
                          textStyle: AppTextStyles.linkPequeno,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Ver todos →'),
                      ),
                      child: _Recentes(state: state),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, required this.child, this.acao});

  final String titulo;
  final Widget child;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(titulo, style: AppTextStyles.tituloItemCompacto),
            ),
            ?acao,
          ],
        ),
        child,
      ],
    );
  }
}

class _Recentes extends StatelessWidget {
  const _Recentes({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      HomeCarregando() => const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: IndicadorCarregando()),
      ),
      HomeErro(:final mensagem) => EstadoMensagem(
        icone: Icons.cloud_off_outlined,
        titulo: 'Não foi possível carregar',
        mensagem: mensagem,
        textoAcao: 'Tentar novamente',
        onAcao: () => context.read<HomeBloc>().add(const HomeIniciado()),
      ),
      HomeSucesso(:final resumo) when resumo.recentes.isEmpty =>
        const EstadoMensagem(
          icone: Icons.checkroom_outlined,
          titulo: 'Nenhum pedido ainda',
          mensagem: 'Use o "Novo Pedido" para cadastrar a primeira peça.',
        ),
      HomeSucesso(:final resumo) => Column(
        spacing: AppSpacing.smd,
        children: [
          for (final pedido in resumo.recentes)
            PedidoRecenteCard(
              pedido: pedido,
              agora: DateTime.now(),
              onTap: () => _abrir(context, pedido),
            ),
        ],
      ),
    };
  }

  // Pendente abre o detalhe; finalizado não tem detalhe, então vai para o
  // histórico.
  void _abrir(BuildContext context, Pedido pedido) => pedido.finalizado
      ? context.goNamed(AppRoutes.historico)
      : context.pushNamed(
          AppRoutes.pedidoDetalhe,
          pathParameters: {AppRoutes.paramId: pedido.id},
        );
}
