import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/icone_svg.dart';

/// Foto do pedido com cache em disco. Sem foto (ou se ela não carregar),
/// mostra a camiseta do Figma sobre o fundo bege.
class FotoPedido extends StatelessWidget {
  const FotoPedido({
    super.key,
    required this.url,
    required this.tamanhoIcone,
    this.iconeGrande = false,
  });

  final String? url;
  final double tamanhoIcone;

  /// O detalhe usa a versão de traço mais fino, desenhada para 100px.
  final bool iconeGrande;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: AppColors.begeEscuro,
      child: Center(
        child: IconeSvg(
          iconeGrande ? AppAssets.iconeCamisetaGrande : AppAssets.iconeCamiseta,
          tamanho: tamanhoIcone,
        ),
      ),
    );
    final url = this.url;
    if (url == null) return placeholder;

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );
  }
}
