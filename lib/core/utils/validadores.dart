/// Validadores prontos para o `validator:` de um TextFormField.
abstract final class Validadores {
  static const tamanhoMinimoSenha = 6;

  static final _regexEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? obrigatorio(String? valor, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) return '$campo é obrigatório';
    return null;
  }

  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe seu e-mail';
    if (!_regexEmail.hasMatch(valor.trim())) return 'E-mail inválido';
    return null;
  }

  static String? senha(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe sua senha';
    if (valor.length < tamanhoMinimoSenha) {
      return 'A senha deve ter no mínimo $tamanhoMinimoSenha caracteres';
    }
    return null;
  }

  static String? Function(String?) confirmacaoSenha(String Function() senha) {
    return (valor) {
      if (valor == null || valor.isEmpty) return 'Confirme sua senha';
      if (valor != senha()) return 'As senhas não coincidem';
      return null;
    };
  }
}
