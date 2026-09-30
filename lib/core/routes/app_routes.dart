/// Nomes e caminhos das rotas. Navegue sempre pelo nome:
/// `context.goNamed(AppRoutes.home)` ou `context.pushNamed(AppRoutes.cadastro)`.
abstract final class AppRoutes {
  static const splash = 'splash';
  static const login = 'login';
  static const cadastro = 'cadastro';
  static const recuperarSenha = 'recuperar-senha';
  static const home = 'home';

  static const clientes = 'clientes';
  static const clienteNovo = 'cliente-novo';
  static const clienteDetalhe = 'cliente-detalhe';
  static const clienteEditar = 'cliente-editar';

  static const splashPath = '/splash';
  static const loginPath = '/login';
  static const cadastroPath = '/cadastro';
  static const recuperarSenhaPath = '/recuperar-senha';
  static const homePath = '/';

  /// /clientes, /clientes/novo, /clientes/:id e /clientes/:id/editar.
  /// Os caminhos filhos são relativos ao pai no go_router.
  static const clientesPath = '/clientes';
  static const clienteNovoPath = 'novo';
  static const clienteDetalhePath = ':$paramId';
  static const clienteEditarPath = 'editar';

  /// Uso: `context.pushNamed(AppRoutes.clienteDetalhe,
  /// pathParameters: {AppRoutes.paramId: cliente.id})`.
  static const paramId = 'id';

  /// Rotas acessíveis sem estar logado.
  static const publicas = {loginPath, cadastroPath, recuperarSenhaPath};
}
