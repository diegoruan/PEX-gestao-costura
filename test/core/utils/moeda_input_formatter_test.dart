import 'package:flutter_test/flutter_test.dart';
import 'package:pex_gestao_costura/core/utils/moeda_input_formatter.dart';

void main() {
  final formatter = MoedaInputFormatter();

  String digitar(String texto, {String anterior = ''}) => formatter
      .formatEditUpdate(
        TextEditingValue(text: anterior),
        TextEditingValue(text: texto),
      )
      .text;

  test('preenche da direita para a esquerda', () {
    expect(digitar('1'), '0,01');
    expect(digitar('12'), '0,12');
    expect(digitar('9000'), '90,00');
    expect(digitar('123456'), '1.234,56');
  });

  test('ignora o que não é dígito e reformata ao apagar', () {
    // Apagar o último dígito de "90,00" desloca tudo para a direita.
    expect(digitar('90,0', anterior: '90,00'), '9,00');
    expect(digitar('R\$ 1a2'), '0,12');
  });

  test('campo vazio continua vazio', () {
    expect(digitar(''), '');
  });

  test('não passa do limite de dígitos', () {
    expect(digitar('1234567890', anterior: '1.234.567,89'), '1.234.567,89');
  });

  test('centavos lê o texto mascarado como inteiro', () {
    expect(MoedaInputFormatter.centavos('1.234,56'), 123456);
    expect(MoedaInputFormatter.centavos('0,01'), 1);
    expect(MoedaInputFormatter.centavos(''), 0);
  });

  test('formatar e centavos são inversos', () {
    for (final valor in [1, 99, 100, 9000, 123456]) {
      expect(
        MoedaInputFormatter.centavos(MoedaInputFormatter.formatar(valor)),
        valor,
      );
    }
  });
}
