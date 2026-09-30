import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pex_gestao_costura/core/utils/formatadores.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('formata moeda no padrão brasileiro', () {
    // O intl usa espaço não separável entre "R$" e o valor.
    expect(Formatadores.moeda(1240.5), 'R\$ 1.240,50');
  });

  test('formata datas no padrão dd/MM/yyyy', () {
    expect(Formatadores.data(DateTime(2026, 9, 1)), '01/09/2026');
    expect(Formatadores.mesAno(DateTime(2026, 9)), 'setembro/2026');
  });
}
