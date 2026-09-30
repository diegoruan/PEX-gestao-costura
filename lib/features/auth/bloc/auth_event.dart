import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Disparado uma vez no app.dart para começar a escutar a sessão do Firebase.
final class AuthIniciado extends AuthEvent {
  const AuthIniciado();
}

final class AuthLoginSolicitado extends AuthEvent {
  const AuthLoginSolicitado({required this.email, required this.senha});

  final String email;
  final String senha;

  @override
  List<Object?> get props => [email, senha];
}

final class AuthCadastroSolicitado extends AuthEvent {
  const AuthCadastroSolicitado({
    required this.nome,
    required this.email,
    required this.senha,
  });

  final String nome;
  final String email;
  final String senha;

  @override
  List<Object?> get props => [nome, email, senha];
}

final class AuthRecuperacaoSenhaSolicitada extends AuthEvent {
  const AuthRecuperacaoSenhaSolicitada({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

final class AuthLogoutSolicitado extends AuthEvent {
  const AuthLogoutSolicitado();
}
