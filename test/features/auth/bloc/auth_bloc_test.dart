import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pex_gestao_costura/features/auth/bloc/auth_bloc.dart';
import 'package:pex_gestao_costura/features/auth/data/auth_repository.dart';
import 'package:pex_gestao_costura/features/auth/data/usuario.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  const usuario = Usuario(id: 'uid-1', email: 'maria@email.com', nome: 'Maria');
  const email = 'maria@email.com';
  const senha = '123456';

  setUp(() {
    repository = MockAuthRepository();
  });

  AuthBloc criarBloc() => AuthBloc(authRepository: repository);

  test('estado inicial é AuthInicial', () {
    expect(criarBloc().state, const AuthInicial());
  });

  group('AuthIniciado (sessão persistente)', () {
    blocTest<AuthBloc, AuthState>(
      'emite AuthAutenticado quando já existe sessão salva',
      setUp: () =>
          when(() => repository.usuarioAtual)
              .thenAnswer((_) => Stream.value(usuario)),
      build: criarBloc,
      act: (bloc) => bloc.add(const AuthIniciado()),
      expect: () => const [AuthAutenticado(usuario)],
    );

    blocTest<AuthBloc, AuthState>(
      'acompanha as mudanças de sessão do Firebase',
      setUp: () =>
          when(() => repository.usuarioAtual)
              .thenAnswer((_) => Stream.fromIterable([null, usuario, null])),
      build: criarBloc,
      act: (bloc) => bloc.add(const AuthIniciado()),
      expect: () => const [
        AuthNaoAutenticado(),
        AuthAutenticado(usuario),
        AuthNaoAutenticado(),
      ],
    );
  });

  group('AuthLoginSolicitado', () {
    blocTest<AuthBloc, AuthState>(
      'emite [AuthCarregando, AuthAutenticado] quando o login dá certo',
      setUp: () =>
          when(() => repository.entrar(email: email, senha: senha))
              .thenAnswer((_) async => usuario),
      build: criarBloc,
      act: (bloc) =>
          bloc.add(const AuthLoginSolicitado(email: email, senha: senha)),
      expect: () => const [AuthCarregando(), AuthAutenticado(usuario)],
      verify: (_) =>
          verify(() => repository.entrar(email: email, senha: senha)).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'emite [AuthCarregando, AuthErro] com a mensagem traduzida quando falha',
      setUp: () =>
          when(() => repository.entrar(email: email, senha: senha))
              .thenThrow(const AuthFalha('E-mail ou senha incorretos.')),
      build: criarBloc,
      act: (bloc) =>
          bloc.add(const AuthLoginSolicitado(email: email, senha: senha)),
      expect: () => const [
        AuthCarregando(),
        AuthErro('E-mail ou senha incorretos.'),
      ],
    );
  });

  group('AuthCadastroSolicitado', () {
    blocTest<AuthBloc, AuthState>(
      'emite [AuthCarregando, AuthAutenticado] quando o cadastro dá certo',
      setUp: () => when(
        () => repository.cadastrar(nome: 'Maria', email: email, senha: senha),
      ).thenAnswer((_) async => usuario),
      build: criarBloc,
      act: (bloc) => bloc.add(
        const AuthCadastroSolicitado(nome: 'Maria', email: email, senha: senha),
      ),
      expect: () => const [AuthCarregando(), AuthAutenticado(usuario)],
    );

    blocTest<AuthBloc, AuthState>(
      'emite [AuthCarregando, AuthErro] quando o e-mail já está em uso',
      setUp: () => when(
        () => repository.cadastrar(nome: 'Maria', email: email, senha: senha),
      ).thenThrow(const AuthFalha('Este e-mail já está cadastrado.')),
      build: criarBloc,
      act: (bloc) => bloc.add(
        const AuthCadastroSolicitado(nome: 'Maria', email: email, senha: senha),
      ),
      expect: () => const [
        AuthCarregando(),
        AuthErro('Este e-mail já está cadastrado.'),
      ],
    );
  });

  group('AuthRecuperacaoSenhaSolicitada', () {
    blocTest<AuthBloc, AuthState>(
      'emite [AuthCarregando, AuthRecuperacaoEnviada] quando o e-mail é enviado',
      setUp: () =>
          when(() => repository.recuperarSenha(email: email))
              .thenAnswer((_) async {}),
      build: criarBloc,
      act: (bloc) =>
          bloc.add(const AuthRecuperacaoSenhaSolicitada(email: email)),
      expect: () => const [AuthCarregando(), AuthRecuperacaoEnviada(email)],
      verify: (_) =>
          verify(() => repository.recuperarSenha(email: email)).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'emite [AuthCarregando, AuthErro] quando não há conexão',
      setUp: () => when(() => repository.recuperarSenha(email: email))
          .thenThrow(
            AuthFalha(AuthRepository.traduzirErro('network-request-failed')),
          ),
      build: criarBloc,
      act: (bloc) =>
          bloc.add(const AuthRecuperacaoSenhaSolicitada(email: email)),
      expect: () => [
        const AuthCarregando(),
        AuthErro(AuthRepository.traduzirErro('network-request-failed')),
      ],
    );
  });

  group('AuthLogoutSolicitado', () {
    blocTest<AuthBloc, AuthState>(
      'chama sair() e emite AuthNaoAutenticado',
      setUp: () => when(() => repository.sair()).thenAnswer((_) async {}),
      build: criarBloc,
      seed: () => const AuthAutenticado(usuario),
      act: (bloc) => bloc.add(const AuthLogoutSolicitado()),
      expect: () => const [AuthNaoAutenticado()],
      verify: (_) => verify(() => repository.sair()).called(1),
    );
  });

  group('AuthRepository.traduzirErro', () {
    test('traduz os códigos mais comuns do Firebase', () {
      expect(
        AuthRepository.traduzirErro('email-already-in-use'),
        'Este e-mail já está cadastrado.',
      );
      expect(
        AuthRepository.traduzirErro('invalid-credential'),
        'E-mail ou senha incorretos.',
      );
      expect(
        AuthRepository.traduzirErro('codigo-desconhecido'),
        AuthRepository.mensagemErroGenerico,
      );
    });
  });
}
