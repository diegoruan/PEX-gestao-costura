import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/falha.dart';
import '../data/cliente_repository.dart';
import '../domain/cliente.dart';
import 'clientes_event.dart';
import 'clientes_state.dart';

export 'clientes_event.dart';
export 'clientes_state.dart';

class ClientesBloc extends Bloc<ClientesEvent, ClientesState> {
  ClientesBloc({required this._clienteRepository})
    : super(const ClientesCarregando()) {
    // restartable: ao tentar de novo após um erro, a assinatura anterior do
    // stream é cancelada antes de abrir outra.
    on<ClientesIniciado>(_onIniciado, transformer: restartable());
    on<ClienteCadastroSolicitado>(_onCadastroSolicitado);
    on<ClienteEdicaoSolicitada>(_onEdicaoSolicitada);
    on<ClienteInativacaoSolicitada>(_onInativacaoSolicitada);
  }

  final ClienteRepository _clienteRepository;

  Future<void> _onIniciado(
    ClientesIniciado event,
    Emitter<ClientesState> emit,
  ) async {
    emit(const ClientesCarregando());
    await emit.forEach(
      _clienteRepository.observarAtivos(),
      onData: (clientes) {
        final atual = state;
        return atual is ClientesSucesso
            ? atual.copyWith(clientes: clientes)
            : ClientesSucesso(clientes);
      },
      onError: (erro, _) =>
          ClientesErro(erro is Falha ? erro.mensagem : Falha.mensagemGenerica),
    );
  }

  Future<void> _onCadastroSolicitado(
    ClienteCadastroSolicitado event,
    Emitter<ClientesState> emit,
  ) {
    return _executar(
      emit,
      emAndamento: AcaoCliente.salvando,
      concluida: AcaoCliente.salvo,
      acao: () => _clienteRepository.cadastrar(
        nome: event.nome,
        telefone: event.telefone,
        observacoes: event.observacoes,
      ),
    );
  }

  Future<void> _onEdicaoSolicitada(
    ClienteEdicaoSolicitada event,
    Emitter<ClientesState> emit,
  ) {
    return _executar(
      emit,
      emAndamento: AcaoCliente.salvando,
      concluida: AcaoCliente.salvo,
      acao: () => _clienteRepository.atualizar(event.cliente),
    );
  }

  Future<void> _onInativacaoSolicitada(
    ClienteInativacaoSolicitada event,
    Emitter<ClientesState> emit,
  ) {
    return _executar(
      emit,
      emAndamento: AcaoCliente.inativando,
      concluida: AcaoCliente.inativado,
      acao: () => _clienteRepository.inativar(event.id),
    );
  }

  /// Padrão das ações de escrita: em andamento -> concluída ou falhou,
  /// mantendo a lista atual no estado.
  Future<void> _executar(
    Emitter<ClientesState> emit, {
    required AcaoCliente emAndamento,
    required AcaoCliente concluida,
    required Future<void> Function() acao,
  }) async {
    emit(_comAcao(emAndamento));
    try {
      await acao();
      emit(_comAcao(concluida));
    } on Falha catch (e) {
      emit(_comAcao(AcaoCliente.falhou, mensagemErro: e.mensagem));
    }
  }

  ClientesSucesso _comAcao(AcaoCliente acao, {String? mensagemErro}) {
    final atual = state;
    final clientes = atual is ClientesSucesso
        ? atual.clientes
        : const <Cliente>[];
    return ClientesSucesso(clientes, acao: acao, mensagemErro: mensagemErro);
  }
}
