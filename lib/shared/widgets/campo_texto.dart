import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// Campo com rótulo em caixa alta acima do texto. Feito para ficar dentro de
/// um [CartaoFormulario], que desenha o fundo e as divisórias.
class CampoTexto extends StatefulWidget {
  const CampoTexto({
    super.key,
    required this.rotulo,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.senha = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.minLines,
    this.maxLines = 1,
  }) : assert(!senha || maxLines == 1, 'Campo de senha tem uma linha só');

  final String rotulo;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final bool senha;
  final bool enabled;
  final TextCapitalization textCapitalization;

  /// Para textos longos (observações), use `minLines: 3, maxLines: null`.
  final int? minLines;
  final int? maxLines;

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  late bool _ocultarTexto = widget.senha;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.campo,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.rotulo.toUpperCase(), style: AppTextStyles.rotuloCampo),
          TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            onFieldSubmitted: widget.onFieldSubmitted,
            enabled: widget.enabled,
            obscureText: _ocultarTexto,
            textCapitalization: widget.textCapitalization,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            autocorrect: !widget.senha,
            enableSuggestions: !widget.senha,
            style: AppTextStyles.textoCampo,
            decoration: InputDecoration(
              hintText: widget.hint,
              suffixIconConstraints: const BoxConstraints(),
              suffixIcon: widget.senha ? _botaoVisibilidade() : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoVisibilidade() {
    return GestureDetector(
      onTap: () => setState(() => _ocultarTexto = !_ocultarTexto),
      child: Semantics(
        button: true,
        label: _ocultarTexto ? 'Mostrar senha' : 'Ocultar senha',
        child: Icon(
          _ocultarTexto
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: AppSizes.iconeCampo,
          color: AppColors.placeholder,
        ),
      ),
    );
  }
}
