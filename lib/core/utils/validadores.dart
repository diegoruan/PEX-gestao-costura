/// Validadores prontos para o `validator:` de um TextFormField.
abstract final class Validadores {
  static const tamanhoMinimoSenha = 6;

  static final _regexEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _regexTelefone = RegExp(r'^\+?[\d\s().-]+$');

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

  static String? nome(String? valor) {
    final nome = valor?.trim() ?? '';
    if (nome.isEmpty) return 'Informe o nome';
    if (nome.length < 2) return 'O nome deve ter pelo menos 2 letras';
    return null;
  }

  /// Opcional. Aceita "(11) 9 8765-4321", "11987654321", "+55 11 98765-4321"...
  static String? telefoneOpcional(String? valor) {
    final telefone = valor?.trim() ?? '';
    if (telefone.isEmpty) return null;
    if (!_regexTelefone.hasMatch(telefone)) return 'Use só números, ( ) - e +';
    final digitos = telefone.replaceAll(RegExp(r'\D'), '').length;
    if (digitos < 8 || digitos > 13) return 'Telefone inválido';
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
