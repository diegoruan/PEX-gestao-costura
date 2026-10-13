import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatadores.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/botao_icone.dart';
import '../../../shared/widgets/botao_suave.dart';
import '../../../shared/widgets/estado_mensagem.dart';
import '../../../shared/widgets/foto_pedido.dart';
import '../../../shared/widgets/indicador_carregando.dart';
import '../../../shared/widgets/snackbar_mensagem.dart';
import '../bloc/pedidos_bloc.dart';
import '../domain/pedido.dart';
import 'widgets/acoes_pedido.dart';

class PedidoDetalhePage extends StatelessWidget {
  const PedidoDetalhePage({super.key, required this.pedidoId});

  final String pedidoId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PedidosBloc, PedidosState>(
      // O formulário de edição fica empilhado por cima e escuta o mesmo bloc;
      // só a tela visível reage, e só quando a ação muda.
      listenWhen: (anterior, atual) =>
          atual is PedidosSucesso &&
          (anterior is! PedidosSucesso || anterior.acao != atual.acao) &&
          (ModalRoute.of(context)?.isCurrent ?? false),
      listener: (context, state) {
        if (state is! PedidosSucesso) return;
        switch (state.acao) {
          case AcaoPedido.finalizado:
            mostrarSnackbarSucesso(context, 'Pedido marcado como entregue.');
            context.goNamed(AppRoutes.pedidos);
          case AcaoPedido.excluido:
            mostrarSnackbarSucesso(context, 'Pedido excluído.');
            context.goNamed(AppRoutes.pedidos);
          case AcaoPedido.falhou:
            mostrarSnackbarErro(context, state.mensagemErro!);
          default:
            break;
        }
      },
      builder: (context, state) {
        final Widget conteudo = switch (state) {
          PedidosCarregando() => const Center(child: IndicadorCarregando()),
          PedidosErro(:final mensagem) => EstadoMensagem(
            icone: AppIcons.semConexao,
            titulo: 'Não foi possível carregar',
            mensagem: mensagem,
          ),
          PedidosSucesso() => switch (state.buscarPorId(pedidoId)) {
            // Offline, o pedido some da lista (o cache já foi atualizado)
            // antes de a ação ser dada como concluída; evita piscar a
            // mensagem de "não encontrado" no meio do caminho.
            null
                when state.acao == AcaoPedido.finalizando ||
                    state.acao == AcaoPedido.finalizado ||
                    state.acao == AcaoPedido.excluindo ||
                    state.acao == AcaoPedido.excluido =>
              const Center(child: IndicadorCarregando()),
            null => EstadoMensagem(
              icone: AppIcons.semResultado,
              titulo: 'Pedido não encontrado',
              mensagem: 'Ele pode ter sido entregue ou excluído.',
              textoAcao: 'Voltar para a lista',
              onAcao: () => context.goNamed(AppRoutes.pedidos),
            ),
            final pedido => _Detalhe(pedido: pedido, acao: state.acao),
          },
        };
        return Scaffold(body: conteudo);
      },
    );
  }
}

class _Detalhe extends StatelessWidget {
  const _Detalhe({required this.pedido, required this.acao});

  final Pedido pedido;
  final AcaoPedido acao;

