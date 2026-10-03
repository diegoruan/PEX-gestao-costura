import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/services/imagem_service.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/icone_svg.dart';
import '../../../../shared/widgets/indicador_carregando.dart';
import 'foto_pedido.dart';

/// Quadrado de 80px do formulário: tracejado com "Adicionar" ou a foto
/// escolhida (nova, em memória, ou a que já está salva).
class SeletorFoto extends StatelessWidget {
  const SeletorFoto({
    super.key,
    required this.fotoNova,
    required this.fotoUrl,
    required this.carregando,
    required this.onTap,
  });

  final Uint8List? fotoNova;
  final String? fotoUrl;
  final bool carregando;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final temFoto = fotoNova != null || fotoUrl != null;
    final Widget conteudo;
    if (carregando) {
      conteudo = const Center(
        child: IndicadorCarregando(tamanho: AppSizes.indicadorBotao),
      );
    } else if (fotoNova case final bytes?) {
      conteudo = Image.memory(bytes, fit: BoxFit.cover);
    } else if (fotoUrl != null) {
      conteudo = FotoPedido(
        url: fotoUrl,
        tamanhoIcone: AppSizes.iconeMiniatura,
      );
    } else {
      conteudo = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppSpacing.xsm,
        children: [
          IconeSvg(
            AppAssets.iconeCamera,
            tamanho: AppSizes.iconeFotoFormulario,
          ),
          Text('Adicionar', style: AppTextStyles.legendaPequena),
        ],
      );
    }

    return Semantics(
      button: true,
      label: temFoto ? 'Trocar foto da peça' : 'Adicionar foto da peça',
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          foregroundPainter: temFoto && !carregando
              ? null
              : const _BordaTracejada(),
          child: Container(
            width: AppSizes.fotoFormulario,
            height: AppSizes.fotoFormulario,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.superficie,
              borderRadius: BorderRadius.circular(AppRadius.item),
            ),
            child: conteudo,
          ),
        ),
      ),
    );
  }
}

/// O Flutter não tem borda tracejada pronta; desenhamos o contorno
/// arredondado em pedaços.
class _BordaTracejada extends CustomPainter {
  const _BordaTracejada();

  @override
  void paint(Canvas canvas, Size size) {
    const largura = AppSizes.bordaTracejada;
    final contorno = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(largura / 2),
          const Radius.circular(AppRadius.item),
        ),
      );
    final pincel = Paint()
      ..color = AppColors.begeEscuro
      ..style = PaintingStyle.stroke
      ..strokeWidth = largura;

    for (final metrica in contorno.computeMetrics()) {
      for (var d = 0.0; d < metrica.length; d += AppSizes.tracoBorda * 2) {
        canvas.drawPath(
          metrica.extractPath(d, d + AppSizes.tracoBorda),
          pincel,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BordaTracejada oldDelegate) => false;
}

enum EscolhaFoto { camera, galeria, remover }

extension EscolhaFotoOrigem on EscolhaFoto {
  OrigemImagem? get origem => switch (this) {
    EscolhaFoto.camera => OrigemImagem.camera,
    EscolhaFoto.galeria => OrigemImagem.galeria,
    EscolhaFoto.remover => null,
  };
}

/// Folha de baixo com "Tirar foto", "Escolher da galeria" e, se já houver
/// foto, "Remover foto".
Future<EscolhaFoto?> perguntarOrigemFoto(
  BuildContext context, {
  required bool temFoto,
}) {
  return showModalBottomSheet<EscolhaFoto>(
    context: context,
    backgroundColor: AppColors.superficie,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.folha),
      ),
    ),
    builder: (context) {
      Widget opcao(EscolhaFoto escolha, IconData icone, String texto) {
        final cor = escolha == EscolhaFoto.remover
            ? AppColors.erro
            : AppColors.textoPrincipal;
        return ListTile(
          leading: Icon(icone, color: cor),
          title: Text(texto, style: AppTextStyles.corpo.copyWith(color: cor)),
          onTap: () => Navigator.of(context).pop(escolha),
        );
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              opcao(
                EscolhaFoto.camera,
                Icons.photo_camera_outlined,
                'Tirar foto',
              ),
              opcao(
                EscolhaFoto.galeria,
                Icons.photo_library_outlined,
                'Escolher da galeria',
              ),
              if (temFoto)
                opcao(
                  EscolhaFoto.remover,
                  Icons.delete_outline,
                  'Remover foto',
                ),
            ],
          ),
        ),
      );
    },
  );
}
