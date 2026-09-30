import 'package:equatable/equatable.dart';

/// Usuário do app, independente do Firebase. O BLoC e as telas só conhecem
/// esta classe, o que também deixa os testes livres de mocks do Firebase.
class Usuario extends Equatable {
  const Usuario({required this.id, required this.email, this.nome});

  final String id;
  final String email;
  final String? nome;

  /// Nome para exibição; cai para o início do e-mail se o nome não existir.
  String get nomeExibicao {
    final nome = this.nome?.trim();
    if (nome != null && nome.isNotEmpty) return nome;
    return email.split('@').first;
  }

  @override
  List<Object?> get props => [id, email, nome];
}
