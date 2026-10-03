import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pex_gestao_costura/features/pedidos/domain/pedido.dart';

void main() {
  final criadoEm = DateTime(2026, 8, 28, 9, 15);
  final dataEntrega = DateTime(2026, 9, 3);
  final pedido = Pedido(
    id: 'p1',
    clienteId: 'c1',
    clienteNome: 'Ana Clara',
    nome: 'Vestido Floral',
    valorUnitarioCentavos: 9000,
    quantidade: 2,
    dataEntrega: dataEntrega,
    observacoes: 'Tamanho P, com forro',
    fotoVersao: 1756900000000,
    criadoEm: criadoEm,
  );

  group('toMap', () {
    test('gera os campos do documento, sem o id, com datas em Timestamp', () {
      expect(pedido.toMap(), {
        'clienteId': 'c1',
        'clienteNome': 'Ana Clara',
        'nome': 'Vestido Floral',
        'valorUnitarioCentavos': 9000,
        'quantidade': 2,
        'dataEntrega': Timestamp.fromDate(dataEntrega),
        'observacoes': 'Tamanho P, com forro',
        'fotoVersao': 1756900000000,
        'status': 'pendente',
        'dataFinalizacao': null,
        'criadoEm': Timestamp.fromDate(criadoEm),
      });
    });

    test('grava status e dataFinalizacao de um pedido finalizado', () {
      final finalizadoEm = DateTime(2026, 9, 2, 18, 40);
      final mapa = pedido
          .copyWith(
            status: StatusPedido.finalizado,
            dataFinalizacao: () => finalizadoEm,
          )
          .toMap();
      expect(mapa['status'], 'finalizado');
      expect(mapa['dataFinalizacao'], Timestamp.fromDate(finalizadoEm));
    });
  });

  group('fromMap', () {
    test('ida e volta com toMap reconstrói o mesmo pedido', () {
      expect(Pedido.fromMap('p1', pedido.toMap()), pedido);

      final finalizado = pedido.copyWith(
        status: StatusPedido.finalizado,
        dataFinalizacao: () => DateTime(2026, 9, 2, 18, 40),
      );
      expect(Pedido.fromMap('p1', finalizado.toMap()), finalizado);
    });

    test('converte Timestamp em DateTime', () {
      final lido = Pedido.fromMap('p1', pedido.toMap());
      expect(lido.dataEntrega, isA<DateTime>());
      expect(lido.dataEntrega, dataEntrega);
      expect(lido.criadoEm, criadoEm);
    });

    test('campos opcionais ausentes viram null e o status é pendente', () {
      final lido = Pedido.fromMap('x', {
        'clienteId': 'c1',
        'clienteNome': 'Ana',
        'nome': 'Saia',
        'valorUnitarioCentavos': 100,
        'quantidade': 1,
        'dataEntrega': Timestamp.fromDate(dataEntrega),
        'criadoEm': Timestamp.fromDate(criadoEm),
      });
      expect(lido.observacoes, isNull);
      expect(lido.fotoVersao, isNull);
      expect(lido.temFoto, isFalse);
      expect(lido.dataFinalizacao, isNull);
      expect(lido.status, StatusPedido.pendente);
      expect(lido.finalizado, isFalse);
    });

    test('aceita números vindos como double do Firestore', () {
      final lido = Pedido.fromMap('x', {
        ...pedido.toMap(),
        'valorUnitarioCentavos': 9000.0,
        'quantidade': 2.0,
      });
      expect(lido.valorUnitarioCentavos, 9000);
      expect(lido.quantidade, 2);
    });

    test('status desconhecido cai em pendente', () {
      final lido = Pedido.fromMap('x', {...pedido.toMap(), 'status': '???'});
      expect(lido.status, StatusPedido.pendente);
    });
  });

  group('totalCentavos', () {
    test('é valor unitário x quantidade', () {
      expect(pedido.totalCentavos, 18000);
      expect(pedido.copyWith(quantidade: 1).totalCentavos, 9000);
    });

    test('preserva os centavos sem arredondar', () {
      final quebrado = pedido.copyWith(
        valorUnitarioCentavos: 3333, // R$ 33,33
        quantidade: 3,
      );
      expect(quebrado.totalCentavos, 9999); // R$ 99,99, não R$ 100,00
    });

    test('não sofre o erro de ponto flutuante de double', () {
      // Em double, 0.1 * 3 == 0.30000000000000004.
      expect(0.1 * 3 == 0.3, isFalse);
      final dezCentavos = pedido.copyWith(
        valorUnitarioCentavos: 10,
        quantidade: 3,
      );
      expect(dezCentavos.totalCentavos, 30);
    });

    test('soma de vários pedidos continua exata', () {
      final pedidos = List.generate(
        1000,
        (_) => pedido.copyWith(valorUnitarioCentavos: 1, quantidade: 1),
      );
      final soma = pedidos.fold(0, (total, p) => total + p.totalCentavos);
      expect(soma, 1000); // R$ 10,00 exatos
    });
  });

  group('prazo', () {
    PrazoPedido prazoPara(DateTime entrega, DateTime agora) =>
        pedido.copyWith(dataEntrega: entrega).prazo(agora);

    final agora = DateTime(2026, 9, 3, 15, 30);

    test('classifica pela data, ignorando a hora', () {
      expect(prazoPara(DateTime(2026, 9, 2), agora), PrazoPedido.atrasado);
      expect(prazoPara(DateTime(2026, 9, 3), agora), PrazoPedido.hoje);
      expect(prazoPara(DateTime(2026, 9, 4), agora), PrazoPedido.estaSemana);
      expect(prazoPara(DateTime(2026, 9, 10), agora), PrazoPedido.estaSemana);
      expect(prazoPara(DateTime(2026, 9, 11), agora), PrazoPedido.depois);
    });
  });

  group('ordenação', () {
    final cedo = pedido.copyWith(dataEntrega: DateTime(2026, 9, 1));
    final tarde = pedido.copyWith(dataEntrega: DateTime(2026, 9, 20));

    test('pendentes: entrega mais próxima primeiro', () {
      expect([tarde, cedo]..sort(Pedido.compararPorEntrega), [cedo, tarde]);
    });

    test('finalizados: finalização mais recente primeiro', () {
      final antigo = pedido.copyWith(
        nome: 'Antigo',
        dataFinalizacao: () => DateTime(2026, 8, 1),
      );
      final recente = pedido.copyWith(
        nome: 'Recente',
        dataFinalizacao: () => DateTime(2026, 9, 1),
      );
      expect([antigo, recente]..sort(Pedido.compararPorFinalizacao), [
        recente,
        antigo,
      ]);
    });
  });

  group('copyWith', () {
    test('altera só o que foi passado', () {
      final editado = pedido.copyWith(nome: 'Vestido Longo');
      expect(editado.nome, 'Vestido Longo');
      expect(editado.id, pedido.id);
      expect(editado.clienteNome, pedido.clienteNome);
      expect(editado.fotoVersao, pedido.fotoVersao);
      expect(editado.criadoEm, pedido.criadoEm);
    });

    test('consegue limpar campos opcionais', () {
      final editado = pedido.copyWith(
        observacoes: () => null,
        fotoVersao: () => null,
      );
      expect(editado.observacoes, isNull);
      expect(editado.fotoVersao, isNull);
      expect(editado.temFoto, isFalse);
    });
  });

  test('dois pedidos com os mesmos dados são iguais (Equatable)', () {
    expect(pedido.copyWith(), pedido);
    expect(pedido.copyWith(quantidade: 3), isNot(pedido));
  });
}
