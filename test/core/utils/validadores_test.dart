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

  group('Validadores.valorPositivo (formulário de pedido)', () {
    test('aceita valores maiores que zero no formato da máscara', () {
      expect(Validadores.valorPositivo('0,01'), isNull);
      expect(Validadores.valorPositivo('90,00'), isNull);
      expect(Validadores.valorPositivo('1.234,56'), isNull);
    });

    test('rejeita vazio e zero', () {
      expect(Validadores.valorPositivo(null), isNotNull);
      expect(Validadores.valorPositivo(''), isNotNull);
      expect(Validadores.valorPositivo('0,00'), isNotNull);
    });
  });

  group('Validadores.quantidade (formulário de pedido)', () {
    test('aceita 1 ou mais', () {
      expect(Validadores.quantidade(1), isNull);
      expect(Validadores.quantidade(30), isNull);
    });

    test('rejeita nulo, zero e negativo', () {
      expect(Validadores.quantidade(null), isNotNull);
      expect(Validadores.quantidade(0), isNotNull);
      expect(Validadores.quantidade(-2), isNotNull);
    });
  });

  group('Validadores.selecionado (cliente e data do pedido)', () {
    final cliente = Validadores.selecionado<String>('Escolha o cliente');
    final data = Validadores.selecionado<DateTime>('Escolha a data');

    test('exige uma escolha', () {
      expect(cliente(null), 'Escolha o cliente');
      expect(data(null), 'Escolha a data');
    });

    test('aceita qualquer valor escolhido', () {
      expect(cliente('c1'), isNull);
      expect(data(DateTime(2026, 9, 3)), isNull);
    });
  });

  group('Validadores.nome (nome da peça)', () {
    test('exige 2 ou mais caracteres', () {
      expect(Validadores.nome('V'), isNotNull);
      expect(Validadores.nome('Vestido'), isNull);
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
