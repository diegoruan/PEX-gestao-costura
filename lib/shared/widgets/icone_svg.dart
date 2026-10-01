import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ícone SVG exportado do Figma (constantes em `AppAssets`). Passe [cor] para
/// recolorir; sem ela, mantém a cor original do arquivo.
class IconeSvg extends StatelessWidget {
  const IconeSvg(this.asset, {super.key, required this.tamanho, this.cor});

  final String asset;
  final double tamanho;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: tamanho,
      height: tamanho,
      colorFilter: cor == null ? null : ColorFilter.mode(cor!, BlendMode.srcIn),
    );
  }
}
