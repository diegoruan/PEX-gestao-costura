import 'package:intl/intl.dart';

/// Requer `initializeDateFormatting('pt_BR')`, feito no main.dart.
abstract final class Formatadores {
  static final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
  static final _moedaInteira = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
    decimalDigits: 0,
  );
  static final _data = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _dataHora = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
  static final _mesAno = DateFormat('MMMM/yyyy', 'pt_BR');
  static final _mesAnoExtenso = DateFormat("MMMM 'de' yyyy", 'pt_BR');
  static final _mesAbreviado = DateFormat('MMM', 'pt_BR');
  static final _diaMesExtenso = DateFormat("d 'de' MMMM", 'pt_BR');
  static final _dataExtenso = DateFormat("d 'de' MMMM, yyyy", 'pt_BR');

  /// 1240.5 -> "R$ 1.240,50"
  static String moeda(num valor) => _moeda.format(valor);

  /// 18050 -> "R$ 180,50". Os valores do app são guardados em centavos.
  static String moedaCentavos(int centavos) => _moeda.format(centavos / 100);

  /// Versão curta da lista: 18000 -> "R$ 180", mas 18050 -> "R$ 180,50".
  static String moedaCompacta(int centavos) => centavos % 100 == 0
      ? _moedaInteira.format(centavos ~/ 100)
      : moedaCentavos(centavos);

  /// DateTime(2026, 9, 1) -> "01/09/2026"
  static String data(DateTime data) => _data.format(data);

  static String dataHora(DateTime data) => _dataHora.format(data);

  /// Útil no fechamento mensal: DateTime(2026, 9) -> "setembro/2026"
  static String mesAno(DateTime data) => _mesAno.format(data);

  /// DateTime(2025, 3) -> "março de 2025"
  static String mesAnoExtenso(DateTime data) => _mesAnoExtenso.format(data);

  /// DateTime(2026, 9, 3) -> "3 set"
  static String diaMes(DateTime data) => '${data.day} ${_mes(data)}';

  /// DateTime(2026, 9, 3) -> "3 set 2026"
  static String diaMesAno(DateTime data) => '${diaMes(data)} ${data.year}';

  /// DateTime(2026, 9, 3) -> "3 de setembro"
  static String diaMesExtenso(DateTime data) => _diaMesExtenso.format(data);

  /// DateTime(2026, 9, 3) -> "3 de setembro, 2026"
  static String dataExtenso(DateTime data) => _dataExtenso.format(data);

  /// 1 -> "1 peça"; 3 -> "3 peças"
  static String pecas(int quantidade) =>
      quantidade == 1 ? '1 peça' : '$quantidade peças';

  // O intl abrevia com ponto ("set."); o Figma usa sem.
  static String _mes(DateTime data) =>
      _mesAbreviado.format(data).replaceAll('.', '');
}
