import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/avatar_iniciais.dart';
import '../../../../shared/widgets/cartao_item_lista.dart';
import '../../../../shared/widgets/icone_svg.dart';
import '../../domain/cliente.dart';

class ClienteCard extends StatelessWidget {
  const ClienteCard({super.key, required this.cliente, required this.onTap});

  final Cliente cliente;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final telefone = cliente.telefone;
    return CartaoItemLista(
      inicio: AvatarIniciais(nome: cliente.nome),
      titulo: cliente.nome,
      onTap: onTap,
      conteudo: telefone == null
          ? null
          : Row(
              spacing: AppSpacing.xs,
              children: [
                const IconeSvg(
                  AppAssets.iconeTelefone,
                  tamanho: AppSizes.iconeMinimo,
                ),
                Text(telefone, style: AppTextStyles.legenda),
              ],
            ),
    );
  }
}
