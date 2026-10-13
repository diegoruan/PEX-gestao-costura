import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatadores.dart';
import '../../../shared/widgets/cabecalho_pagina.dart';
import '../../../shared/widgets/campo_busca.dart';
import '../../../shared/widgets/cartao_numeros.dart';
import '../../../shared/widgets/estado_mensagem.dart';
import '../../../shared/widgets/indicador_carregando.dart';
import '../../pedidos/domain/pedido.dart';
import '../bloc/historico_bloc.dart';
import 'widgets/cabecalho_mes.dart';
import 'widgets/filtros_historico.dart';
import 'widgets/historico_item.dart';

/// Peças já finalizadas, agrupadas pelo mês de finalização. Somente leitura.
class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CabecalhoPagina(titulo: 'Histórico'),
            Expanded(
              child: BlocBuilder<HistoricoBloc, HistoricoState>(
                builder: (context, state) => switch (state) {
                  HistoricoCarregando() => const Center(
                    child: IndicadorCarregando(),
                  ),
                  HistoricoErro(:final mensagem) => EstadoMensagem(
                    icone: AppIcons.semConexao,
                    titulo: 'Não foi possível carregar',
                    mensagem: mensagem,
                    textoAcao: 'Tentar novamente',
                    onAcao: () => context.read<HistoricoBloc>().add(
                      const HistoricoIniciado(),
                    ),
                  ),
                  HistoricoSucesso(:final pedidos) when pedidos.isEmpty =>
                    const EstadoMensagem(
                      icone: AppIcons.historico,
                      titulo: 'Nenhuma peça entregue ainda',
                      mensagem:
                          'Os pedidos marcados como entregues aparecem aqui.',
                    ),
                  HistoricoSucesso() => _Conteudo(estado: state),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.estado});

  final HistoricoSucesso estado;

  @override
  Widget build(BuildContext context) {
    final filtrados = estado.filtrados;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: CampoBusca(
            hint: 'Buscar por peça ou cliente...',
            onChanged: (busca) => context.read<HistoricoBloc>().add(
              HistoricoFiltroAlterado(estado.filtro.copyWith(busca: busca)),
            ),
          ),
        ),
        FiltrosHistorico(estado: estado),
        Expanded(
          child: filtrados.isEmpty
              ? const EstadoMensagem(
                  icone: AppIcons.semResultado,
                  titulo: 'Nenhuma peça encontrada',
                  mensagem: 'Confira a busca ou os filtros escolhidos.',
                )
              : _Lista(pedidos: filtrados),
        ),
      ],
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.pedidos});

  final List<Pedido> pedidos;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        _Resumo(resumo: ResumoHistorico.de(pedidos)),
        for (final mes in MesHistorico.agrupar(pedidos)) ...[
          CabecalhoMes(mes: mes),
          for (final pedido in mes.pedidos)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: HistoricoItem(pedido: pedido),
            ),
        ],
      ],
    );
  }
}

/// Peças, total faturado e clientes do que está filtrado.
class _Resumo extends StatelessWidget {
  const _Resumo({required this.resumo});

  final ResumoHistorico resumo;

  @override
  Widget build(BuildContext context) {
    return CartaoNumeros(
      itens: [
        (valor: '${resumo.pecas}', rotulo: 'Peças entregues'),
        (
          valor: Formatadores.moedaCompacta(resumo.totalCentavos),
          rotulo: 'Total faturado',
        ),
        (valor: '${resumo.clientes}', rotulo: 'Clientes ativos'),
      ],
    );
  }
}
