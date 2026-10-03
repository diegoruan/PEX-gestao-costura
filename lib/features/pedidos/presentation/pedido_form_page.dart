import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/falha.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/imagem_service.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatadores.dart';
import '../../../core/utils/moeda_input_formatter.dart';
import '../../../core/utils/validadores.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/botao_pequeno.dart';
import '../../../shared/widgets/botao_primario.dart';
import '../../../shared/widgets/cabecalho_pagina.dart';
import '../../../shared/widgets/campo_texto.dart';
import '../../../shared/widgets/cartao_formulario.dart';
import '../../../shared/widgets/estado_mensagem.dart';
import '../../../shared/widgets/icone_svg.dart';
import '../../../shared/widgets/indicador_carregando.dart';
import '../../../shared/widgets/link_texto.dart';
import '../../../shared/widgets/rotulo_secao.dart';
import '../../../shared/widgets/snackbar_mensagem.dart';
import '../../clientes/bloc/clientes_bloc.dart';
import '../bloc/pedidos_bloc.dart';
import '../domain/pedido.dart';
import 'widgets/aviso_pedido.dart';
import 'widgets/campos_pedido.dart';
import 'widgets/dialogos_pedido.dart';
import 'widgets/seletor_foto.dart';

typedef _ClienteEscolhido = ({String id, String nome});

/// Cadastro (sem [pedidoId]) e edição (com [pedidoId]) na mesma tela.
class PedidoFormPage extends StatefulWidget {
  const PedidoFormPage({super.key, this.pedidoId});

  final String? pedidoId;

  bool get edicao => pedidoId != null;

  @override
  State<PedidoFormPage> createState() => _PedidoFormPageState();
}

