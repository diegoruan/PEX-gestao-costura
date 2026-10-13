import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/falha.dart';
import '../../pedidos/data/pedido_repository.dart';
import '../../pedidos/domain/pedido.dart';
import 'historico_event.dart';
import 'historico_state.dart';

export 'historico_event.dart';
export 'historico_state.dart';

/// Somente leitura: o histórico só escuta os finalizados e filtra em memória.
class HistoricoBloc extends Bloc<HistoricoEvent, HistoricoState> {
  HistoricoBloc({required this._pedidoRepository})
    : super(const HistoricoCarregando()) {
    // restartable: ao tentar de novo após um erro, a assinatura anterior do
    // stream é cancelada antes de abrir outra.
    on<HistoricoIniciado>(_onIniciado, transformer: restartable());
    on<HistoricoFiltroAlterado>(_onFiltroAlterado);
  }

  final PedidoRepository _pedidoRepository;

  Future<void> _onIniciado(
    HistoricoIniciado event,
    Emitter<HistoricoState> emit,
  ) async {
    emit(const HistoricoCarregando());
    await emit.forEach(
      _pedidoRepository.observarFinalizados(),
      onData: (pedidos) {
        // O agrupamento por mês depende desta ordem; ordenar aqui também
        // deixa o bloc correto sem depender de como o repository entrega.
        final ordenados = [...pedidos]..sort(Pedido.compararPorFinalizacao);
        final atual = state;
        return atual is HistoricoSucesso
            ? atual.copyWith(pedidos: ordenados)
            : HistoricoSucesso(ordenados);
      },
      onError: (erro, _) =>
          HistoricoErro(erro is Falha ? erro.mensagem : Falha.mensagemGenerica),
    );
  }

  void _onFiltroAlterado(
    HistoricoFiltroAlterado event,
    Emitter<HistoricoState> emit,
  ) {
    final atual = state;
    if (atual is HistoricoSucesso) emit(atual.copyWith(filtro: event.filtro));
  }
}