  @override
  Widget build(BuildContext context) {
    final ocupado = acao.emAndamento;
    final observacoes = pedido.observacoes;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Topo(pedido: pedido, habilitado: !ocupado),
        // Sobe por cima da foto, como a "folha" arredondada do Figma.
        Transform.translate(
          offset: const Offset(0, -AppSizes.sobreposicaoFoto),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            decoration: const BoxDecoration(
              color: AppColors.fundo,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.folha),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.lg,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xsm,
                  children: [
                    Text(pedido.nome, style: AppTextStyles.tituloDestaque),
                    Text(
                      'Cadastrado em ${Formatadores.data(pedido.criadoEm)}',
                      style: AppTextStyles.subtitulo,
                    ),
                  ],
                ),
                _Resumo(pedido: pedido),
                _CartaoCliente(nome: pedido.clienteNome),
                if (observacoes != null) _CartaoObservacoes(texto: observacoes),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Row(
                    spacing: AppSpacing.md,
                    children: [
                      Expanded(
                        child: _BotaoAcao(
                          texto: 'Editar',
                          icone: AppIcons.editar,
                          principal: false,
                          onPressed: ocupado ? null : () => _editar(context),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _BotaoAcao(
                          texto: 'Marcar como Entregue',
                          icone: AppIcons.check,
                          principal: true,
                          carregando: acao == AcaoPedido.finalizando,
                          onPressed: ocupado
                              ? null
                              : () =>
                                    confirmarFinalizacaoPedido(context, pedido),
                        ),
                      ),
                    ],
                  ),
                ),
                BotaoSuave(
                  texto: 'Excluir pedido',
                  icone: const Icon(
                    AppIcons.lixeira,
                    size: AppSizes.iconeAcao,
                    color: AppColors.primaria,
                  ),
                  carregando: acao == AcaoPedido.excluindo,
                  onPressed: ocupado
                      ? null
                      : () => confirmarExclusaoPedido(context, pedido),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _editar(BuildContext context) => context.pushNamed(
    AppRoutes.pedidoEditar,
    pathParameters: {AppRoutes.paramId: pedido.id},
  );
}

class _Topo extends StatelessWidget {
  const _Topo({required this.pedido, required this.habilitado});

  final Pedido pedido;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    const corIcone = AppColors.textoSobrePrimaria;
    // Foto escura no topo: ícones da barra de status claros.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SizedBox(
        height: AppSizes.fotoDetalhe,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FotoPedido(pedido: pedido, tamanhoIcone: AppSizes.iconeFotoDetalhe),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.fotoSombraTopo,
                    AppColors.transparente,
                    AppColors.fotoSombraBase,
                  ],
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    spacing: AppSpacing.sm,
                    children: [
                      _BotaoSobreFoto(
                        descricao: 'Voltar',
                        icone: const Icon(
                          AppIcons.voltar,
                          size: AppSizes.iconeBotao,
                          color: corIcone,
                        ),
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.goNamed(AppRoutes.pedidos),
                      ),
                      const Spacer(),
                      _BotaoSobreFoto(
                        descricao: 'Editar pedido',
                        icone: const Icon(
                          AppIcons.editar,
                          size: AppSizes.iconePequeno,
                          color: corIcone,
                        ),
                        onPressed: !habilitado
                            ? null
                            : () => context.pushNamed(
                                AppRoutes.pedidoEditar,
                                pathParameters: {AppRoutes.paramId: pedido.id},
                              ),
                      ),
                      _MenuMaisAcoes(pedido: pedido, habilitado: habilitado),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [BotaoIcone] com o fundo de vidro usado por cima da foto.
class _BotaoSobreFoto extends StatelessWidget {
  const _BotaoSobreFoto({
    required this.descricao,
    required this.icone,
    required this.onPressed,
  });

  final String descricao;
  final Widget icone;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: descricao,
      child: Material(
        color: AppColors.sobreFoto,
        borderRadius: BorderRadius.circular(AppRadius.pequeno),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.pequeno),
          child: SizedBox.square(
            dimension: AppSizes.botaoIcone,
            child: Center(child: icone),
          ),
        ),
      ),
    );
  }
}

class _MenuMaisAcoes extends StatelessWidget {
  const _MenuMaisAcoes({required this.pedido, required this.habilitado});