class _PedidoFormPageState extends State<PedidoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _observacoesController = TextEditingController();

  _ClienteEscolhido? _cliente;
  int _quantidade = 1;
  DateTime? _dataEntrega;

  /// Foto escolhida agora, ainda não enviada.
  Uint8List? _fotoNova;

  /// Na edição: a pessoa pediu para tirar a foto que já estava salva.
  bool _removerFoto = false;
  bool _carregandoFoto = false;

  /// Pedido sendo editado, como estava antes das alterações.
  Pedido? _original;

  @override
  void initState() {
    super.initState();
    _preencherSeEdicao(context.read<PedidosBloc>().state);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  // Se a tela for aberta direto pela rota, a lista pode ainda estar
  // carregando; nesse caso preenchemos quando ela chegar (ver listener).
  void _preencherSeEdicao(PedidosState state) {
    if (!widget.edicao || _original != null || state is! PedidosSucesso) {
      return;
    }
    final pedido = state.buscarPorId(widget.pedidoId!);
    if (pedido == null) return;
    _original = pedido;
    _nomeController.text = pedido.nome;
    _valorController.text = MoedaInputFormatter.formatar(
      pedido.valorUnitarioCentavos,
    );
    _observacoesController.text = pedido.observacoes ?? '';
    _cliente = (id: pedido.clienteId, nome: pedido.clienteNome);
    _quantidade = pedido.quantidade;
    _dataEntrega = pedido.dataEntrega;
  }

  String? get _fotoSalva => _removerFoto ? null : _original?.fotoUrl;

  Future<void> _escolherFoto() async {
    final temFoto = _fotoNova != null || _fotoSalva != null;
    final escolha = await perguntarOrigemFoto(context, temFoto: temFoto);
    if (escolha == null || !mounted) return;

    final origem = escolha.origem;
    if (origem == null) {
      setState(() {
        _fotoNova = null;
        _removerFoto = true;
      });
      return;
    }

    setState(() => _carregandoFoto = true);
    try {
      final bytes = await context.read<ImagemService>().escolher(origem);
      if (bytes != null && mounted) setState(() => _fotoNova = bytes);
    } on Falha catch (e) {
      if (mounted) mostrarSnackbarErro(context, e.mensagem);
    } finally {
      if (mounted) setState(() => _carregandoFoto = false);
    }
  }

  void _salvar({bool semFoto = false}) {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final bloc = context.read<PedidosBloc>();
    final cliente = _cliente!;
    final valor = MoedaInputFormatter.centavos(_valorController.text);
    final foto = semFoto ? null : _fotoNova;
    final original = _original;

    if (original == null) {
      bloc.add(
        PedidoCadastroSolicitado(
          clienteId: cliente.id,
          clienteNome: cliente.nome,
          nome: _nomeController.text,
          valorUnitarioCentavos: valor,
          quantidade: _quantidade,
          dataEntrega: _dataEntrega!,
          observacoes: _observacoesController.text,
          foto: foto,
        ),
      );
    } else {
      bloc.add(
        PedidoEdicaoSolicitada(
          original.copyWith(
            clienteId: cliente.id,
            clienteNome: cliente.nome,
            nome: _nomeController.text,
            valorUnitarioCentavos: valor,
            quantidade: _quantidade,
            dataEntrega: _dataEntrega,
            observacoes: () => _observacoesController.text,
          ),
          novaFoto: foto,
          removerFoto: _removerFoto,
        ),
      );
    }
  }

  Future<void> _tratarFalhaFoto(String mensagem) async {
    final resposta = await perguntarFalhaFoto(context, mensagem);
    if (!mounted) return;
    switch (resposta) {
      case RespostaFalhaFoto.tentarDeNovo:
        _salvar();
      case RespostaFalhaFoto.salvarSemFoto:
        setState(() => _fotoNova = null);
        _salvar(semFoto: true);
      case null:
        break;
    }
  }

  Future<DateTime?> _escolherData(DateTime? atual) {
    final hoje = DateUtils.dateOnly(DateTime.now());
    final inicial = atual ?? hoje;
    return showDatePicker(
      context: context,
      initialDate: inicial,
      // Não deixa marcar entrega no passado, mas aceita manter a data de um
      // pedido que já está atrasado.
      firstDate: inicial.isBefore(hoje) ? inicial : hoje,
      lastDate: DateTime(hoje.year + 3, hoje.month, hoje.day),
      helpText: 'Data de entrega',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dois listeners: um preenche o formulário de edição quando a lista
    // chega; o outro reage ao resultado de salvar.
    return BlocListener<PedidosBloc, PedidosState>(
      listenWhen: (_, atual) =>
          widget.edicao && _original == null && atual is PedidosSucesso,
      listener: (context, state) => setState(() => _preencherSeEdicao(state)),
      child: BlocConsumer<PedidosBloc, PedidosState>(
        listenWhen: (anterior, atual) =>
            atual is PedidosSucesso &&
            (anterior is! PedidosSucesso || anterior.acao != atual.acao) &&
            (ModalRoute.of(context)?.isCurrent ?? false),
        listener: (context, state) {
          if (state is! PedidosSucesso) return;
          switch (state.acao) {
            case AcaoPedido.salvo:
              mostrarSnackbarSucesso(context, 'Pedido salvo.');
              context.pop();
            case AcaoPedido.fotoFalhou:
              _tratarFalhaFoto(state.mensagemErro!);
            case AcaoPedido.falhou:
              mostrarSnackbarErro(context, state.mensagemErro!);
            default:
              break;
          }
        },
        builder: (context, state) {
          final acao = state is PedidosSucesso ? state.acao : null;
          final ocupado = (acao?.emAndamento ?? false) || _carregandoFoto;
          final salvando = acao == AcaoPedido.salvando;
          final aguardandoPedido = widget.edicao && _original == null;

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  CabecalhoPagina(
                    titulo: widget.edicao ? 'Editar Pedido' : 'Novo Pedido',
                    acoes: [
                      BotaoPequeno(
                        texto: 'Salvar',
                        carregando: salvando,
                        onPressed: ocupado || aguardandoPedido ? null : _salvar,
                      ),
                    ],
                  ),
                  Expanded(
                    child: aguardandoPedido
                        ? _carregandoOuNaoEncontrado(state)
                        : _formulario(ocupado: ocupado, salvando: salvando),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _carregandoOuNaoEncontrado(PedidosState state) {
    return state is PedidosCarregando
        ? const Center(child: IndicadorCarregando())
        : EstadoMensagem(
            icone: Icons.search_off,
            titulo: 'Pedido não encontrado',
            mensagem: 'Ele pode ter sido entregue ou excluído.',
            textoAcao: 'Voltar para a lista',
            onAcao: () => context.goNamed(AppRoutes.pedidos),
          );
  }

  Widget _formulario({required bool ocupado, required bool salvando}) {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: RotuloSecao('Foto da peça (opcional)')),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: SeletorFoto(
                fotoNova: _fotoNova,
                fotoUrl: _fotoSalva,
                carregando: _carregandoFoto,
                onTap: ocupado ? null : _escolherFoto,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const RotuloSecao('Dados da peça'),
            const SizedBox(height: AppSpacing.md),
            _AvisoSemClientes(clienteEscolhido: _cliente != null),
            CartaoFormulario(
              campos: [
                CampoTexto(
                  rotulo: 'Nome da peça *',
                  hint: 'Ex: Vestido Floral',
                  controller: _nomeController,
                  validator: Validadores.nome,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  enabled: !ocupado,
                ),
                CampoTexto(
                  rotulo: r'Valor unitário (R$) *',
                  hint: '0,00',
                  controller: _valorController,
                  validator: Validadores.valorPositivo,
                  keyboardType: TextInputType.number,
                  inputFormatters: [MoedaInputFormatter()],
                  textInputAction: TextInputAction.done,
                  enabled: !ocupado,
                ),
                _campoCliente(ocupado),
                CampoQuantidade(
                  valorInicial: _quantidade,
                  validator: Validadores.quantidade,
                  enabled: !ocupado,
                  onChanged: (valor) => setState(() => _quantidade = valor),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ValueListenableBuilder(
              valueListenable: _valorController,
              builder: (context, valor, _) => CartaoTotal(
                valorUnitarioCentavos: MoedaInputFormatter.centavos(valor.text),
                quantidade: _quantidade,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const RotuloSecao('Prazo'),
            const SizedBox(height: AppSpacing.md),
            CartaoFormulario(
              campos: [
                LinhaInformativa(
                  rotulo: 'Data de entrada',
                  valor: Formatadores.dataExtenso(
                    _original?.criadoEm ?? DateTime.now(),
                  ),
                ),
                CampoSelecao<DateTime>(
                  rotulo: 'Data de entrega *',
                  valorInicial: _dataEntrega,
                  validator: Validadores.selecionado(
                    'Escolha a data de entrega',
                  ),
                  enabled: !ocupado,
                  escolher: _escolherData,
                  onChanged: (data) => _dataEntrega = data,
                  fim: const IconeSvg(
                    AppAssets.iconeCalendario,
                    tamanho: AppSizes.iconeResumo,
                  ),
                  conteudo: (data) => data == null
                      ? Text(
                          'Toque para escolher',
                          style: AppTextStyles.placeholderCampo,
                        )
                      : Text(
                          Formatadores.dataExtenso(data),
                          style: AppTextStyles.textoCampo,
                        ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const RotuloSecao('Observações'),
            const SizedBox(height: AppSpacing.md),
            CartaoFormulario(
              campos: [
                CampoTexto(
                  rotulo: 'Detalhes / Instrução',
                  hint: 'Ex: tecido floral, tamanho P, com forro...',
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
            const SizedBox(height: AppSpacing.xxl * 2),
            BotaoPrimario(
              texto: 'Salvar Pedido',
              icone: const IconeSvg(
                AppAssets.iconeSalvar,
                tamanho: AppSizes.iconeBotao,
              ),
              carregando: salvando,
              onPressed: ocupado ? null : _salvar,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: LinkTexto(
                texto: 'Cancelar',
                secundario: true,
                onPressed: ocupado ? null : () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Só lê a lista de clientes ativos do ClientesBloc.
  Widget _campoCliente(bool ocupado) {
    return BlocBuilder<ClientesBloc, ClientesState>(
      builder: (context, state) {
        final clientes = state is ClientesSucesso ? state.clientes : null;
        return CampoSelecao<_ClienteEscolhido>(
          rotulo: 'Cliente *',
          valorInicial: _cliente,
          validator: Validadores.selecionado('Escolha o cliente'),
          enabled: !ocupado && clientes != null && clientes.isNotEmpty,
          onChanged: (cliente) => _cliente = cliente,
          escolher: (atual) async {
            final cliente = await escolherCliente(
              context,
              clientes: clientes!,
              selecionadoId: atual?.id,
            );
            return cliente == null
                ? null
                : (id: cliente.id, nome: cliente.nome);
          },
          fim: const IconeSvg(
            AppAssets.iconeChevron,
            tamanho: AppSizes.iconePequeno,
          ),
          conteudo: (cliente) {
            if (cliente != null) {
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Row(
                  spacing: AppSpacing.sm,
                  children: [
                    AvatarIniciais(nome: cliente.nome, compacto: true),
                    Expanded(
                      child: Text(
                        cliente.nome,
                        style: AppTextStyles.tituloItem,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }
            final texto = switch (state) {
              ClientesCarregando() => 'Carregando clientes...',
              ClientesErro() => 'Não foi possível carregar os clientes',
              ClientesSucesso(:final clientes) when clientes.isEmpty =>
                'Nenhum cliente cadastrado',
              ClientesSucesso() => 'Toque para escolher',
            };
            return Text(texto, style: AppTextStyles.placeholderCampo);
          },
        );
      },
    );
  }
}

/// Sem clientes não dá para cadastrar pedido: avisa e leva ao cadastro.
class _AvisoSemClientes extends StatelessWidget {
  const _AvisoSemClientes({required this.clienteEscolhido});

  final bool clienteEscolhido;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientesBloc, ClientesState>(
      builder: (context, state) {
        final aviso = switch (state) {
          ClientesSucesso(:final clientes)
              when clientes.isEmpty && !clienteEscolhido =>
            AvisoPedido(
              titulo: 'Nenhum cliente cadastrado',
              mensagem: 'Cadastre um cliente antes de criar o pedido.',
              textoAcao: 'Cadastrar cliente',
              onAcao: () => context.pushNamed(AppRoutes.clienteNovo),
            ),
          ClientesErro(:final mensagem) => AvisoPedido(
            titulo: 'Não foi possível carregar os clientes',
            mensagem: mensagem,
            textoAcao: 'Tentar novamente',
            onAcao: () =>
                context.read<ClientesBloc>().add(const ClientesIniciado()),
          ),
          _ => null,
        };
        if (aviso == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: aviso,
        );
      },
    );
  }
}
