import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Máscara de dinheiro para campos de texto: a pessoa digita só números e o
/// campo preenche da direita para a esquerda ("1" -> "0,01", "12345" ->
/// "123,45"). Use [centavos] para ler o valor sem passar por `double`.
class MoedaInputFormatter extends TextInputFormatter {
  static final _formato = NumberFormat('#,##0.00', 'pt_BR');

  /// Até R$ 9.999.999,99; evita estourar o campo com dígitos sem fim.
  static const maximoDigitos = 9;

  static String formatar(int centavos) => _formato.format(centavos / 100);

  /// "1.234,56" -> 123456. Texto vazio ou sem dígitos -> 0.
  static int centavos(String texto) {
    final digitos = texto.replaceAll(RegExp(r'\D'), '');
    return digitos.isEmpty ? 0 : int.parse(digitos);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.isEmpty) return TextEditingValue.empty;
    if (digitos.length > maximoDigitos) return oldValue;

    final texto = formatar(int.parse(digitos));
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
