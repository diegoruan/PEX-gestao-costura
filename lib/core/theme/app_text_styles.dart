import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tamanhos, pesos e cores do Figma, com a fonte do sistema (Roboto no
/// Android, San Francisco no iOS).
abstract final class AppTextStyles {
  static const marca = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: AppColors.primaria,
  );

  static const marcaSubtitulo = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    color: AppColors.textoSecundario,
  );

  static const titulo = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const subtitulo = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSecundario,
  );

  static const rotuloCampo = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.textoSecundario,
  );

  static const textoCampo = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textoPrincipal,
  );

  static final placeholderCampo = textoCampo.copyWith(
    color: AppColors.placeholder,
  );

  static const erroCampo = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.erro,
  );

  static const botao = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textoSobrePrimaria,
  );

  static const link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaria,
  );

  static const linkSecundario = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textoSecundario,
  );

  static const corpo = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textoPrincipal,
  );

  static const tituloPagina = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  /// Cabeçalho de grupo em caixa alta ("DADOS PESSOAIS", letra da lista).
  static const rotuloSecao = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    color: AppColors.textoSecundario,
  );

  static const tituloItem = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const legenda = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSecundario,
  );

  static const tituloDestaque = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const iniciais = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textoSobrePrimaria,
  );

  static final iniciaisDestaque = iniciais.copyWith(fontSize: 30);

  static final iniciaisCompacto = iniciais.copyWith(fontSize: 12);

  static const rotuloLinha = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSecundario,
  );

  static const valorLinha = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const textoLongo = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.7,
    color: AppColors.textoPrincipal,
  );

  static const botaoPequeno = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textoSobrePrimaria,
  );

  static const botaoSuave = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primaria,
  );

  /// "8 pedidos" no topo da lista; o resto da frase usa [legenda].
  static const legendaDestaque = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const legendaPequena = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSecundario,
  );

  /// Valor total no cartão de pedido da lista.
  static const valorItem = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textoValor,
  );

  /// Texto das etiquetas de prazo; a cor muda conforme a etiqueta.
  static const etiqueta = TextStyle(fontSize: 10, fontWeight: FontWeight.w700);

  static const avisoTitulo = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primariaEscura,
  );

  static const avisoTexto = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.primaria,
  );

  /// Valor dos cartõezinhos de resumo do detalhe (total, quantidade...).
  static const valorResumo = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const totalRotulo = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSobrePrimariaSuave,
  );

  static const totalValor = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textoSobrePrimaria,
  );

  static const totalDetalhe = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSobrePrimariaFraco,
  );

  static const quantidade = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const botaoQuantidade = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primaria,
  );

  /// Botão branco ao lado do principal, como o "Editar" do detalhe.
  static const botaoSecundario = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  /// Nome da peça no item do histórico, um pouco menor que [tituloItem].
  static const tituloItemCompacto = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  /// Valor total no item do histórico.
  static const valorItemCompacto = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textoValor,
  );

  /// Chips de filtro; a cor muda se o chip está selecionado.
  static const chip = TextStyle(fontSize: 12, fontWeight: FontWeight.w700);

  /// Mês no cabeçalho dos grupos do histórico ("Setembro 2026").
  static const rotuloMes = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textoValor,
  );

  /// Total do mês, à direita do [rotuloMes].
  static const totalMes = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.primaria,
  );

  /// Números do cartão de resumo do histórico.
  static const numeroResumo = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primaria,
  );

  static const legendaMinima = TextStyle(
    fontSize: 9.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSecundario,
  );

  /// Mês no seletor do fechamento ("Agosto 2026").
  static const tituloMes = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  /// Textos de apoio dos totais do fechamento ("Total do mês").
  static const legendaValor = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textoValor,
  );

  /// Total do mês no topo do fechamento.
  static const totalDestaque = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.primaria,
  );

  /// Total geral no cartão do fim do fechamento.
  static const totalGeral = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.primaria,
  );

  /// Números dos cartõezinhos do fechamento (peças, clientes, referência).
  static const numeroEstatistica = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primaria,
  );

  /// Nome da peça nas linhas de detalhe do cliente.
  static const textoDetalhe = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textoPrincipal,
  );

  static const valorDetalhe = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textoValor,
  );

  /// Selo "Fechado" do total geral.
  static const selo = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textoValor,
  );

  /// Rótulos da barra de navegação inferior.
  static const rotuloNavegacao = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSecundario,
  );

  static const rotuloNavegacaoAtivo = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.primaria,
  );

  /// "Ateliê" no cabeçalho rosa da Home.
  static const marcaCabecalho = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.textoSobrePrimaria,
  );

  static const subtituloCabecalho = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSobrePrimariaSuave,
  );

  static const saudacao = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSobrePrimariaSuave,
  );

  static const nomeUsuario = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textoSobrePrimaria,
  );

  /// Números dos cartões do topo da Home.
  static const numeroDestaque = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.primaria,
  );

  /// Aviso amarelo de entregas da Home.
  static const alertaTitulo = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.alertaTexto,
  );

  static const alertaMensagem = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.alerta,
  );

  /// Link discreto ao lado de um título de seção ("Ver todos →").
  static const linkPequeno = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.primaria,
  );

  /// Nome da peça nos pedidos recentes da Home.
  static const tituloItemPequeno = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const snackbar = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textoSobrePrimaria,
  );
}
