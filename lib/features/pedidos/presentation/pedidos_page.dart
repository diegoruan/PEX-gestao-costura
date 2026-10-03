import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatadores.dart';
import '../../../shared/widgets/botao_icone.dart';
import '../../../shared/widgets/cabecalho_pagina.dart';
import '../../../shared/widgets/estado_mensagem.dart';
import '../../../shared/widgets/indicador_carregando.dart';
import '../../../shared/widgets/rotulo_secao.dart';
import '../bloc/pedidos_bloc.dart';
import '../domain/pedido.dart';
import 'widgets/aviso_pedido.dart';
import 'widgets/pedido_card.dart';

/// Lista de pedidos pendentes, agrupados pelo prazo de entrega.
class PedidosPage extends StatelessWidget {
  const PedidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    void novoPedido() => context.pushNamed(AppRoutes.pedidoNovo);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CabecalhoPagina(
              titulo: 'Pedidos',
              acoes: [
                BotaoIcone(
                  descricao: 'Novo pedido',
                  estilo: EstiloBotaoIcone.primario,
                  icone: const Icon(
                    Icons.add,
                    size: AppSizes.iconeBotao,
                    color: AppColors.textoSobrePrimaria,
                  ),
                  onPressed: novoPedido,
                ),
              ],
            ),
            Expanded(
              child: BlocBuilder<PedidosBloc, PedidosState>(
                builder: (context, state) => switch (state) {
                  PedidosCarregando() => const Center(
                    child: IndicadorCarregando(),
                  ),
                  PedidosErro(:final mensagem) => EstadoMensagem(
                    icone: Icons.cloud_off_outlined,
                    titulo: 'Não foi possível carregar',
                    mensagem: mensagem,
                    textoAcao: 'Tentar novamente',
                    onAcao: () => context.read<PedidosBloc>().add(
                      const PedidosIniciado(),
                    ),
                  ),
                  PedidosSucesso(:final pedidos) when pedidos.isEmpty =>
                    EstadoMensagem(
                      icone: Icons.checkroom_outlined,
                      titulo: 'Nenhum pedido em aberto',
                      mensagem: 'Cadastre as peças que você precisa entregar.',
                      textoAcao: 'Cadastrar pedido',
                      onAcao: novoPedido,
                    ),
                  PedidosSucesso(:final pedidos) => _ListaPedidos(
                    pedidos: pedidos,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaPedidos extends StatelessWidget {
  const _ListaPedidos({required this.pedidos});

  final List<Pedido> pedidos;

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final paraHoje = [
      for (final p in pedidos)
        if (p.prazo(agora) == PrazoPedido.hoje) p,
    ];

    // A lista já vem ordenada por entrega do repository; aqui só inserimos
    // o cabeçalho sempre que o grupo de prazo muda.
    final itens = <Widget>[];
    PrazoPedido? grupoAtual;
    for (final pedido in pedidos) {
      final prazo = pedido.prazo(agora);
      if (prazo != grupoAtual) {
        itens.add(
          Padding(
            padding: EdgeInsets.only(
              top: grupoAtual == null ? AppSpacing.xs : AppSpacing.lg,
              bottom: AppSpacing.sm,
            ),
            child: RotuloSecao(_tituloGrupo(prazo, agora)),
          ),
        );
        grupoAtual = prazo;
      }
      itens.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: PedidoCard(
            pedido: pedido,
            prazo: prazo,
            onTap: () => context.pushNamed(
              AppRoutes.pedidoDetalhe,
              pathParameters: {AppRoutes.paramId: pedido.id},
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.lg,
          ),
          child: Text.rich(
            TextSpan(
              text: pedidos.length == 1
                  ? '1 pedido'
                  : '${pedidos.length} pedidos',
              style: AppTextStyles.legendaDestaque,
              children: const [
                TextSpan(text: ' em aberto', style: AppTextStyles.legenda),
              ],
            ),
          ),
        ),
        if (paraHoje.isNotEmpty) ...[
          AvisoPedido(
            titulo: 'Entregas para hoje',
            mensagem: _resumoHoje(paraHoje),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        ...itens,
      ],
    );
  }

  String _tituloGrupo(PrazoPedido prazo, DateTime agora) => switch (prazo) {
    PrazoPedido.atrasado => 'Atrasados',
    PrazoPedido.hoje => 'Hoje — ${Formatadores.diaMesExtenso(agora)}',
    PrazoPedido.estaSemana => 'Esta semana',
    PrazoPedido.depois => 'Mais adiante',
  };

  /// "Vestido Floral (Ana) e Calça Social (Pedro)"
  String _resumoHoje(List<Pedido> pedidos) {
    final partes = [
      for (final p in pedidos) '${p.nome} (${p.clienteNome.split(' ').first})',
    ];
    if (partes.length == 1) return partes.first;
    final ultima = partes.removeLast();
    return '${partes.join(', ')} e $ultima';
  }
}
