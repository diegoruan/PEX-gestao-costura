import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/falha.dart';
import '../../pedidos/data/pedido_repository.dart';
import '../../pedidos/domain/pedido.dart';
import 'home_event.dart';
import 'home_state.dart';

export 'home_event.dart';
export 'home_state.dart';

/// Somente leitura: junta os pendentes e os finalizados que já existem no
/// PedidoRepository e monta o [ResumoHome].
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required this._pedidoRepository, this._agora = DateTime.now})
    : super(const HomeCarregando()) {
    // restartable: ao tentar de novo após um erro, as assinaturas anteriores
    // são canceladas antes de abrir outras.
    on<HomeIniciado>(_onIniciado, transformer: restartable());
  }

  final PedidoRepository _pedidoRepository;

  /// Injetável para os testes não dependerem do dia em que rodam.
  final DateTime Function() _agora;

  Future<void> _onIniciado(HomeIniciado event, Emitter<HomeState> emit) {
    emit(const HomeCarregando());
    List<Pedido>? pendentes;
    List<Pedido>? finalizados;
    var falhou = false;

    // Só emite quando as duas listas já chegaram, para os números não
    // aparecerem pela metade; depois de um erro, para de atualizar.
    void atualizar() {
      if (falhou || pendentes == null || finalizados == null) return;
      emit(
        HomeSucesso(
          ResumoHome.calcular(
            pendentes: pendentes!,
            finalizados: finalizados!,
            agora: _agora(),
          ),
        ),
      );
    }

    void erro(Object erro, StackTrace _) {
      if (falhou) return;
      falhou = true;
      emit(HomeErro(erro is Falha ? erro.mensagem : Falha.mensagemGenerica));
    }

    return Future.wait([
      emit.onEach(
        _pedidoRepository.observarPendentes(),
        onData: (lista) {
          pendentes = lista;
          atualizar();
        },
        onError: erro,
      ),
      emit.onEach(
        _pedidoRepository.observarFinalizados(),
        onData: (lista) {
          finalizados = lista;
          atualizar();
        },
        onError: erro,
      ),
    ]);
  }
}
