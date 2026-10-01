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

  group('Validadores.emailOpcional', () {
    test('aceita vazio, porque o campo é opcional', () {
      expect(Validadores.emailOpcional(null), isNull);
      expect(Validadores.emailOpcional(''), isNull);
      expect(Validadores.emailOpcional('   '), isNull);
    });

    test('aceita e-mail válido, ignorando espaços nas pontas', () {
      expect(Validadores.emailOpcional('maria@email.com'), isNull);
      expect(Validadores.emailOpcional(' maria@email.com '), isNull);
    });

    test('rejeita formato inválido', () {
      expect(Validadores.emailOpcional('maria@'), isNotNull);
      expect(Validadores.emailOpcional('maria email.com'), isNotNull);
    });
  });

  group('Validadores.senha', () {
    test('exige no mínimo 6 caracteres', () {
      expect(Validadores.senha('12345'), isNotNull);
      expect(Validadores.senha('123456'), isNull);
    });
  });

  group('Validadores.nome', () {
    test('exige pelo menos 2 caracteres', () {
      expect(Validadores.nome('A'), isNotNull);
      expect(Validadores.nome('Al'), isNull);
    });

    test('rejeita vazio e só espaços', () {
      expect(Validadores.nome(null), isNotNull);
      expect(Validadores.nome(''), isNotNull);
      expect(Validadores.nome('    '), isNotNull);
      expect(Validadores.nome(' A '), isNotNull);
    });
  });

  group('Validadores.telefoneOpcional', () {
    test('aceita vazio, porque o campo é opcional', () {
      expect(Validadores.telefoneOpcional(null), isNull);
      expect(Validadores.telefoneOpcional(''), isNull);
      expect(Validadores.telefoneOpcional('   '), isNull);
    });

    test('aceita formatos comuns', () {
      expect(Validadores.telefoneOpcional('(11) 9 8765-4321'), isNull);
      expect(Validadores.telefoneOpcional('11987654321'), isNull);
      expect(Validadores.telefoneOpcional('+55 11 98765-4321'), isNull);
      expect(Validadores.telefoneOpcional('3456-7890'), isNull);
    });

    test('rejeita letras e símbolos estranhos', () {
      expect(Validadores.telefoneOpcional('11 9abc-4321'), isNotNull);
      expect(Validadores.telefoneOpcional('11#98765'), isNotNull);
    });

    test('rejeita quantidade de dígitos fora do esperado', () {
      expect(Validadores.telefoneOpcional('1234'), isNotNull);
      expect(Validadores.telefoneOpcional('+55 11 98765-43210'), isNotNull);
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
