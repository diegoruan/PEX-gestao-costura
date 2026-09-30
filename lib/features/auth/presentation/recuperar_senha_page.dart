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

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({super.key, this.emailInicial});

  final String? emailInicial;

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
    text: widget.emailInicial,
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthRecuperacaoSenhaSolicitada(email: _emailController.text),
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
          (atual is AuthErro || atual is AuthRecuperacaoEnviada) &&
          (ModalRoute.of(context)?.isCurrent ?? false),
      listener: (context, state) {
        switch (state) {
          case AuthErro(:final mensagem):
            mostrarSnackbarErro(context, mensagem);
          case AuthRecuperacaoEnviada(:final email):
            mostrarSnackbarSucesso(
              context,
              'Enviamos um link de redefinição para $email. '
              'Confira sua caixa de entrada e o spam.',
            );
            _voltarParaLogin();
          default:
            break;
        }
      },
      builder: (context, state) {
        final carregando = state is AuthCarregando;
        return AuthLayout(
          titulo: 'Esqueceu a senha?',
          subtitulo: 'Enviaremos um link para você criar uma nova',
          formulario: Form(
            key: _formKey,
            child: CartaoFormulario(
              campos: [
                CampoTexto(
                  rotulo: 'E-mail',
                  hint: 'seu@email.com',
                  controller: _emailController,
                  validator: Validadores.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  onFieldSubmitted: (_) => _enviar(),
                  enabled: !carregando,
                ),
              ],
            ),
          ),
          acoes: [
            BotaoPrimario(
              texto: 'Enviar link',
              onPressed: _enviar,
              carregando: carregando,
            ),
            LinkTexto(
              texto: 'Voltar para o login',
              onPressed: carregando ? null : _voltarParaLogin,
            ),
          ],
        );
      },
    );
  }
}
