import 'package:firebase_auth/firebase_auth.dart';

import 'usuario.dart';

/// Erro de autenticação já traduzido para exibir ao usuário.
class AuthFalha implements Exception {
  const AuthFalha(this.mensagem);

  final String mensagem;

  @override
  String toString() => 'AuthFalha: $mensagem';
}

/// Único ponto do app que conversa com o Firebase Authentication.
class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  /// Emite o usuário logado (ou `null`) sempre que a sessão muda. O Firebase
  /// persiste a sessão no dispositivo, então ao reabrir o app o primeiro valor
  /// já é o usuário logado.
  Stream<Usuario?> get usuarioAtual =>
      _firebaseAuth.authStateChanges().map(_paraUsuario);

  Future<Usuario> entrar({required String email, required String senha}) {
    return _executar(() async {
      final credencial = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      return _paraUsuario(credencial.user)!;
    });
  }

  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) {
    return _executar(() async {
      final credencial = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      final user = credencial.user!;
      await user.updateDisplayName(nome.trim());
      // Monta o Usuario com o nome informado em vez de reler o `user`.
      return Usuario(
        id: user.uid,
        email: user.email ?? email,
        nome: nome.trim(),
      );
    });
  }

  Future<void> recuperarSenha({required String email}) {
    return _executar(
      () => _firebaseAuth.sendPasswordResetEmail(email: email.trim()),
    );
  }

  Future<void> sair() => _firebaseAuth.signOut();

  Usuario? _paraUsuario(User? user) {
    if (user == null) return null;
    return Usuario(
      id: user.uid,
      email: user.email ?? '',
      nome: user.displayName,
    );
  }

  Future<T> _executar<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on FirebaseAuthException catch (e) {
      throw AuthFalha(traduzirErro(e.code));
    } catch (_) {
      throw const AuthFalha(mensagemErroGenerico);
    }
  }

  static const mensagemErroGenerico =
      'Algo deu errado. Tente novamente em instantes.';

  static String traduzirErro(String codigo) {
    return switch (codigo) {
      'email-already-in-use' => 'Este e-mail já está cadastrado.',
      'invalid-email' => 'O e-mail informado é inválido.',
      'weak-password' => 'Senha fraca. Use pelo menos 6 caracteres.',
      'user-not-found' => 'Não encontramos uma conta com este e-mail.',
      'wrong-password' => 'Senha incorreta.',
      'invalid-credential' ||
      'INVALID_LOGIN_CREDENTIALS' => 'E-mail ou senha incorretos.',
      'user-disabled' => 'Esta conta foi desativada.',
      'too-many-requests' =>
        'Muitas tentativas seguidas. Aguarde alguns minutos e tente de novo.',
      'network-request-failed' =>
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      'operation-not-allowed' =>
        'Login por e-mail e senha não está habilitado no Firebase.',
      'missing-email' => 'Informe seu e-mail.',
      _ => mensagemErroGenerico,
    };
  }
}
