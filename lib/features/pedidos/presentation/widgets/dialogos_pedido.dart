import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/avatar_iniciais.dart';
import '../../../clientes/domain/cliente.dart';

enum RespostaFalhaFoto { tentarDeNovo, salvarSemFoto }

/// Quando só o envio da foto falhou: tentar de novo ou salvar sem ela.
/// Fechar o diálogo devolve `null` (a pessoa continua no formulário).
Future<RespostaFalhaFoto?> perguntarFalhaFoto(
  BuildContext context,
  String mensagem,
) {
  return showDialog<RespostaFalhaFoto>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medio),
      ),
      title: const Text(
        'A foto não foi salva',
        style: AppTextStyles.tituloPagina,
      ),
      content: Text(mensagem, style: AppTextStyles.corpo),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(RespostaFalhaFoto.salvarSemFoto),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textoSecundario,
          ),
          child: const Text('Salvar sem foto'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(RespostaFalhaFoto.tentarDeNovo),
          child: const Text('Tentar de novo'),
        ),
      ],
    ),
  );
}

/// Lista os clientes ativos numa folha de baixo e devolve o escolhido.
Future<Cliente?> escolherCliente(
  BuildContext context, {
  required List<Cliente> clientes,
  String? selecionadoId,
}) {
  return showModalBottomSheet<Cliente>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.superficie,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.folha),
      ),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Text('Escolha o cliente', style: AppTextStyles.tituloPagina),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              itemCount: clientes.length,
              itemBuilder: (context, i) {
                final cliente = clientes[i];
                final selecionado = cliente.id == selecionadoId;
                return ListTile(
                  leading: AvatarIniciais(
                    nome: cliente.nomeExibicao,
                    compacto: true,
                  ),
                  title: Text(
                    cliente.nomeComApelido,
                    style: AppTextStyles.tituloItem,
                  ),
                  trailing: selecionado
                      ? const Icon(AppIcons.check, color: AppColors.primaria)
                      : null,
                  onTap: () => Navigator.of(context).pop(cliente),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
