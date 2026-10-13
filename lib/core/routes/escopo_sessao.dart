import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/clientes/bloc/clientes_bloc.dart';
import '../../features/clientes/data/cliente_repository.dart';
import '../../features/fechamento/bloc/fechamento_bloc.dart';
import '../../features/historico/bloc/historico_bloc.dart';
import '../../features/home/bloc/home_bloc.dart';
import '../../features/pedidos/bloc/pedidos_bloc.dart';
import '../../features/pedidos/data/pedido_repository.dart';

/// Blocs que leem `usuarios/{uid}/...` e por isso pertencem a uma sessão.
///
/// Fica no builder do ShellRoute que envolve só as rotas autenticadas: os
/// blocs nascem depois do login, sobrevivem à troca de abas e são fechados
/// no logout, quando o redirect manda para /login e o shell sai da árvore.
/// Assim quem entra com outra conta nunca vê o estado da conta anterior.
///
/// Os providers são lazy: cada bloc é criado (e seu evento de início é
/// disparado, uma única vez) na primeira tela que o usa.
class EscopoSessao extends StatelessWidget {
  const EscopoSessao({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              HomeBloc(pedidoRepository: context.read<PedidoRepository>())
                ..add(const HomeIniciado()),
        ),
        // Um só ClientesBloc para a área de clientes e para o formulário de
        // pedido, que lista os clientes ativos.
        BlocProvider(
          create: (context) =>
              ClientesBloc(clienteRepository: context.read<ClienteRepository>())
                ..add(const ClientesIniciado()),
        ),
        BlocProvider(
          create: (context) =>
              PedidosBloc(pedidoRepository: context.read<PedidoRepository>())
                ..add(const PedidosIniciado()),
        ),
        BlocProvider(
          create: (context) =>
              HistoricoBloc(pedidoRepository: context.read<PedidoRepository>())
                ..add(const HistoricoIniciado()),
        ),
        BlocProvider(
          create: (context) =>
              FechamentoBloc(pedidoRepository: context.read<PedidoRepository>())
                ..add(const FechamentoIniciado()),
        ),
      ],
      child: child,
    );
  }
}
