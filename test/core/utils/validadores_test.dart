import 'package:flutter_test/flutter_test.dart';
import 'package:pex_gestao_costura/core/utils/validadores.dart';

void main() {
  group('Validadores.email', () {
    test('aceita e-mail válido', () {
      expect(Validadores.email('maria@email.com'), isNull);
    });

    test('rejeita vazio e formato inválido', () {
      expect(Validadores.email(''), isNotNull);
      expect(Validadores.email('maria@'), isNotNull);
      expect(Validadores.email('maria email.com'), isNotNull);
    });
  });

  group('Validadores.senha', () {
    test('exige no mínimo 6 caracteres', () {
      expect(Validadores.senha('12345'), isNotNull);
      expect(Validadores.senha('123456'), isNull);
    });
  });

  group('Validadores.confirmacaoSenha', () {
    final validar = Validadores.confirmacaoSenha(() => 'segredo1');

    test('aceita quando é igual à senha', () {
      expect(validar('segredo1'), isNull);
    });

    test('rejeita quando é diferente', () {
      expect(validar('segredo2'), 'As senhas não coincidem');
    });
  });
}
