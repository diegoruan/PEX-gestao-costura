import 'package:equatable/equatable.dart';

import '../../../core/utils/texto.dart';
import '../../pedidos/domain/pedido.dart';

extension PedidoHistorico on Pedido {
  /// Mesma regra da ordenação do repository: um finalizado sem data (gravado
  /// antes de o campo existir) usa a data de cadastro.
  DateTime get finalizadoEm => dataFinalizacao ?? criadoEm;
}

/// Dias inteiros, inclusive nas duas pontas.
typedef PeriodoHistorico = ({DateTime inicio, DateTime fim});

/// Cliente que aparece no histórico, para o filtro "Clientes".
typedef ClienteHistorico = ({String id, String nome});

/// Filtros da tela, aplicados em memória sobre a lista completa.
class HistoricoFiltro extends Equatable {
  const HistoricoFiltro({this.busca = '', this.clienteId, this.periodo});

  final String busca;
  final String? clienteId;
  final PeriodoHistorico? periodo;

  /// O chip "Todos": sem cliente nem período. A busca é independente.
  bool get todos => clienteId == null && periodo == null;

  /// Nos campos opcionais, passe uma função para poder limpar o valor:
  /// `filtro.copyWith(clienteId: () => null)`.
  HistoricoFiltro copyWith({
    String? busca,
    String? Function()? clienteId,
    PeriodoHistorico? Function()? periodo,
  }) {
    return HistoricoFiltro(
      busca: busca ?? this.busca,
      clienteId: clienteId != null ? clienteId() : this.clienteId,
      periodo: periodo != null ? periodo() : this.periodo,
    );
  }

  /// Mantém a ordem de [pedidos].
  List<Pedido> aplicar(List<Pedido> pedidos) {
    final termo = Texto.normalizar(busca);
    final periodo = this.periodo;
    final inicio = periodo == null ? null : _soData(periodo.inicio);
    final fim = periodo == null ? null : _soData(periodo.fim);

    return [
      for (final p in pedidos)
        if ((clienteId == null || p.clienteId == clienteId) &&
            (inicio == null || !_soData(p.finalizadoEm).isBefore(inicio)) &&
            (fim == null || !_soData(p.finalizadoEm).isAfter(fim)) &&
            (termo.isEmpty ||
                Texto.normalizar(p.nome).contains(termo) ||
                Texto.normalizar(p.clienteNome).contains(termo)))
          p,
    ];
  }

  static DateTime _soData(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  List<Object?> get props => [busca, clienteId, periodo];
}

/// Um grupo da lista: as peças finalizadas num mês e o total delas.
class MesHistorico extends Equatable {
  const MesHistorico({required this.mes, required this.pedidos});

  /// Dia 1 do mês, à meia-noite.
  final DateTime mes;
  final List<Pedido> pedidos;

  int get totalCentavos => pedidos.fold(0, (soma, p) => soma + p.totalCentavos);

  /// Agrupa pelo mês de finalização. Os grupos e os pedidos de cada grupo
  /// seguem a ordem de [pedidos] (no estado, mais recente primeiro).
  static List<MesHistorico> agrupar(List<Pedido> pedidos) {
    final grupos = <DateTime, List<Pedido>>{};
    for (final p in pedidos) {
      final mes = DateTime(p.finalizadoEm.year, p.finalizadoEm.month);
      grupos.putIfAbsent(mes, () => []).add(p);
    }
    return [
      for (final MapEntry(key: mes, value: doMes) in grupos.entries)
        MesHistorico(mes: mes, pedidos: doMes),
    ];
  }

  @override
  List<Object?> get props => [mes, pedidos];
}

/// Números do cartão do topo, calculados sobre a lista já filtrada.
class ResumoHistorico extends Equatable {
  const ResumoHistorico({
    required this.pecas,
    required this.totalCentavos,
    required this.clientes,
  });

  factory ResumoHistorico.de(List<Pedido> pedidos) {
    return ResumoHistorico(
      pecas: pedidos.fold(0, (soma, p) => soma + p.quantidade),
      totalCentavos: pedidos.fold(0, (soma, p) => soma + p.totalCentavos),
      clientes: {for (final p in pedidos) p.clienteId}.length,
    );
  }

  /// Soma das quantidades, não o número de pedidos.
  final int pecas;
  final int totalCentavos;

  /// Clientes diferentes atendidos.
  final int clientes;

  @override
  List<Object?> get props => [pecas, totalCentavos, clientes];
}

sealed class HistoricoState extends Equatable {
  const HistoricoState();

  @override
  List<Object?> get props => [];
}

final class HistoricoCarregando extends HistoricoState {
  const HistoricoCarregando();
}

final class HistoricoSucesso extends HistoricoState {
  const HistoricoSucesso(this.pedidos, {this.filtro = const HistoricoFiltro()});

  /// Todos os finalizados, mais recente primeiro, sem filtro.
  final List<Pedido> pedidos;
  final HistoricoFiltro filtro;

  List<Pedido> get filtrados => filtro.aplicar(pedidos);

  /// Opções do filtro "Clientes", em ordem alfabética. Usa o nome gravado no
  /// pedido mais recente: o cliente pode ter sido renomeado ou inativado.
  List<ClienteHistorico> get clientes {
    final nomes = <String, String>{};
    for (final p in pedidos) {
      nomes.putIfAbsent(p.clienteId, () => p.clienteNome);
    }
    return [
      for (final MapEntry(key: id, value: nome) in nomes.entries)
        (id: id, nome: nome),
    ]..sort(
      (a, b) => Texto.normalizar(a.nome).compareTo(Texto.normalizar(b.nome)),
    );
  }

  HistoricoSucesso copyWith({List<Pedido>? pedidos, HistoricoFiltro? filtro}) {
    return HistoricoSucesso(
      pedidos ?? this.pedidos,
      filtro: filtro ?? this.filtro,
    );
  }

  @override
  List<Object?> get props => [pedidos, filtro];
}

final class HistoricoErro extends HistoricoState {
  const HistoricoErro(this.mensagem);

  final String mensagem;

  @override
  List<Object?> get props => [mensagem];
}
