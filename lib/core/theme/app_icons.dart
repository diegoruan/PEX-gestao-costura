import 'package:flutter/material.dart';

/// Ícones do app, todos do Material Icons (o equivalente mais próximo do
/// desenho do Figma). Use sempre estas constantes, nunca `Icons.` direto nas
/// telas: assim trocar um ícone é mudar uma linha.
abstract final class AppIcons {
  static const voltar = Icons.chevron_left_rounded;
  static const avancar = Icons.chevron_right_rounded;
  static const busca = Icons.search_rounded;
  static const adicionar = Icons.add_rounded;
  static const editar = Icons.edit_outlined;
  static const mais = Icons.more_horiz_rounded;
  static const lixeira = Icons.delete_outline_rounded;
  static const salvar = Icons.save_outlined;
  static const check = Icons.check_rounded;
  static const sair = Icons.logout_rounded;

  static const telefone = Icons.phone_outlined;
  static const email = Icons.mail_outline_rounded;
  static const endereco = Icons.location_on_outlined;

  static const camiseta = Icons.checkroom_outlined;
  static const camera = Icons.photo_camera_outlined;
  static const quantidade = Icons.adjust_rounded;
  static const pacote = Icons.inventory_2_outlined;
  static const etiqueta = Icons.sell_outlined;
  static const dolar = Icons.attach_money_rounded;
  static const alvo = Icons.track_changes_rounded;

  static const calendario = Icons.calendar_today_outlined;
  static const agenda = Icons.event_note_outlined;
  static const sino = Icons.notifications_none_rounded;
  static const alerta = Icons.warning_amber_rounded;

  static const casa = Icons.home_outlined;
  static const pessoas = Icons.people_outline_rounded;
  static const documento = Icons.insert_drive_file_outlined;
  static const documentoTexto = Icons.description_outlined;
  static const grafico = Icons.bar_chart_rounded;
  static const historico = Icons.history_rounded;

  static const galeria = Icons.photo_library_outlined;
  static const mostrarSenha = Icons.visibility_outlined;
  static const ocultarSenha = Icons.visibility_off_outlined;

  /// Estados vazios e de erro (EstadoMensagem).
  static const semConexao = Icons.cloud_off_outlined;
  static const semResultado = Icons.search_off_rounded;
  static const clienteNaoEncontrado = Icons.person_off_outlined;
  static const mesSemPecas = Icons.event_busy_outlined;
}
