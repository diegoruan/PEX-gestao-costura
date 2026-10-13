import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/barra_navegacao.dart';
import '../theme/app_assets.dart';

/// Ordem igual à dos branches do StatefulShellRoute em app_router.dart.
abstract final class AbasNavegacao {
  static const inicio = 0;
  static const pedidos = 1;
  static const clientes = 2;
  static const historico = 3;
  static const fechamento = 4;

  static const itens = [
    ItemNavegacao(icone: AppAssets.iconeCasa, rotulo: 'Início'),
    ItemNavegacao(icone: AppAssets.iconeCalendario, rotulo: 'Pedidos'),
    ItemNavegacao(icone: AppAssets.iconePessoas, rotulo: 'Clientes'),
    ItemNavegacao(icone: AppAssets.iconeDocumento, rotulo: 'Histórico'),
    ItemNavegacao(icone: AppAssets.iconeGrafico, rotulo: 'Fechamento'),
  ];
}

/// Telas principais com a barra inferior. Cada aba tem a sua pilha
/// (indexedStack), então trocar de aba não perde rolagem nem filtros.
class NavegacaoShell extends StatelessWidget {
  const NavegacaoShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final naInicio = shell.currentIndex == AbasNavegacao.inicio;

    // Voltar do Android: fora da Home, volta para a Home; na Home, sai do app.
    return PopScope(
      canPop: naInicio,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(AbasNavegacao.inicio);
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: BarraNavegacao(
          itens: AbasNavegacao.itens,
          indiceAtual: shell.currentIndex,
          // Tocar na aba que já está ativa volta para a raiz dela.
          onSelecionar: (indice) => shell.goBranch(
            indice,
            initialLocation: indice == shell.currentIndex,
          ),
        ),
      ),
    );
  }
}
