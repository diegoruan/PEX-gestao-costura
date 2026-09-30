import 'package:intl/intl.dart';

/// Requer `initializeDateFormatting('pt_BR')`, feito no main.dart.
abstract final class Formatadores {
  static final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
  static final _data = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _dataHora = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
  static final _mesAno = DateFormat('MMMM/yyyy', 'pt_BR');

  /// 1240.5 -> "R$ 1.240,50"
  static String moeda(num valor) => _moeda.format(valor);

  /// DateTime(2026, 9, 1) -> "01/09/2026"
  static String data(DateTime data) => _data.format(data);

  static String dataHora(DateTime data) => _dataHora.format(data);

  /// Útil no fechamento mensal: DateTime(2026, 9) -> "setembro/2026"
  static String mesAno(DateTime data) => _mesAno.format(data);
}
