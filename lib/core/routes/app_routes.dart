/// Nomes e caminhos das rotas. Navegue sempre pelo nome:
/// `context.goNamed(AppRoutes.home)` ou `context.pushNamed(AppRoutes.cadastro)`.
abstract final class AppRoutes {
  static const splash = 'splash';
  static const login = 'login';
  static const cadastro = 'cadastro';
  static const recuperarSenha = 'recuperar-senha';
  static const home = 'home';

  static const splashPath = '/splash';
  static const loginPath = '/login';
  static const cadastroPath = '/cadastro';
  static const recuperarSenhaPath = '/recuperar-senha';
  static const homePath = '/';

  /// Rotas acessíveis sem estar logado.
  static const publicas = {loginPath, cadastroPath, recuperarSenhaPath};
}
