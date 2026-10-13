import 'package:equatable/equatable.dart';

sealed class FechamentoEvent extends Equatable {
  const FechamentoEvent();

  @override
  List<Object?> get props => [];
}

/// Abre no mês atual.
final class FechamentoIniciado extends FechamentoEvent {
  const FechamentoIniciado();
}

/// Troca o mês exibido; também serve para tentar de novo após um erro.
final class FechamentoMesAlterado extends FechamentoEvent {
  const FechamentoMesAlterado(this.mes);

  /// Qualquer instante dentro do mês desejado.
  final DateTime mes;

  @override
  List<Object?> get props => [mes];
}
