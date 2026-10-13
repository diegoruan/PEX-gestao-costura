import 'package:equatable/equatable.dart';

import 'fechamento_cliente.dart';

class FechamentoMensal extends Equatable {
  const FechamentoMensal({required this.mes, required this.clientes});

  /// Dia 1 do mês de referência, à meia-noite.
  final DateTime mes;

  /// Em ordem alfabética pelo nome do cliente.
  final List<FechamentoCliente> clientes;

  int get totalGeralCentavos =>
      clientes.fold(0, (soma, c) => soma + c.totalCentavos);

  int get quantidadePecas =>
      clientes.fold(0, (soma, c) => soma + c.quantidadePecas);

  /// Fatia do cliente no total, arredondada para o inteiro mais próximo
  /// ("34% do mês"). Só com inteiros, como o resto do cálculo.
  int percentualDe(FechamentoCliente cliente) {
    final total = totalGeralCentavos;
    if (total == 0) return 0;
    return (cliente.totalCentavos * 100 + total ~/ 2) ~/ total;
  }

  @override
  List<Object?> get props => [mes, clientes];
}
