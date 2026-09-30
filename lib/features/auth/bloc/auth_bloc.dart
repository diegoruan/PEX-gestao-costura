import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this._authRepository}) : super(const AuthInicial()) {
    on<AuthIniciado>(_onIniciado);
    on<AuthLoginSolicitado>(_onLoginSolicitado);
    on<AuthCadastroSolicitado>(_onCadastroSolicitado);
    on<AuthRecuperacaoSenhaSolicitada>(_onRecuperacaoSenhaSolicitada);
    on<AuthLogoutSolicitado>(_onLogoutSolicitado);
  }

  final AuthRepository _authRepository;

  /// Fica ativo enquanto o bloc existir, mantendo o estado em sincronia com a
  /// sessão do Firebase (inclusive ao reabrir o app ou se o token expirar).
  Future<void> _onIniciado(AuthIniciado event, Emitter<AuthState> emit) {
    return emit.forEach(
      _authRepository.usuarioAtual,
      onData: (usuario) => usuario == null
          ? const AuthNaoAutenticado()
          : AuthAutenticado(usuario),
    );
  }

  Future<void> _onLoginSolicitado(
    AuthLoginSolicitado event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCarregando());
    try {
      final usuario = await _authRepository.entrar(
        email: event.email,
        senha: event.senha,
      );
      emit(AuthAutenticado(usuario));
    } on AuthFalha catch (e) {
      emit(AuthErro(e.mensagem));
    }
  }

  Future<void> _onCadastroSolicitado(
    AuthCadastroSolicitado event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCarregando());
    try {
      final usuario = await _authRepository.cadastrar(
        nome: event.nome,
        email: event.email,
        senha: event.senha,
      );
      emit(AuthAutenticado(usuario));
    } on AuthFalha catch (e) {
      emit(AuthErro(e.mensagem));
    }
  }

  Future<void> _onRecuperacaoSenhaSolicitada(
    AuthRecuperacaoSenhaSolicitada event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCarregando());
    try {
      await _authRepository.recuperarSenha(email: event.email);
      emit(AuthRecuperacaoEnviada(event.email));
    } on AuthFalha catch (e) {
      emit(AuthErro(e.mensagem));
    }
  }

  Future<void> _onLogoutSolicitado(
    AuthLogoutSolicitado event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.sair();
    emit(const AuthNaoAutenticado());
  }
}
