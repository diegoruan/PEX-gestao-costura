import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/validadores.dart';
import '../../../shared/widgets/botao_pequeno.dart';
import '../../../shared/widgets/botao_suave.dart';
import '../../../shared/widgets/cabecalho_pagina.dart';
import '../../../shared/widgets/campo_texto.dart';
import '../../../shared/widgets/cartao_formulario.dart';
import '../../../shared/widgets/estado_mensagem.dart';
import '../../../shared/widgets/icone_svg.dart';
import '../../../shared/widgets/indicador_carregando.dart';
import '../../../shared/widgets/rotulo_secao.dart';
import '../../../shared/widgets/snackbar_mensagem.dart';
import '../bloc/clientes_bloc.dart';
import '../domain/cliente.dart';
import 'widgets/confirmar_exclusao_cliente.dart';

/// Cadastro (sem [clienteId]) e edição (com [clienteId]) na mesma tela.
class ClienteFormPage extends StatefulWidget {
  const ClienteFormPage({super.key, this.clienteId});

  final String? clienteId;

  bool get edicao => clienteId != null;

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _observacoesController = TextEditingController();

  /// Cliente sendo editado, como estava antes das alterações.
  Cliente? _original;

  @override
  void initState() {
    super.initState();
    _preencherSeEdicao(context.read<ClientesBloc>().state);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _apelidoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  // Se a tela for aberta direto pela rota, a lista pode ainda estar
  // carregando; nesse caso preenchemos quando ela chegar (ver listener).
  void _preencherSeEdicao(ClientesState state) {
    if (!widget.edicao || _original != null || state is! ClientesSucesso) {
      return;
    }
    final cliente = state.buscarPorId(widget.clienteId!);
    if (cliente == null) return;
    _original = cliente;
    _nomeController.text = cliente.nome;
    _apelidoController.text = cliente.apelido ?? '';
    _telefoneController.text = cliente.telefone ?? '';
    _emailController.text = cliente.email ?? '';
    _enderecoController.text = cliente.endereco ?? '';
    _observacoesController.text = cliente.observacoes ?? '';
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final bloc = context.read<ClientesBloc>();
    final original = _original;
    if (original == null) {
      bloc.add(
        ClienteCadastroSolicitado(
          nome: _nomeController.text,
          apelido: _apelidoController.text,
          telefone: _telefoneController.text,
          email: _emailController.text,
          endereco: _enderecoController.text,
          observacoes: _observacoesController.text,
        ),
      );
    } else {
      bloc.add(
        ClienteEdicaoSolicitada(
          original.copyWith(
            nome: _nomeController.text,
            apelido: () => _apelidoController.text,
            telefone: () => _telefoneController.text,
            email: () => _emailController.text,
            endereco: () => _enderecoController.text,
            observacoes: () => _observacoesController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dois listeners: um preenche o formulário de edição quando a lista
    // chega; o outro reage ao resultado de salvar/excluir.
    return BlocListener<ClientesBloc, ClientesState>(
      listenWhen: (_, atual) =>
          widget.edicao && _original == null && atual is ClientesSucesso,
      listener: (context, state) => setState(() => _preencherSeEdicao(state)),
      child: BlocConsumer<ClientesBloc, ClientesState>(
        listenWhen: (anterior, atual) =>
            atual is ClientesSucesso &&
            (anterior is! ClientesSucesso || anterior.acao != atual.acao) &&
            (ModalRoute.of(context)?.isCurrent ?? false),
        listener: (context, state) {
          if (state is! ClientesSucesso) return;
          switch (state.acao) {
            case AcaoCliente.salvo:
              mostrarSnackbarSucesso(context, 'Cliente salvo.');
              context.pop();
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
          final acao = state is ClientesSucesso ? state.acao : null;
          final ocupado = acao?.emAndamento ?? false;

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  CabecalhoPagina(
                    titulo: widget.edicao ? 'Editar Cliente' : 'Novo Cliente',
                    acoes: [
                      BotaoPequeno(
                        texto: 'Salvar',
                        carregando: acao == AcaoCliente.salvando,
                        onPressed:
                            ocupado || (widget.edicao && _original == null)
                            ? null
                            : _salvar,
                      ),
                    ],
                  ),
                  Expanded(child: _corpo(state, acao, ocupado)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _corpo(ClientesState state, AcaoCliente? acao, bool ocupado) {
    if (widget.edicao && _original == null) {
      return state is ClientesCarregando
          ? const Center(child: IndicadorCarregando())
          : EstadoMensagem(
              icone: Icons.person_off_outlined,
              titulo: 'Cliente não encontrado',
              mensagem: 'Ele pode ter sido excluído.',
              textoAcao: 'Voltar para a lista',
              onAcao: () => context.goNamed(AppRoutes.clientes),
            );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RotuloSecao('Dados pessoais'),
            const SizedBox(height: AppSpacing.md),
            CartaoFormulario(
              campos: [
                CampoTexto(
                  rotulo: 'Nome completo *',
                  hint: 'Ex: Ana Clara',
                  controller: _nomeController,
                  validator: Validadores.nome,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  enabled: !ocupado,
                ),
                CampoTexto(
                  rotulo: 'Apelido/Como chamar',
                  hint: 'Ex: Aninha',
                  controller: _apelidoController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  enabled: !ocupado,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const RotuloSecao('Contato'),
            const SizedBox(height: AppSpacing.md),
            CartaoFormulario(
              campos: [
                CampoTexto(
                  rotulo: 'WhatsApp / Telefone',
                  hint: '(11) 9 8765-4321',
                  controller: _telefoneController,
                  validator: Validadores.telefoneOpcional,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enabled: !ocupado,
                ),
                CampoTexto(
                  rotulo: 'E-mail (Opcional)',
                  hint: 'ana@email.com',
                  controller: _emailController,
                  validator: Validadores.emailOpcional,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !ocupado,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const RotuloSecao('Endereço (Opcional)'),
            const SizedBox(height: AppSpacing.md),
            CartaoFormulario(
              campos: [
                CampoTexto(
                  rotulo: 'Bairro / Cidade',
                  hint: 'Ex: Joinville, Santa Catarina',
                  controller: _enderecoController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  enabled: !ocupado,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const RotuloSecao('Observações'),
            const SizedBox(height: AppSpacing.md),
            CartaoFormulario(
              campos: [
                CampoTexto(
                  rotulo: 'Anotações sobre o cliente',
                  hint: 'Ex: prefere tecidos leves, não usa sintético...',
                  controller: _observacoesController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 3,
                  maxLines: null,
                  enabled: !ocupado,
                ),
              ],
            ),
            if (_original case final original?) ...[
              const SizedBox(height: AppSpacing.xxl * 2),
              BotaoSuave(
                texto: 'Excluir cliente',
                icone: const IconeSvg(
                  AppAssets.iconeLixeira,
                  tamanho: AppSizes.iconePequeno,
                ),
                carregando: acao == AcaoCliente.inativando,
                onPressed: ocupado
                    ? null
                    : () => confirmarExclusaoCliente(context, original),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
