import 'package:equatable/equatable.dart';

import '../../../core/utils/texto.dart';
import '../../fechamento/domain/calculador_fechamento.dart';
import '../../pedidos/domain/pedido.dart';

/// Tudo o que a Home mostra, calculado de uma vez a partir das duas listas.
class ResumoHome extends Equatable {
  const ResumoHome({
    required this.pedidosEmAberto,
    required this.pecasFinalizadasNoMes,
    required this.totalMesCentavos,
    required this.atrasados,
    required this.paraHoje,
    required this.recentes,
  });

  /// Os números do mês vêm do mesmo calculador do fechamento, para a Home e
  /// a tela de fechamento nunca discordarem.
  factory ResumoHome.calcular({
    required List<Pedido> pendentes,
    required List<Pedido> finalizados,
    required DateTime agora,
  }) {
    final mes = calcularFechamento(finalizados, agora);
    final recentes = [...pendentes, ...finalizados]
      ..sort((a, b) => _movimentadoEm(b).compareTo(_movimentadoEm(a)));

    return ResumoHome(
      pedidosEmAberto: pendentes.length,
      pecasFinalizadasNoMes: mes.quantidadePecas,
      totalMesCentavos: mes.totalGeralCentavos,
      atrasados: [
        for (final p in pendentes)
          if (p.prazo(agora) == PrazoPedido.atrasado) p,
      ],
      paraHoje: [
        for (final p in pendentes)
          if (p.prazo(agora) == PrazoPedido.hoje) p,
      ],
      recentes: recentes.take(quantidadeRecentes).toList(),
    );
  }

  static const quantidadeRecentes = 3;

  final int pedidosEmAberto;
  final int pecasFinalizadasNoMes;
  final int totalMesCentavos;

  /// Pendentes, na ordem de entrega que vem do repository.
  final List<Pedido> atrasados;
  final List<Pedido> paraHoje;

  /// Pendentes e finalizados juntos, o mais movimentado por último primeiro.
  final List<Pedido> recentes;

  bool get temAviso => atrasados.isNotEmpty || paraHoje.isNotEmpty;

  /// "2 entregas hoje e uma atrasada!", "1 entrega atrasada!"...
  String get tituloAviso {
    final hoje = paraHoje.length;
    final atrasadas = atrasados.length;
    final partes = [
      if (hoje > 0) hoje == 1 ? '1 entrega hoje' : '$hoje entregas hoje',
      if (atrasadas > 0)
        switch ((hoje > 0, atrasadas)) {
          (true, 1) => 'uma atrasada',
          (true, _) => '$atrasadas atrasadas',
          (false, 1) => '1 entrega atrasada',
          (false, _) => '$atrasadas entregas atrasadas',
        },
    ];
    return '${partes.join(' e ')}!';
  }

  /// "Vestido Rosa (Ana) e Calça Social (Pedro)", atrasados primeiro.
  String get textoAviso => Texto.listar([
    for (final p in [...atrasados, ...paraHoje])
      '${p.nome} (${Texto.primeiroNome(p.clienteNome)})',
  ]);

  /// Pendente: quando foi cadastrado; finalizado: quando foi entregue.
  static DateTime _movimentadoEm(Pedido p) =>
      p.finalizado ? (p.dataFinalizacao ?? p.criadoEm) : p.criadoEm;

  @override
  List<Object?> get props => [
    pedidosEmAberto,
    pecasFinalizadasNoMes,
    totalMesCentavos,
    atrasados,
    paraHoje,
    recentes,
  ];
}

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeCarregando extends HomeState {
  const HomeCarregando();
}

final class HomeSucesso extends HomeState {
  const HomeSucesso(this.resumo);

  final ResumoHome resumo;

  @override
  List<Object?> get props => [resumo];
}

final class HomeErro extends HomeState {
  const HomeErro(this.mensagem);

  final String mensagem;

  @override
  List<Object?> get props => [mensagem];
}
