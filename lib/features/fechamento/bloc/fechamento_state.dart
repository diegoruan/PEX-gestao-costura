import 'package:equatable/equatable.dart';

import '../domain/fechamento_mensal.dart';

/// Todos os estados guardam o mês: o seletor continua na tela enquanto o mês
/// carrega ou se der erro.
sealed class FechamentoState extends Equatable {
  const FechamentoState(this.mesSelecionado);

  /// Dia 1 do mês, à meia-noite.
  final DateTime mesSelecionado;

  @override
  List<Object?> get props => [mesSelecionado];
}

final class FechamentoCarregando extends FechamentoState {
  const FechamentoCarregando(super.mesSelecionado);
}

final class FechamentoSucesso extends FechamentoState {
  const FechamentoSucesso(super.mesSelecionado, this.fechamento);

  final FechamentoMensal fechamento;

  @override
  List<Object?> get props => [mesSelecionado, fechamento];
}

final class FechamentoErro extends FechamentoState {
  const FechamentoErro(super.mesSelecionado, this.mensagem);

  final String mensagem;

  @override
  List<Object?> get props => [mesSelecionado, mensagem];
}
