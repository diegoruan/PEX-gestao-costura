import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

import '../errors/falha.dart';

/// Espera uma escrita do Firestore (set/update) por no máximo [limite].
///
/// Offline, o Firestore aplica a escrita no cache na hora (os streams já
/// refletem a mudança), mas o Future só completa quando o servidor confirma,
/// o que pode nunca acontecer enquanto não houver internet. Passado o limite,
/// consideramos a escrita feita para a tela não travar; ela sincroniza sozinha
/// quando a conexão voltar. Erros que chegam dentro do limite (como
/// permission-denied) viram [Falha].
Future<void> aguardarEscrita(
  Future<void> escrita, {
  Duration limite = const Duration(seconds: 2),
}) async {
  try {
    await escrita.timeout(limite);
  } on TimeoutException {
    return;
  } on FirebaseException catch (e) {
    throw Falha.firestore(e);
  }
}
