import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatadores.dart';
import '../../bloc/historico_bloc.dart';

/// Chips "Todos", "Clientes" e "Por data". Com um filtro ativo, o chip mostra
/// o que foi escolhido (nome do cliente ou o período).
class FiltrosHistorico extends StatelessWidget {
  const FiltrosHistorico({super.key, required this.estado});

  final HistoricoSucesso estado;

  HistoricoFiltro get _filtro => estado.filtro;

  void _alterar(BuildContext context, HistoricoFiltro filtro) =>
      context.read<HistoricoBloc>().add(HistoricoFiltroAlterado(filtro));

  @override
  Widget build(BuildContext context) {
    final clienteId = _filtro.clienteId;
    final periodo = _filtro.periodo;
    final nomeCliente = clienteId == null
        ? null
        : estado.clientes.where((c) => c.id == clienteId).firstOrNull?.nome;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Row(
        spacing: AppSpacing.xsm,
        children: [
          _Chip(
            texto: 'Todos',
            selecionado: _filtro.todos,
            onTap: () => _alterar(
              context,
              _filtro.copyWith(clienteId: () => null, periodo: () => null),
            ),
          ),
          _Chip(
            texto: nomeCliente ?? 'Clientes',
            selecionado: clienteId != null,
            onTap: () => _escolherCliente(context),
          ),
          _Chip(
            texto: periodo == null
                ? 'Por data'
                : '${Formatadores.diaMes(periodo.inicio)} – '
                      '${Formatadores.diaMes(periodo.fim)}',
            icone: AppIcons.calendario,
            selecionado: periodo != null,
            onTap: () => _escolherPeriodo(context),
          ),
        ],
      ),
    );
  }

  Future<void> _escolherCliente(BuildContext context) async {
    // O registro distingue "fechou sem escolher" (null) de "Todos os
    // clientes" (id null).
    final escolha = await showModalBottomSheet<({String? id})>(
      context: context,
      backgroundColor: AppColors.superficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.folha),
        ),
      ),
      builder: (context) {
        Widget opcao(String? id, String nome) {
          final selecionado = id == _filtro.clienteId;
          return ListTile(
            title: Text(
              nome,
              style: AppTextStyles.corpo.copyWith(
                color: selecionado
                    ? AppColors.primaria
                    : AppColors.textoPrincipal,
              ),
            ),
            trailing: selecionado
                ? const Icon(AppIcons.check, color: AppColors.primaria)
                : null,
            onTap: () => Navigator.of(context).pop((id: id)),
          );
        }

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              opcao(null, 'Todos os clientes'),
              for (final cliente in estado.clientes)
                opcao(cliente.id, cliente.nome),
            ],
          ),
        );
      },
    );
    if (escolha == null || !context.mounted) return;
    _alterar(context, _filtro.copyWith(clienteId: () => escolha.id));
  }

  Future<void> _escolherPeriodo(BuildContext context) async {
    final hoje = DateTime.now();
    // A lista vem do mais recente para o mais antigo.
    final maisAntigo = estado.pedidos.lastOrNull?.finalizadoEm ?? hoje;
    final maisRecente = estado.pedidos.firstOrNull?.finalizadoEm ?? hoje;
    final ultimoDia = maisRecente.isAfter(hoje) ? maisRecente : hoje;
    final periodo = _filtro.periodo;

    final escolhido = await showDateRangePicker(
      context: context,
      firstDate: DateTime(maisAntigo.year, maisAntigo.month, maisAntigo.day),
      lastDate: DateTime(ultimoDia.year, ultimoDia.month, ultimoDia.day),
      initialDateRange: periodo == null
          ? null
          : DateTimeRange(start: periodo.inicio, end: periodo.fim),
      helpText: 'Peças entregues entre',
    );
    if (escolhido == null || !context.mounted) return;
    _alterar(
      context,
      _filtro.copyWith(
        periodo: () => (inicio: escolhido.start, fim: escolhido.end),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.texto,
    required this.selecionado,
    required this.onTap,
    this.icone,
  });

  final String texto;
  final bool selecionado;
  final VoidCallback onTap;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final cor = selecionado
        ? AppColors.textoSobrePrimaria
        : AppColors.textoSecundario;

    return Container(
      decoration: BoxDecoration(
        color: selecionado ? AppColors.primaria : AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.pilula),
        boxShadow: selecionado ? null : AppShadows.botaoIcone,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pilula),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.cartao,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.xsm,
              children: [
                if (icone != null)
                  Icon(icone!, size: AppSizes.iconeMinimo, color: cor),
                Text(texto, style: AppTextStyles.chip.copyWith(color: cor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
