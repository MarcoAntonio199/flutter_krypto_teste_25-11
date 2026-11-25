# KryptoVault — versão Flutter

Recriação em Flutter do projeto final (React + Express + MySQL). O app usa **o mesmo backend, sem nenhuma alteração**: mesmas rotas (`/api/auth`, `/api/vault`, `/api/dashboard`, `/api/continuity`), mesma sessão por cookie HTTP-only e mesma criptografia AES-256-GCM feita no servidor.

## Telas (espelham as páginas do React)

| Flutter | React | Rota |
|---|---|---|
| `landing_screen.dart` | `Landing` (App.jsx) | `/` |
| `login_screen.dart` | `Login.jsx` | `/login` |
| `register_screen.dart` | `Register.jsx` | `/register` |
| `recovery_screen.dart` | `Recovery.jsx` | `/recovery` |
| `dashboard_screen.dart` | `Dashboard.jsx` | `/dashboard` 🔒 |
| `vault_screen.dart` | `Vault.jsx` | `/vault` 🔒 |
| `plans_screen.dart` | `PreventPlans.jsx` | `/plans` 🔒 |
| `history_screen.dart` | `ActivityHistory.jsx` | `/history` 🔒 |

🔒 = exige login (redireciona para `/login`, como o `Protected` do React).

O visual segue o `index.css` final: preto e branco de alto contraste, fundo quadriculado, eyebrows `[ ASSIM ]`, botões retangulares em fonte mono que invertem a cor no hover, Space Grotesk / DM Sans / IBM Plex Mono.

## Como rodar

1. **Backend no ar** (como no README do projeto original): MySQL com o `schema.sql`, `.env` configurado e `npm run dev` em `backend/` → `http://localhost:3000`.

2. **Criar o projeto Flutter e copiar estes arquivos** (este pacote traz só o código; as pastas `android/`, `ios/`, etc. são geradas pelo Flutter):

   ```bash
   flutter create kryptovault --org br.com.kryptovault
   ```
   Depois copie para dentro de `kryptovault/`, substituindo o que já existir:
   `lib/`, `assets/`, `pubspec.yaml` e `analysis_options.yaml`.

3. **Dependências e execução**

   ```bash
   cd kryptovault
   flutter pub get
   flutter run
   ```

### Endereço da API

Por padrão o app escolhe sozinho:

- Android (emulador): `http://10.0.2.2:3000`
- Web, desktop e simulador iOS: `http://localhost:3000`

Para outro endereço (por exemplo, celular real na mesma rede Wi-Fi):

```bash
flutter run --dart-define=API_URL=http://192.168.0.10:3000
```

### Por plataforma

- **Android**: no `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>` adicione
  `<uses-permission android:name="android.permission.INTERNET"/>` e, na tag `<application>`,
  `android:usesCleartextTraffic="true"` (o backend de desenvolvimento usa `http`, não `https`).
- **Web**: rode na porta que o backend já aceita no CORS (`FRONTEND_ORIGIN=http://localhost:5173`):
  `flutter run -d chrome --web-port=5173`
- **iOS**: o backend em `http` exige uma exceção de ATS no `Info.plist` durante o desenvolvimento
  (`NSAppTransportSecurity` → `NSAllowsLocalNetworking`).

## Como a sessão funciona

O backend identifica o usuário pelo cookie `kv.sid`. No navegador o próprio browser cuida disso; em Android/iOS/desktop o app guarda o cookie (`services/cookie_store.dart`) e o reenvia em cada requisição, e o salva em disco para a sessão sobreviver ao app fechado (equivalente a recarregar a página no React).

## Estrutura

```
lib/
├── main.dart                 # inicialização + verificação de sessão (GET /auth/me)
├── app.dart                  # rotas e proteção de rotas
├── config.dart               # endereço da API
├── theme/app_theme.dart      # cores e fontes (variáveis do index.css)
├── models/models.dart        # usuário, item do cofre, plano, evento...
├── services/                 # api_service (= api.js), auth_state, cookies
├── widgets/                  # app_shell (topbar/rodapé) e componentes (botão, painel, campos)
└── screens/                  # as 8 telas
```

## Observações

- É um protótipo acadêmico, igual ao original: a chave de criptografia fica no servidor (não é zero-knowledge) e não há recuperação de senha implementada.
- As fontes são baixadas pelo pacote `google_fonts` na primeira execução (precisa de internet). Para uso offline, baixe os `.ttf` e declare-os no `pubspec.yaml`.
- Nunca versione o `.env` do backend.
