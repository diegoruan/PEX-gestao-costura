import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/dialogo_confirmacao.dart';
import '../../bloc/clientes_bloc.dart';
import '../../domain/cliente.dart';

/// Usado no detalhe e no formulário de edição.
Future<void> confirmarExclusaoCliente(
  BuildContext context,
  Cliente cliente,
) async {
  final confirmou = await confirmarAcao(
    context,
    titulo: 'Excluir ${cliente.nome}?',
    mensagem:
        'O cadastro sai da sua lista de clientes, mas os pedidos e '
        'fechamentos antigos continuam guardados.',
    textoConfirmar: 'Excluir',
  );
  if (confirmou && context.mounted) {
    context.read<ClientesBloc>().add(ClienteInativacaoSolicitada(cliente.id));
  }
}
