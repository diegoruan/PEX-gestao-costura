import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../shared/widgets/indicador_carregando.dart';
import '../../../shared/widgets/logo_atelie.dart';

/// Exibida enquanto o Firebase restaura a sessão salva no dispositivo.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LogoAtelie(),
            SizedBox(height: AppSpacing.xxl),
            IndicadorCarregando(),
          ],
        ),
      ),
    );
  }
}
