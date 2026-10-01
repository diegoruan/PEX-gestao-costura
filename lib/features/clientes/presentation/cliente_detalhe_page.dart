import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatadores.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/botao_icone.dart';
import '../../../shared/widgets/cabecalho_pagina.dart';
import '../../../shared/widgets/cartao_informacoes.dart';
import '../../../shared/widgets/estado_mensagem.dart';
import '../../../shared/widgets/icone_svg.dart';
import '../../../shared/widgets/indicador_carregando.dart';
import '../../../shared/widgets/snackbar_mensagem.dart';
import '../bloc/clientes_bloc.dart';
import '../domain/cliente.dart';
import 'widgets/confirmar_exclusao_cliente.dart';

class ClienteDetalhePage extends StatelessWidget {
  const ClienteDetalhePage({super.key, required this.clienteId});

  final String clienteId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientesBloc, ClientesState>(
      // O formulário de edição fica empilhado por cima e escuta o mesmo bloc;
      // só a tela visível reage, e só quando a ação muda.
      listenWhen: (anterior, atual) =>
          atual is ClientesSucesso &&
          (anterior is! ClientesSucesso || anterior.acao != atual.acao) &&
          (ModalRoute.of(context)?.isCurrent ?? false),
      listener: (context, state) {
        if (state is! ClientesSucesso) return;
        switch (state.acao) {
          case AcaoCliente.inativado:
            mostrarSnackbarSucesso(context, 'Cliente excluído.');
            context.goNamed(AppRoutes.clientes);
          case AcaoCliente.falhou:
            mostrarSnackbarErro(context, state.mensagemErro!);
          default:
            break;
        }
      },
      builder: (context, state) {
        final Widget conteudo = switch (state) {
          ClientesCarregando() => const Center(child: IndicadorCarregando()),
          ClientesErro(:final mensagem) => EstadoMensagem(
            icone: Icons.cloud_off_outlined,
            titulo: 'Não foi possível carregar',
            mensagem: mensagem,
          ),
          ClientesSucesso() => switch (state.buscarPorId(clienteId)) {
            null => EstadoMensagem(
              icone: Icons.person_off_outlined,
              titulo: 'Cliente não encontrado',
              mensagem: 'Ele pode ter sido excluído.',
              textoAcao: 'Voltar para a lista',
              onAcao: () => context.goNamed(AppRoutes.clientes),
            ),
            final cliente => _Detalhe(
              cliente: cliente,
              excluindo: state.acao == AcaoCliente.inativando,
            ),
          },
        };
        return Scaffold(body: SafeArea(child: conteudo));
      },
    );
  }
}

class _Detalhe extends StatelessWidget {
  const _Detalhe({required this.cliente, required this.excluindo});

  final Cliente cliente;
  final bool excluindo;

  @override
  Widget build(BuildContext context) {
    final observacoes = cliente.observacoes;
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        CabecalhoPagina(
          estiloBotoes: EstiloBotaoIcone.translucido,
          acoes: [
            BotaoIcone(
              descricao: 'Editar cliente',
              estilo: EstiloBotaoIcone.translucido,
              icone: const IconeSvg(
                AppAssets.iconeEditar,
                tamanho: AppSizes.iconePequeno,
              ),
              onPressed: () => context.pushNamed(
                AppRoutes.clienteEditar,
                pathParameters: {AppRoutes.paramId: cliente.id},
              ),
            ),
            _MenuMaisAcoes(cliente: cliente, habilitado: !excluindo),
          ],
        ),
        Column(
          spacing: AppSpacing.smd,
          children: [
            AvatarIniciais(nome: cliente.nome, destaque: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                cliente.nomeComApelido,
                style: AppTextStyles.tituloDestaque,
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              'Cliente desde ${Formatadores.mesAnoExtenso(cliente.criadoEm)}',
              style: AppTextStyles.legenda,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            spacing: AppSpacing.smd,
            children: [
              CartaoInformacoes(
                titulo: 'Dados de contato',
                linhas: [
                  LinhaInformacao(
                    icone: const IconeSvg(
                      AppAssets.iconeTelefone,
                      tamanho: AppSizes.iconeContato,
                    ),
                    rotulo: 'Telefone',
                    valor: cliente.telefone ?? 'Não informado',
                    destacar: cliente.telefone != null,
                  ),
                  LinhaInformacao(
                    icone: const IconeSvg(
                      AppAssets.iconeEmail,
                      tamanho: AppSizes.iconeContato,
                    ),
                    rotulo: 'E-mail',
                    valor: cliente.email ?? 'Não informado',
                    destacar: cliente.email != null,
                  ),
                  LinhaInformacao(
                    icone: const IconeSvg(
                      AppAssets.iconeEndereco,
                      tamanho: AppSizes.iconeContato,
                    ),
                    rotulo: 'Endereço',
                    valor: cliente.endereco ?? 'Não informado',
                    destacar: cliente.endereco != null,
                  ),
                ],
              ),
              if (observacoes != null) _CartaoObservacoes(texto: observacoes),
            ],
          ),
        ),
        if (excluindo)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xxl),
            child: Center(child: IndicadorCarregando()),
          ),
      ],
    );
  }
}

class _MenuMaisAcoes extends StatelessWidget {
  const _MenuMaisAcoes({required this.cliente, required this.habilitado});

  final Cliente cliente;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const IconeSvg(
            AppAssets.iconeLixeira,
            tamanho: AppSizes.iconePequeno,
          ),
          style: MenuItemButton.styleFrom(
            foregroundColor: AppColors.primaria,
            textStyle: AppTextStyles.link,
          ),
          onPressed: () => confirmarExclusaoCliente(context, cliente),
          child: const Text('Excluir cliente'),
        ),
      ],
      builder: (context, controller, _) => BotaoIcone(
        descricao: 'Mais ações',
        estilo: EstiloBotaoIcone.translucido,
        icone: const IconeSvg(
          AppAssets.iconeMais,
          tamanho: AppSizes.iconePequeno,
        ),
        onPressed: !habilitado
            ? null
            : () => controller.isOpen ? controller.close() : controller.open(),
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
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.medio),
        boxShadow: AppShadows.itemLista,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.smd,
        children: [
          Text('OBSERVAÇÕES SOBRE O CLIENTE', style: AppTextStyles.rotuloSecao),
          Text(texto, style: AppTextStyles.textoLongo),
        ],
      ),
    );
  }
}
