import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/dialogo_confirmacao.dart';
import '../../bloc/pedidos_bloc.dart';
import '../../domain/pedido.dart';

Future<void> confirmarFinalizacaoPedido(
  BuildContext context,
  Pedido pedido,
) async {
  final confirmou = await confirmarAcao(
    context,
    titulo: 'Marcar "${pedido.nome}" como entregue?',
    mensagem: 'O pedido sai da lista de pendentes e vai para o histórico.',
    textoConfirmar: 'Marcar como entregue',
    destrutiva: false,
  );
  if (confirmou && context.mounted) {
    context.read<PedidosBloc>().add(PedidoFinalizacaoSolicitada(pedido.id));
  }
}

/// Exclusão definitiva, só para pendentes. Para tirar a exclusão do app,
/// remova esta função, os botões que a chamam no detalhe, o evento
/// `PedidoExclusaoSolicitada` e `PedidoRepository.excluir`.
Future<void> confirmarExclusaoPedido(
  BuildContext context,
  Pedido pedido,
) async {
  final confirmou = await confirmarAcao(
    context,
    titulo: 'Excluir "${pedido.nome}"?',
    mensagem:
        'O pedido e a foto serão apagados de vez. Essa ação não pode ser '
        'desfeita.',
    textoConfirmar: 'Excluir',
  );
  if (confirmou && context.mounted) {
    context.read<PedidosBloc>().add(PedidoExclusaoSolicitada(pedido.id));
  }
}
