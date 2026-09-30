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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _entrar() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthLoginSolicitado(
        email: _emailController.text,
        senha: _senhaController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      // As telas de auth ficam empilhadas; só a que está visível reage.
      listenWhen: (_, atual) =>
          atual is AuthErro && (ModalRoute.of(context)?.isCurrent ?? false),
      listener: (context, state) {
        if (state is AuthErro) mostrarSnackbarErro(context, state.mensagem);
      },
      builder: (context, state) {
        final carregando = state is AuthCarregando;
        return AuthLayout(
          titulo: 'Bem-vinda de volta!',
          subtitulo: 'Faça login para gerenciar suas costuras',
          formulario: Form(
            key: _formKey,
            child: AutofillGroup(
              child: CartaoFormulario(
                campos: [
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
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _entrar(),
                    enabled: !carregando,
                  ),
                ],
              ),
            ),
          ),
          acoes: [
            BotaoPrimario(
              texto: 'Entrar',
              onPressed: _entrar,
              carregando: carregando,
            ),
            LinkTexto(
              texto: 'Criar uma conta',
              onPressed: carregando
                  ? null
                  : () => context.pushNamed(AppRoutes.cadastro),
            ),
            LinkTexto(
              texto: 'Esqueci minha senha',
              secundario: true,
              onPressed: carregando
                  ? null
                  : () => context.pushNamed(
                      AppRoutes.recuperarSenha,
                      extra: _emailController.text.trim(),
                    ),
            ),
          ],
        );
      },
    );
  }
}
