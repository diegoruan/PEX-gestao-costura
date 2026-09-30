import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/clientes/data/cliente_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR');

  runApp(
    App(
      authRepository: AuthRepository(),
      clienteRepository: ClienteRepository(),
    ),
  );
}
