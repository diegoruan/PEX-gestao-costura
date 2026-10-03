import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/falha.dart';
import '../data/pedido_repository.dart';
import '../domain/pedido.dart';
import 'pedidos_event.dart';
import 'pedidos_state.dart';

export 'pedidos_event.dart';
export 'pedidos_state.dart';

class PedidosBloc extends Bloc<PedidosEvent, PedidosState> {
  PedidosBloc({required this._pedidoRepository})
    : super(const PedidosCarregando()) {
    // restartable: ao tentar de novo após um erro, a assinatura anterior do
    // stream é cancelada antes de abrir outra.
    on<PedidosIniciado>(_onIniciado, transformer: restartable());
    on<PedidoCadastroSolicitado>(_onCadastroSolicitado);
    on<PedidoEdicaoSolicitada>(_onEdicaoSolicitada);
    on<PedidoFinalizacaoSolicitada>(_onFinalizacaoSolicitada);
    on<PedidoExclusaoSolicitada>(_onExclusaoSolicitada);
  }

  final PedidoRepository _pedidoRepository;

  Future<void> _onIniciado(
    PedidosIniciado event,
    Emitter<PedidosState> emit,
  ) async {
    emit(const PedidosCarregando());
    await emit.forEach(
      _pedidoRepository.observarPendentes(),
      onData: (pedidos) {
        final atual = state;
        return atual is PedidosSucesso
            ? atual.copyWith(pedidos: pedidos)
            : PedidosSucesso(pedidos);
      },
      onError: (erro, _) =>
          PedidosErro(erro is Falha ? erro.mensagem : Falha.mensagemGenerica),
    );
  }

  Future<void> _onCadastroSolicitado(
    PedidoCadastroSolicitado event,
    Emitter<PedidosState> emit,
  ) {
    return _executar(
      emit,
      emAndamento: AcaoPedido.salvando,
      concluida: AcaoPedido.salvo,
      acao: () => _pedidoRepository.cadastrar(
        clienteId: event.clienteId,
        clienteNome: event.clienteNome,
        nome: event.nome,
        valorUnitarioCentavos: event.valorUnitarioCentavos,
        quantidade: event.quantidade,
        dataEntrega: event.dataEntrega,
        observacoes: event.observacoes,
        foto: event.foto,
      ),
    );
  }

  Future<void> _onEdicaoSolicitada(
    PedidoEdicaoSolicitada event,
    Emitter<PedidosState> emit,
  ) {
    return _executar(
      emit,
      emAndamento: AcaoPedido.salvando,
      concluida: AcaoPedido.salvo,
      acao: () => _pedidoRepository.atualizar(
        event.pedido,
        novaFoto: event.novaFoto,
        removerFoto: event.removerFoto,
      ),
    );
  }

  Future<void> _onFinalizacaoSolicitada(
    PedidoFinalizacaoSolicitada event,
    Emitter<PedidosState> emit,
  ) {
    return _executar(
      emit,
      emAndamento: AcaoPedido.finalizando,
      concluida: AcaoPedido.finalizado,
      acao: () => _pedidoRepository.finalizar(event.id),
    );
  }

  Future<void> _onExclusaoSolicitada(
    PedidoExclusaoSolicitada event,
    Emitter<PedidosState> emit,
  ) {
    return _executar(
      emit,
      emAndamento: AcaoPedido.excluindo,
      concluida: AcaoPedido.excluido,
      acao: () => _pedidoRepository.excluir(event.id),
    );
  }

  /// Padrão das ações de escrita: em andamento -> concluída ou falhou,
  /// mantendo a lista atual no estado.
  Future<void> _executar(
    Emitter<PedidosState> emit, {
    required AcaoPedido emAndamento,
    required AcaoPedido concluida,
    required Future<void> Function() acao,
  }) async {
    emit(_comAcao(emAndamento));
    try {
      await acao();
      emit(_comAcao(concluida));
    } on FalhaEnvioFoto catch (e) {
      emit(_comAcao(AcaoPedido.fotoFalhou, mensagemErro: e.mensagem));
    } on Falha catch (e) {
      emit(_comAcao(AcaoPedido.falhou, mensagemErro: e.mensagem));
    }
  }

  PedidosSucesso _comAcao(AcaoPedido acao, {String? mensagemErro}) {
    final atual = state;
    final pedidos = atual is PedidosSucesso ? atual.pedidos : const <Pedido>[];
    return PedidosSucesso(pedidos, acao: acao, mensagemErro: mensagemErro);
  }
}
