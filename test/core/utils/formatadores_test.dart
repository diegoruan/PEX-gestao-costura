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
    expect(Formatadores.mesAnoExtenso(DateTime(2025, 3)), 'março de 2025');
    expect(Formatadores.mesAnoTitulo(DateTime(2026, 9)), 'Setembro 2026');
    expect(Formatadores.mesAnoTitulo(DateTime(2027, 1, 31)), 'Janeiro 2027');
  });

  test('formata valores em centavos', () {
    expect(Formatadores.moedaCentavos(18050), 'R\$ 180,50');
    expect(Formatadores.moedaCentavos(9999), 'R\$ 99,99');
    expect(Formatadores.moedaCentavos(0), 'R\$ 0,00');
  });

  test('moeda compacta só esconde os centavos quando são zero', () {
    expect(Formatadores.moedaCompacta(18000), 'R\$ 180');
    expect(Formatadores.moedaCompacta(18050), 'R\$ 180,50');
    expect(Formatadores.moedaCompacta(123400), 'R\$ 1.234');
  });

  test('formata datas curtas e por extenso dos pedidos', () {
    final data = DateTime(2026, 9, 3);
    expect(Formatadores.diaMes(data), '3 set');
    expect(Formatadores.diaMesAno(data), '3 set 2026');
    expect(Formatadores.diaMesExtenso(data), '3 de setembro');
    expect(Formatadores.dataExtenso(data), '3 de setembro, 2026');
  });

  test('pluraliza peças', () {
    expect(Formatadores.pecas(1), '1 peça');
    expect(Formatadores.pecas(2), '2 peças');
  });

  test('pluraliza clientes', () {
    expect(Formatadores.clientes(1), '1 cliente');
    expect(Formatadores.clientes(4), '4 clientes');
  });

  test('mês e ano curtos do fechamento, inclusive na virada do ano', () {
    expect(Formatadores.mesAnoCurto(DateTime(2026, 8)), 'ago/26');
    expect(Formatadores.mesAnoCurto(DateTime(2026, 12, 31)), 'dez/26');
    expect(Formatadores.mesAnoCurto(DateTime(2027, 1)), 'jan/27');
    expect(Formatadores.mesAnoCurto(DateTime(2100, 5)), 'mai/00');
  });
}
