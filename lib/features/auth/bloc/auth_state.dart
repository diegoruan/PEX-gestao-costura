import 'package:equatable/equatable.dart';

import '../data/usuario.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInicial extends AuthState {
  const AuthInicial();
}

final class AuthCarregando extends AuthState {
  const AuthCarregando();
}

final class AuthAutenticado extends AuthState {
  const AuthAutenticado(this.usuario);

  final Usuario usuario;

  @override
  List<Object?> get props => [usuario];
}

final class AuthNaoAutenticado extends AuthState {
  const AuthNaoAutenticado();
}

final class AuthErro extends AuthState {
  const AuthErro(this.mensagem);

  final String mensagem;

  @override
  List<Object?> get props => [mensagem];
}

/// O e-mail de redefinição foi enviado; o usuário continua deslogado.
final class AuthRecuperacaoEnviada extends AuthState {
  const AuthRecuperacaoEnviada(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}
