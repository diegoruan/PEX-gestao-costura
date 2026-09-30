import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Cliente extends Equatable {
  const Cliente({
    required this.id,
    required this.nome,
    this.telefone,
    this.observacoes,
    this.ativo = true,
    required this.criadoEm,
  });

  final String id;
  final String nome;
  final String? telefone;
  final String? observacoes;

  /// Exclusão lógica: pedidos e fechamentos antigos continuam apontando para
  /// este documento, então ele nunca é apagado de verdade.
  final bool ativo;
  final DateTime criadoEm;

  factory Cliente.fromMap(String id, Map<String, dynamic> map) {
    return Cliente(
      id: id,
      nome: map['nome'] as String? ?? '',
      telefone: map['telefone'] as String?,
      observacoes: map['observacoes'] as String?,
      ativo: map['ativo'] as bool? ?? true,
      criadoEm: (map['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// O `id` fica fora do mapa porque é o próprio id do documento.
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'telefone': telefone,
      'observacoes': observacoes,
      'ativo': ativo,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }

  /// Nos campos opcionais, passe uma função para poder limpar o valor:
  /// `cliente.copyWith(telefone: () => null)`.
  Cliente copyWith({
    String? nome,
    String? Function()? telefone,
    String? Function()? observacoes,
    bool? ativo,
  }) {
    return Cliente(
      id: id,
      nome: nome ?? this.nome,
      telefone: telefone != null ? telefone() : this.telefone,
      observacoes: observacoes != null ? observacoes() : this.observacoes,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm,
    );
  }

  @override
  List<Object?> get props => [id, nome, telefone, observacoes, ativo, criadoEm];
}
