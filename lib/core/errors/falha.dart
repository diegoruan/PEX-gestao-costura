import 'package:firebase_core/firebase_core.dart';

/// Erro já traduzido para exibir ao usuário. Os repositories do Firestore
/// lançam `Falha` e os BLoCs só repassam a [mensagem] para a tela.
class Falha implements Exception {
  const Falha(this.mensagem);

  factory Falha.firestore(FirebaseException e) =>
      Falha(traduzirErroFirestore(e.code));

  final String mensagem;

  static const mensagemGenerica =
      'Algo deu errado. Tente novamente em instantes.';

  static const sessaoExpirada = Falha('Sua sessão expirou. Entre novamente.');

  static String traduzirErroFirestore(String codigo) {
    return switch (codigo) {
      'permission-denied' => 'Você não tem permissão para acessar estes dados.',
      'unauthenticated' => sessaoExpirada.mensagem,
      'unavailable' =>
        'Sem conexão com o servidor. Verifique sua internet e tente de novo.',
      'deadline-exceeded' =>
        'O servidor demorou para responder. Tente de novo.',
      'not-found' => 'Registro não encontrado.',
      _ => mensagemGenerica,
    };
  }

  @override
  String toString() => 'Falha: $mensagem';
}

/// O envio da foto falhou, mas o resto dos dados está intacto: a tela pode
/// oferecer "tentar de novo" ou "salvar sem foto".
class FalhaEnvioFoto extends Falha {
  const FalhaEnvioFoto([
    super.mensagem =
        'Não foi possível enviar a foto. Verifique sua internet e tente de '
        'novo, ou salve o pedido sem foto.',
  ]);
}
