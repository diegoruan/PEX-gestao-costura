abstract final class Texto {
  static const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  static const _semAcento = 'aaaaaeeeeiiiiooooouuuucn';

  /// Minúsculo e sem acentos, para ordenar e buscar sem que "Ângela" vá
  /// parar depois de "Zilda" ou que "jose" não encontre "José".
  static String normalizar(String texto) {
    final minusculo = texto.trim().toLowerCase();
    final buffer = StringBuffer();
    for (final letra in minusculo.split('')) {
      final i = _comAcento.indexOf(letra);
      buffer.write(i >= 0 ? _semAcento[i] : letra);
    }
    return buffer.toString();
  }

  /// "Ana Clara Souza" -> "AC"; "Regina" -> "RE".
  static String iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'))
      ..removeWhere((p) => p.isEmpty);
    if (partes.isEmpty) return '?';
    if (partes.length == 1) {
      final unica = partes.first;
      return unica.substring(0, unica.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (partes.first[0] + partes[1][0]).toUpperCase();
  }
}