  final Pedido pedido;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(
            AppIcons.lixeira,
            size: AppSizes.iconePequeno,
            color: AppColors.primaria,
          ),
          style: MenuItemButton.styleFrom(
            foregroundColor: AppColors.primaria,
            textStyle: AppTextStyles.link,
          ),
          onPressed: () => confirmarExclusaoPedido(context, pedido),
          child: const Text('Excluir pedido'),
        ),
      ],
      builder: (context, controller, _) => _BotaoSobreFoto(
        descricao: 'Mais ações',
        icone: const Icon(
          AppIcons.mais,
          size: AppSizes.iconePequeno,
          color: AppColors.textoSobrePrimaria,
        ),
        onPressed: !habilitado
            ? null
            : () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

/// Os quatro cartõezinhos: total, quantidade, valor unitário e entrega.
class _Resumo extends StatelessWidget {
  const _Resumo({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSpacing.md,
      children: [
        Row(
          spacing: AppSpacing.md,
          children: [
            Expanded(
              child: _ItemResumo(
                icone: AppIcons.dolar,
                rotulo: 'Valor total',
                valor: Formatadores.moedaCentavos(pedido.totalCentavos),
                cor: AppColors.primaria,
              ),
            ),
            Expanded(
              child: _ItemResumo(
                icone: AppIcons.quantidade,
                rotulo: 'Quantidade',
                valor: Formatadores.pecas(pedido.quantidade),
              ),
            ),
          ],
        ),
        Row(
          spacing: AppSpacing.md,
          children: [
            Expanded(
              child: _ItemResumo(
                icone: AppIcons.etiqueta,
                rotulo: 'Valor unitário',
                valor: Formatadores.moedaCentavos(pedido.valorUnitarioCentavos),
              ),
            ),
            Expanded(
              child: _ItemResumo(
                icone: AppIcons.calendario,
                rotulo: 'Entrega',
                valor: Formatadores.diaMesAno(pedido.dataEntrega),
                cor: AppColors.alerta,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ItemResumo extends StatelessWidget {
  const _ItemResumo({
    required this.icone,
    required this.rotulo,
    required this.valor,
    this.cor,
  });

  final IconData icone;
  final String rotulo;
  final String valor;

  /// Recolore ícone e valor (o total em rosa, a entrega em amarelo).
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cartao),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.item),
        boxShadow: AppShadows.itemLista,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Icon(
              icone,
              size: AppSizes.iconeResumo,
              color: cor ?? AppColors.textoSecundario,
            ),
          ),
          Text(rotulo.toUpperCase(), style: AppTextStyles.rotuloCampo),
          Text(
            valor,
            style: cor == null
                ? AppTextStyles.valorResumo
                : AppTextStyles.valorResumo.copyWith(color: cor),
          ),
        ],
      ),
    );
  }
}

class _CartaoCliente extends StatelessWidget {
  const _CartaoCliente({required this.nome});

  final String nome;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cartao),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.itemLista,
      ),
      child: Row(
        spacing: AppSpacing.cartao,
        children: [
          AvatarIniciais(nome: nome),
          Expanded(child: Text(nome, style: AppTextStyles.tituloItem)),
        ],
      ),
    );
  }
}

class _CartaoObservacoes extends StatelessWidget {
  const _CartaoObservacoes({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.itemLista,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.smd,
        children: [
          Text('OBSERVAÇÕES', style: AppTextStyles.rotuloSecao),
          Text(texto, style: AppTextStyles.textoLongo),
        ],
      ),
    );
  }
}

/// Botões "Editar" (branco) e "Marcar como Entregue" (rosa) do rodapé.
class _BotaoAcao extends StatelessWidget {
  const _BotaoAcao({
    required this.texto,
    required this.icone,
    required this.principal,
    required this.onPressed,
    this.carregando = false,
  });

  final String texto;
  final IconData icone;
  final bool principal;
  final VoidCallback? onPressed;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    final cor = principal ? AppColors.primaria : AppColors.superficie;
    final corTexto = principal
        ? AppColors.textoSobrePrimaria
        : AppColors.textoPrincipal;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.item),
        boxShadow: principal ? AppShadows.botao : AppShadows.botaoIcone,
      ),
      child: SizedBox(
        height: AppSizes.botaoAcao,
        child: TextButton(
          onPressed: carregando ? null : onPressed,
          style: TextButton.styleFrom(
            backgroundColor: cor,
            disabledBackgroundColor: cor,
            foregroundColor: corTexto,
            disabledForegroundColor: corTexto,
            textStyle: AppTextStyles.botaoSecundario,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.item),
            ),
          ),
          child: carregando
              ? IndicadorCarregando(
                  tamanho: AppSizes.indicadorBotao,
                  cor: corTexto,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.sm,
                  children: [
                    Icon(icone, size: AppSizes.iconeAcao, color: corTexto),
                    Flexible(
                      child: Text(
                        texto,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
