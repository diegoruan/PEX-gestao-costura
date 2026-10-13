import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatadores.dart';
import '../../../shared/widgets/botao_icone.dart';
import '../../../shared/widgets/cabecalho_pagina.dart';
import '../../../shared/widgets/estado_mensagem.dart';
import '../../../shared/widgets/indicador_carregando.dart';
import '../bloc/fechamento_bloc.dart';
import '../domain/calculador_fechamento.dart';
import '../domain/fechamento_mensal.dart';
import 'widgets/fechamento_cliente_card.dart';
import 'widgets/resumo_fechamento.dart';
import 'widgets/seletor_mes.dart';
import 'widgets/total_geral_card.dart';

/// Quanto cada cliente deve no mês escolhido. Somente leitura.
class FechamentoPage extends StatelessWidget {
  const FechamentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CabecalhoPagina(
              titulo: 'Fechamento Mensal',
              estiloBotoes: EstiloBotaoIcone.translucido,
            ),
            Expanded(
              child: BlocBuilder<FechamentoBloc, FechamentoState>(
                builder: (context, state) => _Conteudo(state: state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.state});

  final FechamentoState state;

  void _irPara(BuildContext context, DateTime mes) =>
      context.read<FechamentoBloc>().add(FechamentoMesAlterado(mes));

  @override
  Widget build(BuildContext context) {
    final mes = state.mesSelecionado;
    // Meses futuros não têm peças finalizadas: a seta para a frente para no
    // mês atual, que também é o único ainda "em aberto".
    final mesEncerrado = mes.isBefore(inicioDoMes(DateTime.now()));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        SeletorMes(
          mes: mes,
          onAnterior: () => _irPara(context, mesAnterior(mes)),
          onProximo: mesEncerrado
              ? () => _irPara(context, mesSeguinte(mes))
              : null,
        ),
        const SizedBox(height: AppSpacing.xxl),
        ...switch (state) {
          FechamentoCarregando() => const [
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.xxxl),
              child: Center(child: IndicadorCarregando()),
            ),
          ],
          FechamentoErro(:final mensagem) => [
            EstadoMensagem(
              icone: AppIcons.semConexao,
              titulo: 'Não foi possível carregar',
              mensagem: mensagem,
              textoAcao: 'Tentar novamente',
              onAcao: () => _irPara(context, mes),
            ),
          ],
          FechamentoSucesso(:final fechamento)
              when fechamento.clientes.isEmpty =>
            [
              EstadoMensagem(
                icone: AppIcons.mesSemPecas,
                titulo: 'Nenhuma peça finalizada',
                mensagem:
                    'Não há pedidos entregues em '
                    '${Formatadores.mesAnoExtenso(mes)}.',
              ),
            ],
          FechamentoSucesso(:final fechamento) => _fechamento(
            fechamento,
            mesEncerrado,
          ),
        },
      ],
    );
  }

  List<Widget> _fechamento(FechamentoMensal fechamento, bool mesEncerrado) {
    return [
      ResumoFechamento(fechamento: fechamento),
      const SizedBox(height: AppSpacing.xxl),
      const Text('Valor por Cliente', style: AppTextStyles.tituloItemCompacto),
      for (final cliente in fechamento.clientes)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: FechamentoClienteCard(
            cliente: cliente,
            percentual: fechamento.percentualDe(cliente),
          ),
        ),
      const SizedBox(height: AppSpacing.xxl * 2),
      TotalGeralCard(fechamento: fechamento, mesEncerrado: mesEncerrado),
    ];
  }
}
