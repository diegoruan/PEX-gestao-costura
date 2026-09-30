import 'package:flutter_test/flutter_test.dart';
import 'package:pex_gestao_costura/core/utils/texto.dart';

void main() {
  group('Texto.normalizar', () {
    test('remove acentos, espaços das pontas e caixa alta', () {
      expect(Texto.normalizar('  Ângela Conceição '), 'angela conceicao');
    });

    test('permite ordenar acentuados junto com os demais', () {
      final nomes = ['Zilda', 'Ângela', 'Bruna']
        ..sort((a, b) => Texto.normalizar(a).compareTo(Texto.normalizar(b)));
      expect(nomes, ['Ângela', 'Bruna', 'Zilda']);
    });
  });

  group('Texto.iniciais', () {
    test('usa a primeira letra dos dois primeiros nomes', () {
      expect(Texto.iniciais('ana clara souza'), 'AC');
    });

    test('com um nome só, usa as duas primeiras letras', () {
      expect(Texto.iniciais('Regina'), 'RE');
    });

    test('lida com espaços extras e nomes curtos', () {
      expect(Texto.iniciais('  Pedro   Lima '), 'PL');
      expect(Texto.iniciais('A'), 'A');
    });
  });
}
