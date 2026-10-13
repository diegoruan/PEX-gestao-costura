import 'package:equatable/equatable.dart';

import 'historico_state.dart';

sealed class HistoricoEvent extends Equatable {
  const HistoricoEvent();

  @override
  List<Object?> get props => [];
}

/// Começa (ou recomeça, após um erro) a escutar os pedidos finalizados.
final class HistoricoIniciado extends HistoricoEvent {
  const HistoricoIniciado();
}

/// Busca, cliente ou período mudou. Leva o filtro inteiro já atualizado.
final class HistoricoFiltroAlterado extends HistoricoEvent {
  const HistoricoFiltroAlterado(this.filtro);

  final HistoricoFiltro filtro;

  @override
  List<Object?> get props => [filtro];
}
