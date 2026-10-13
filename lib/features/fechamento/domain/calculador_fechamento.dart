import '../../../core/utils/texto.dart';
import '../../pedidos/domain/pedido.dart';
import 'fechamento_cliente.dart';
import 'fechamento_mensal.dart';

/// A data que decide em que mês o pedido é cobrado. É a da finalização
/// porque a facção recebe pelo que entregou no mês; trocar a regra (por
/// exemplo, para `dataEntrega`) é mudar só esta linha.
DateTime? dataDoFechamento(Pedido pedido) => pedido.dataFinalizacao;

DateTime inicioDoMes(DateTime data) => DateTime(data.year, data.month);

// O DateTime normaliza mês 0 e 13, então a virada do ano sai de graça.
DateTime mesAnterior(DateTime mes) => DateTime(mes.year, mes.month - 1);

DateTime mesSeguinte(DateTime mes) => DateTime(mes.year, mes.month + 1);

/// Fechamento de [mes] (qualquer instante dentro dele): só pedidos
/// finalizados cuja [dataDoFechamento] cai do dia 1 às 00:00 até antes do
/// dia 1 do mês seguinte, no horário local. Agrupa por cliente.
FechamentoMensal calcularFechamento(List<Pedido> pedidos, DateTime mes) {
  final inicio = inicioDoMes(mes);
  final fim = mesSeguinte(inicio);

  final porCliente = <String, List<Pedido>>{};
  for (final pedido in pedidos) {
    final data = dataDoFechamento(pedido);
    if (!pedido.finalizado ||
        data == null ||
        data.isBefore(inicio) ||
        !data.isBefore(fim)) {
      continue;
    }
    porCliente.putIfAbsent(pedido.clienteId, () => []).add(pedido);
  }

  final clientes = [
    for (final MapEntry(key: clienteId, value: doCliente) in porCliente.entries)
      _fechar(clienteId, doCliente),
  ]..sort(_porNome);

  return FechamentoMensal(mes: inicio, clientes: clientes);
}

FechamentoCliente _fechar(String clienteId, List<Pedido> pedidos) {
  final ordenados = [...pedidos]
    ..sort((a, b) => dataDoFechamento(b)!.compareTo(dataDoFechamento(a)!));
  return FechamentoCliente(
    clienteId: clienteId,
    clienteNome: ordenados.first.clienteNome,
    totalCentavos: ordenados.fold(0, (soma, p) => soma + p.totalCentavos),
    quantidadePecas: ordenados.fold(0, (soma, p) => soma + p.quantidade),
    pedidos: ordenados,
  );
}

int _porNome(FechamentoCliente a, FechamentoCliente b) {
  final porNome = Texto.normalizar(a.clienteNome)
      .compareTo(Texto.normalizar(b.clienteNome));
  return porNome != 0 ? porNome : a.clienteId.compareTo(b.clienteId);
}
