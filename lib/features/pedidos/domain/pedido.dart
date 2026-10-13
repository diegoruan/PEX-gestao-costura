import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum StatusPedido { pendente, finalizado }

/// Em que ponto do prazo o pedido está, olhando para a data de entrega.
enum PrazoPedido { atrasado, hoje, estaSemana, depois }

class Pedido extends Equatable {
  const Pedido({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.nome,
    required this.valorUnitarioCentavos,
    required this.quantidade,
    required this.dataEntrega,
    this.observacoes,
    this.fotoVersao,
    this.status = StatusPedido.pendente,
    this.dataFinalizacao,
    required this.criadoEm,
  });

  final String id;
  final String clienteId;

  /// Cópia do nome no momento do cadastro: o cliente pode ser renomeado ou
  /// excluído depois, e o histórico e o fechamento precisam do nome original.
  final String clienteNome;
  final String nome;

  /// Dinheiro sempre em centavos (int) para as somas do fechamento serem
  /// exatas; `double` acumularia erros de arredondamento.
  final int valorUnitarioCentavos;
  final int quantidade;

  /// Só a data importa (meia-noite no horário local).
  final DateTime dataEntrega;
  final String? observacoes;

  /// Identifica a foto atual da peça (ela fica num documento separado, lido
  /// pelo PedidoRepository). `null` quando o pedido não tem foto. Muda a cada
  /// troca de foto, para nenhum cache mostrar a antiga.
  final int? fotoVersao;
  final StatusPedido status;

  /// Preenchida quando o pedido é finalizado; é a data que o fechamento
  /// mensal usa para decidir em que mês o pedido entra.
  final DateTime? dataFinalizacao;
  final DateTime criadoEm;

  int get totalCentavos => valorUnitarioCentavos * quantidade;

  bool get temFoto => fotoVersao != null;

  bool get finalizado => status == StatusPedido.finalizado;

  PrazoPedido prazo(DateTime agora) {
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final entrega = DateTime(
      dataEntrega.year,
      dataEntrega.month,
      dataEntrega.day,
    );
    final dias = entrega.difference(hoje).inDays;
    if (dias < 0) return PrazoPedido.atrasado;
    if (dias == 0) return PrazoPedido.hoje;
    if (dias <= 7) return PrazoPedido.estaSemana;
    return PrazoPedido.depois;
  }

  /// Entrega mais próxima primeiro (ordem da lista de pendentes).
  static int compararPorEntrega(Pedido a, Pedido b) {
    final porData = a.dataEntrega.compareTo(b.dataEntrega);
    return porData != 0 ? porData : a.criadoEm.compareTo(b.criadoEm);
  }

  /// Finalizado mais recente primeiro (ordem do histórico).
  static int compararPorFinalizacao(Pedido a, Pedido b) {
    final fimA = a.dataFinalizacao ?? a.criadoEm;
    final fimB = b.dataFinalizacao ?? b.criadoEm;
    return fimB.compareTo(fimA);
  }

  factory Pedido.fromMap(String id, Map<String, dynamic> map) {
    return Pedido(
      id: id,
      clienteId: map['clienteId'] as String? ?? '',
      clienteNome: map['clienteNome'] as String? ?? '',
      nome: map['nome'] as String? ?? '',
      valorUnitarioCentavos:
          (map['valorUnitarioCentavos'] as num?)?.toInt() ?? 0,
      quantidade: (map['quantidade'] as num?)?.toInt() ?? 1,
      dataEntrega: _data(map['dataEntrega']) ?? DateTime.now(),
      observacoes: map['observacoes'] as String?,
      fotoVersao: (map['fotoVersao'] as num?)?.toInt(),
      status:
          StatusPedido.values.asNameMap()[map['status']] ??
          StatusPedido.pendente,
      dataFinalizacao: _data(map['dataFinalizacao']),
      criadoEm: _data(map['criadoEm']) ?? DateTime.now(),
    );
  }

  /// O `id` fica fora do mapa porque é o próprio id do documento.
  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'nome': nome,
      'valorUnitarioCentavos': valorUnitarioCentavos,
      'quantidade': quantidade,
      'dataEntrega': Timestamp.fromDate(dataEntrega),
      'observacoes': observacoes,
      'fotoVersao': fotoVersao,
      'status': status.name,
      'dataFinalizacao': dataFinalizacao == null
          ? null
          : Timestamp.fromDate(dataFinalizacao!),
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }

  /// Nos campos opcionais, passe uma função para poder limpar o valor:
  /// `pedido.copyWith(fotoVersao: () => null)`.
  Pedido copyWith({
    String? clienteId,
    String? clienteNome,
    String? nome,
    int? valorUnitarioCentavos,
    int? quantidade,
    DateTime? dataEntrega,
    String? Function()? observacoes,
    int? Function()? fotoVersao,
    StatusPedido? status,
    DateTime? Function()? dataFinalizacao,
  }) {
    return Pedido(
      id: id,
      clienteId: clienteId ?? this.clienteId,
      clienteNome: clienteNome ?? this.clienteNome,
      nome: nome ?? this.nome,
      valorUnitarioCentavos:
          valorUnitarioCentavos ?? this.valorUnitarioCentavos,
      quantidade: quantidade ?? this.quantidade,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      observacoes: observacoes != null ? observacoes() : this.observacoes,
      fotoVersao: fotoVersao != null ? fotoVersao() : this.fotoVersao,
      status: status ?? this.status,
      dataFinalizacao: dataFinalizacao != null
          ? dataFinalizacao()
          : this.dataFinalizacao,
      criadoEm: criadoEm,
    );
  }

  static DateTime? _data(Object? valor) => (valor as Timestamp?)?.toDate();

  @override
  List<Object?> get props => [
    id,
    clienteId,
    clienteNome,
    nome,
    valorUnitarioCentavos,
    quantidade,
    dataEntrega,
    observacoes,
    fotoVersao,
    status,
    dataFinalizacao,
    criadoEm,
  ];
}
