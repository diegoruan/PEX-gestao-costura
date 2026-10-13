import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/falha.dart';
import '../../pedidos/data/pedido_repository.dart';
import '../domain/calculador_fechamento.dart';
import 'fechamento_event.dart';
import 'fechamento_state.dart';

export 'fechamento_event.dart';
export 'fechamento_state.dart';

/// Somente leitura: escuta os finalizados e deixa a conta com
/// [calcularFechamento].
class FechamentoBloc extends Bloc<FechamentoEvent, FechamentoState> {
  FechamentoBloc({
    required this._pedidoRepository,
    DateTime Function() agora = DateTime.now,
  }) : _agora = agora,
       super(FechamentoCarregando(inicioDoMes(agora()))) {
    // Um handler só para os dois eventos: o restartable() cancela apenas
    // dentro do mesmo handler, e a troca de mês precisa encerrar a
    // assinatura aberta pelo FechamentoIniciado.
    on<FechamentoEvent>(_onMesEscolhido, transformer: restartable());
  }

  final PedidoRepository _pedidoRepository;

  /// Injetável para os testes não dependerem do dia em que rodam.
  final DateTime Function() _agora;

  // Usa observarFinalizados() e recorta o mês em memória: a regra de qual
  // data define o mês fica só no calculador, e os pedidos não trazem foto
  // (ela fica em outro documento), então a lista é leve.
  Future<void> _onMesEscolhido(
    FechamentoEvent event,
    Emitter<FechamentoState> emit,
  ) async {
    final mes = inicioDoMes(switch (event) {
      FechamentoIniciado() => _agora(),
      FechamentoMesAlterado(:final mes) => mes,
    });
    emit(FechamentoCarregando(mes));
    await emit.forEach(
      _pedidoRepository.observarFinalizados(),
      onData: (pedidos) =>
          FechamentoSucesso(mes, calcularFechamento(pedidos, mes)),
      onError: (erro, _) => FechamentoErro(
        mes,
        erro is Falha ? erro.mensagem : Falha.mensagemGenerica,
      ),
    );
  }
}
