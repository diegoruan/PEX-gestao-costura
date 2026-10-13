import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../features/pedidos/data/pedido_repository.dart';
import '../../features/pedidos/domain/pedido.dart';
import 'icone_svg.dart';

/// Foto do pedido. Sem foto (ou enquanto ela carrega, ou se falhar), mostra
/// a camiseta do Figma sobre o fundo bege. Usada em pedidos e no histórico.
///
/// Lê a imagem direto do [PedidoRepository] em vez de passar pelo bloc: é só
/// leitura de exibição, e o repository já guarda as fotos lidas em cache.
class FotoPedido extends StatefulWidget {
  const FotoPedido({
    super.key,
    required this.pedido,
    required this.tamanhoIcone,
    this.iconeGrande = false,
  });

  final Pedido pedido;
  final double tamanhoIcone;

  /// O detalhe usa a versão de traço mais fino, desenhada para 100px.
  final bool iconeGrande;

  @override
  State<FotoPedido> createState() => _FotoPedidoState();
}

class _FotoPedidoState extends State<FotoPedido> {
  late Future<Uint8List?> _foto;

  // Em initState e não no build: o provider não permite context.read
  // durante o build.
  @override
  void initState() {
    super.initState();
    _foto = _carregar();
  }

  @override
  void didUpdateWidget(FotoPedido anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.pedido.id != widget.pedido.id ||
        anterior.pedido.fotoVersao != widget.pedido.fotoVersao) {
      _foto = _carregar();
    }
  }

  Future<Uint8List?> _carregar() =>
      context.read<PedidoRepository>().carregarFoto(widget.pedido);

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: AppColors.begeEscuro,
      child: Center(
        child: IconeSvg(
          widget.iconeGrande
              ? AppAssets.iconeCamisetaGrande
              : AppAssets.iconeCamiseta,
          tamanho: widget.tamanhoIcone,
        ),
      ),
    );
    if (!widget.pedido.temFoto) return placeholder;

    return FutureBuilder(
      future: _foto,
      builder: (context, snapshot) => switch (snapshot.data) {
        final bytes? => Image.memory(
          bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => placeholder,
        ),
        null => placeholder,
      },
    );
  }
}
