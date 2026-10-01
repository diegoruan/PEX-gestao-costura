import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Cliente extends Equatable {
  const Cliente({
    required this.id,
    required this.nome,
    this.apelido,
    this.telefone,
    this.email,
    this.endereco,
    this.observacoes,
    this.ativo = true,
    required this.criadoEm,
  });

  final String id;
  final String nome;
  final String? apelido;
  final String? telefone;
  final String? email;
  final String? endereco;
  final String? observacoes;

  /// Exclusão lógica: pedidos e fechamentos antigos continuam apontando para
  /// este documento, então ele nunca é apagado de verdade.
  final bool ativo;
  final DateTime criadoEm;

  /// Como o cliente aparece na lista: o apelido, quando houver.
  String get nomeExibicao => apelido ?? nome;

  /// Como o cliente aparece no detalhe: "Nome (Apelido)".
  String get nomeComApelido => apelido == null ? nome : '$nome ($apelido)';

  factory Cliente.fromMap(String id, Map<String, dynamic> map) {
    return Cliente(
      id: id,
      nome: map['nome'] as String? ?? '',
      apelido: map['apelido'] as String?,
      telefone: map['telefone'] as String?,
      email: map['email'] as String?,
      endereco: map['endereco'] as String?,
      observacoes: map['observacoes'] as String?,
      ativo: map['ativo'] as bool? ?? true,
      criadoEm: (map['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// O `id` fica fora do mapa porque é o próprio id do documento.
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'apelido': apelido,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'observacoes': observacoes,
      'ativo': ativo,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }

  /// Nos campos opcionais, passe uma função para poder limpar o valor:
  /// `cliente.copyWith(telefone: () => null)`.
  Cliente copyWith({
    String? nome,
    String? Function()? apelido,
    String? Function()? telefone,
    String? Function()? email,
    String? Function()? endereco,
    String? Function()? observacoes,
    bool? ativo,
  }) {
    return Cliente(
      id: id,
      nome: nome ?? this.nome,
      apelido: apelido != null ? apelido() : this.apelido,
      telefone: telefone != null ? telefone() : this.telefone,
      email: email != null ? email() : this.email,
      endereco: endereco != null ? endereco() : this.endereco,
      observacoes: observacoes != null ? observacoes() : this.observacoes,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nome,
    apelido,
    telefone,
    email,
    endereco,
    observacoes,
    ativo,
    criadoEm,
  ];
}
