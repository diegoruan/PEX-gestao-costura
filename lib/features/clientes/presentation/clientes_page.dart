import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/texto.dart';
import '../../../shared/widgets/botao_icone.dart';
import '../../../shared/widgets/cabecalho_pagina.dart';
import '../../../shared/widgets/campo_busca.dart';
import '../../../shared/widgets/estado_mensagem.dart';
import '../../../shared/widgets/indicador_carregando.dart';
import '../../../shared/widgets/rotulo_secao.dart';
import '../bloc/clientes_bloc.dart';
import '../domain/cliente.dart';
import 'widgets/cliente_card.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  // A busca é só um filtro visual sobre a lista que já está no estado, por
  // isso fica na tela e não vira evento do bloc.
  String _busca = '';

  void _novoCliente() => context.pushNamed(AppRoutes.clienteNovo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CabecalhoPagina(
              titulo: 'Clientes',
              acoes: [
                BotaoIcone(
                  descricao: 'Novo cliente',
                  estilo: EstiloBotaoIcone.primario,
                  icone: const Icon(
                    Icons.add,
                    size: AppSizes.iconeBotao,
                    color: AppColors.textoSobrePrimaria,
                  ),
                  onPressed: _novoCliente,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: CampoBusca(
                hint: 'Buscar cliente...',
                onChanged: (valor) => setState(() => _busca = valor),
              ),
            ),
            Expanded(
              child: BlocBuilder<ClientesBloc, ClientesState>(
                builder: (context, state) => switch (state) {
                  ClientesCarregando() => const Center(
                    child: IndicadorCarregando(),
                  ),
                  ClientesErro(:final mensagem) => EstadoMensagem(
                    icone: Icons.cloud_off_outlined,
                    titulo: 'Não foi possível carregar',
                    mensagem: mensagem,
                    textoAcao: 'Tentar novamente',
                    onAcao: () => context.read<ClientesBloc>().add(
                      const ClientesIniciado(),
                    ),
                  ),
                  ClientesSucesso(:final clientes) when clientes.isEmpty =>
                    EstadoMensagem(
                      icone: Icons.people_outline,
                      titulo: 'Nenhum cliente ainda',
                      mensagem: 'Cadastre seus clientes fixos para começar.',
                      textoAcao: 'Cadastrar cliente',
                      onAcao: _novoCliente,
                    ),
                  ClientesSucesso(:final clientes) => _ListaClientes(
                    clientes: _filtrar(clientes),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Cliente> _filtrar(List<Cliente> clientes) {
    final termo = Texto.normalizar(_busca);
    if (termo.isEmpty) return clientes;
    return clientes
        .where(
          (c) =>
              Texto.normalizar(c.nome).contains(termo) ||
              Texto.normalizar(c.apelido ?? '').contains(termo) ||
              (c.telefone?.contains(termo) ?? false),
        )
        .toList();
  }
}

class _ListaClientes extends StatelessWidget {
  const _ListaClientes({required this.clientes});

  final List<Cliente> clientes;

  @override
  Widget build(BuildContext context) {
    if (clientes.isEmpty) {
      return const EstadoMensagem(
        icone: Icons.search_off,
        titulo: 'Nenhum cliente encontrado',
        mensagem: 'Confira o nome ou telefone digitado.',
      );
    }

    // A lista já vem em ordem alfabética do repository; aqui só inserimos o
    // cabeçalho de letra sempre que a inicial muda.
    final itens = <Widget>[];
    String? letraAtual;
    for (final cliente in clientes) {
      final letra = Texto.normalizar(cliente.nomeExibicao).characters.first
          .toUpperCase();
      if (letra != letraAtual) {
        itens.add(
          Padding(
            padding: EdgeInsets.only(
              top: letraAtual == null ? AppSpacing.xs : AppSpacing.lg,
              bottom: AppSpacing.sm,
            ),
            child: RotuloSecao(letra),
          ),
        );
        letraAtual = letra;
      }
      itens.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.smd),
          child: ClienteCard(
            cliente: cliente,
            onTap: () => context.pushNamed(
              AppRoutes.clienteDetalhe,
              pathParameters: {AppRoutes.paramId: cliente.id},
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: itens,
    );
  }
}
