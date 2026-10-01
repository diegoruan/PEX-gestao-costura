import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pex_gestao_costura/features/clientes/domain/cliente.dart';

void main() {
  final criadoEm = DateTime(2025, 3, 10, 14, 30);
  final cliente = Cliente(
    id: 'abc',
    nome: 'Ana Clara',
    apelido: 'Aninha',
    telefone: '(11) 9 8765-4321',
    email: 'ana@email.com',
    endereco: 'Centro, Joinville',
    observacoes: 'Tamanho P',
    criadoEm: criadoEm,
  );

  group('toMap', () {
    test('gera os campos do documento, sem o id', () {
      expect(cliente.toMap(), {
        'nome': 'Ana Clara',
        'apelido': 'Aninha',
        'telefone': '(11) 9 8765-4321',
        'email': 'ana@email.com',
        'endereco': 'Centro, Joinville',
        'observacoes': 'Tamanho P',
        'ativo': true,
        'criadoEm': Timestamp.fromDate(criadoEm),
      });
    });
  });

  group('fromMap', () {
    test('ida e volta com toMap reconstrói o mesmo cliente', () {
      expect(Cliente.fromMap('abc', cliente.toMap()), cliente);
    });

    test('campos opcionais ausentes viram null e ativo é true', () {
      final lido = Cliente.fromMap('x', {
        'nome': 'Pedro',
        'criadoEm': Timestamp.fromDate(criadoEm),
      });
      expect(lido.apelido, isNull);
      expect(lido.telefone, isNull);
      expect(lido.email, isNull);
      expect(lido.endereco, isNull);
      expect(lido.observacoes, isNull);
      expect(lido.ativo, isTrue);
    });

    test('lê ativo = false de clientes excluídos', () {
      final lido = Cliente.fromMap('x', {...cliente.toMap(), 'ativo': false});
      expect(lido.ativo, isFalse);
    });
  });

  group('copyWith', () {
    test('altera só o que foi passado', () {
      final editado = cliente.copyWith(nome: 'Ana C.');
      expect(editado.nome, 'Ana C.');
      expect(editado.apelido, cliente.apelido);
      expect(editado.telefone, cliente.telefone);
      expect(editado.email, cliente.email);
      expect(editado.endereco, cliente.endereco);
      expect(editado.id, cliente.id);
      expect(editado.criadoEm, cliente.criadoEm);
    });

    test('consegue limpar campos opcionais', () {
      final editado = cliente.copyWith(
        apelido: () => null,
        telefone: () => null,
        email: () => null,
        endereco: () => null,
        observacoes: () => null,
      );
      expect(editado.apelido, isNull);
      expect(editado.telefone, isNull);
      expect(editado.email, isNull);
      expect(editado.endereco, isNull);
      expect(editado.observacoes, isNull);
    });
  });

  group('nome de exibição', () {
    final semApelido = cliente.copyWith(apelido: () => null);

    test('na lista, o apelido substitui o nome', () {
      expect(cliente.nomeExibicao, 'Aninha');
      expect(semApelido.nomeExibicao, 'Ana Clara');
    });

    test('no detalhe, mostra "Nome (Apelido)"', () {
      expect(cliente.nomeComApelido, 'Ana Clara (Aninha)');
      expect(semApelido.nomeComApelido, 'Ana Clara');
    });
  });

  test('dois clientes com os mesmos dados são iguais (Equatable)', () {
    expect(cliente.copyWith(), cliente);
    expect(cliente.copyWith(ativo: false), isNot(cliente));
  });
}
