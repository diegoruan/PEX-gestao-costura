import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validadores.dart';
import '../../../shared/widgets/botao_primario.dart';
import '../../../shared/widgets/campo_texto.dart';
import '../../../shared/widgets/cartao_formulario.dart';
import '../../../shared/widgets/link_texto.dart';
import '../../../shared/widgets/snackbar_mensagem.dart';
import '../bloc/auth_bloc.dart';
import 'widgets/auth_layout.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmacaoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }

  void _cadastrar() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthCadastroSolicitado(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
      ),
    );
  }

  void _voltarParaLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, atual) =>
          atual is AuthErro && (ModalRoute.of(context)?.isCurrent ?? false),
      listener: (context, state) {
        if (state is AuthErro) mostrarSnackbarErro(context, state.mensagem);
      },
      builder: (context, state) {
        final carregando = state is AuthCarregando;
        return AuthLayout(
          titulo: 'Crie sua conta',
          subtitulo: 'Comece a organizar seus pedidos de atelier',
          formulario: Form(
            key: _formKey,
            child: AutofillGroup(
              child: CartaoFormulario(
                campos: [
                  CampoTexto(
                    rotulo: 'Nome',
                    hint: 'Como você quer ser chamada',
                    controller: _nomeController,
                    validator: (v) => Validadores.obrigatorio(v, campo: 'Nome'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    enabled: !carregando,
                  ),
                  CampoTexto(
                    rotulo: 'E-mail',
                    hint: 'seu@email.com',
                    controller: _emailController,
                    validator: Validadores.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    enabled: !carregando,
                  ),
                  CampoTexto(
                    rotulo: 'Senha',
                    hint: '••••••••',
                    controller: _senhaController,
                    validator: Validadores.senha,
                    senha: true,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    enabled: !carregando,
                  ),
                  CampoTexto(
                    rotulo: 'Confirmar senha',
                    hint: '••••••••',
                    controller: _confirmacaoController,
                    validator: Validadores.confirmacaoSenha(
                      () => _senhaController.text,
                    ),
                    senha: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _cadastrar(),
                    enabled: !carregando,
                  ),
                ],
              ),
            ),
          ),
          acoes: [
            BotaoPrimario(
              texto: 'Criar conta',
              onPressed: _cadastrar,
              carregando: carregando,
            ),
            LinkTexto(
              texto: 'Já tenho uma conta',
              onPressed: carregando ? null : _voltarParaLogin,
            ),
          ],
        );
      },
    );
  }
}
