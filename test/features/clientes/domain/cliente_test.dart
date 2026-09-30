import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pex_gestao_costura/features/clientes/domain/cliente.dart';

void main() {
  final criadoEm = DateTime(2025, 3, 10, 14, 30);
  final cliente = Cliente(
    id: 'abc',
    nome: 'Ana Clara',
    telefone: '(11) 9 8765-4321',
    observacoes: 'Tamanho P',
    criadoEm: criadoEm,
  );

  group('toMap', () {
    test('gera os campos do documento, sem o id', () {
      expect(cliente.toMap(), {
        'nome': 'Ana Clara',
        'telefone': '(11) 9 8765-4321',
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
      expect(lido.telefone, isNull);
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
      expect(editado.telefone, cliente.telefone);
      expect(editado.id, cliente.id);
      expect(editado.criadoEm, cliente.criadoEm);
    });

    test('consegue limpar campos opcionais', () {
      final editado = cliente.copyWith(
        telefone: () => null,
        observacoes: () => null,
      );
      expect(editado.telefone, isNull);
      expect(editado.observacoes, isNull);
    });
  });

  test('dois clientes com os mesmos dados são iguais (Equatable)', () {
    expect(cliente.copyWith(), cliente);
    expect(cliente.copyWith(ativo: false), isNot(cliente));
  });
}
