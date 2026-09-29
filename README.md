# pex_gestao_costura

PEX em convênio com uma empresa de costura com o objetivo de criar app flutter de gestão.

## Configurando o Firebase (obrigatório antes de rodar o app)

Este é um repositório **público**, então os arquivos de configuração do Firebase
(`android/app/google-services.json`, `lib/firebase_options.dart`, etc.) **não são
versionados** (veja `.gitignore`). Cada dev precisa gerá-los localmente:

1. Peça para ser adicionado como colaborador do projeto Firebase `pex-gestao-costura`
   (peça acesso ao Diego pelo [Console do Firebase](https://console.firebase.google.com/)).
2. Instale o Node.js (se ainda não tiver) e o Firebase CLI:
   ```
   npm install -g firebase-tools
   firebase login
   ```
3. Instale o FlutterFire CLI:
   ```
   dart pub global activate flutterfire_cli
   ```
4. Na raiz do projeto, rode:
   ```
   flutterfire configure --project=pex-gestao-costura
   ```
   Isso gera automaticamente `lib/firebase_options.dart`,
   `android/app/google-services.json` e, se configurar iOS/macOS,
   `ios/Runner/GoogleService-Info.plist`.
5. Rode `flutter pub get` e o app já deve compilar normalmente.

**Nunca** remova essas entradas do `.gitignore` nem force o commit desses arquivos, o repositório é público.
