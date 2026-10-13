import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Começa (ou recomeça, após um erro) a escutar pendentes e finalizados.
final class HomeIniciado extends HomeEvent {
  const HomeIniciado();
}
