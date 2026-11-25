import 'package:flutter/material.dart';

import 'models/models.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/plans_screen.dart';
import 'screens/recovery_screen.dart';
import 'screens/register_screen.dart';
import 'screens/vault_screen.dart';
import 'services/auth_state.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

class KryptoVaultApp extends StatelessWidget {
  const KryptoVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KryptoVault — Cofre Digital',
      debugShowCheckedModeBanner: false,
      theme: KvTheme.dark(),
      darkTheme: KvTheme.dark(),
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

/// Rotas equivalentes às do React Router (App.jsx).
/// A troca de página é instantânea, como num site.
Route<dynamic> _onGenerateRoute(RouteSettings settings) {
  final Widget page;
  switch (settings.name) {
    case '/login':
      page = _Gate(route: '/login', builder: (_) => const LoginScreen());
      break;
    case '/register':
      page = _Gate(route: '/register', builder: (_) => const RegisterScreen());
      break;
    case '/recovery':
      page = _Gate(route: '/recovery', builder: (_) => const RecoveryScreen());
      break;
    case '/dashboard':
      page = _Gate(
        route: '/dashboard',
        protected: true,
        builder: (user) => DashboardScreen(user: user),
      );
      break;
    case '/vault':
      page = _Gate(
        route: '/vault',
        protected: true,
        builder: (_) => const VaultScreen(),
      );
      break;
    case '/plans':
      page = _Gate(
        route: '/plans',
        protected: true,
        builder: (_) => const PlansScreen(),
      );
      break;
    case '/history':
      page = _Gate(
        route: '/history',
        protected: true,
        builder: (_) => const HistoryScreen(),
      );
      break;
    default:
      page = _Gate(route: '/', builder: (_) => const LandingScreen());
  }

  return PageRouteBuilder<void>(
    settings: settings,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) => page,
  );
}

/// Aplica o shell e a proteção de rota (`Protected` do App.jsx).
class _Gate extends StatelessWidget {
  const _Gate({
    required this.route,
    required this.builder,
    this.protected = false,
  });

  final String route;
  final bool protected;
  final Widget Function(AppUser? user) builder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthState.instance,
      builder: (context, _) {
        final auth = AuthState.instance;

        if (auth.loading) return const _LoadingScreen();
        if (protected && auth.user == null) return const _Redirect('/login');

        return AppShell(route: route, child: builder(auth.user));
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KV.black,
      body: Center(
        child: Text(
          'Carregando KryptoVault…',
          style: KV.body(color: const Color(0xFFAAAAAA)),
        ),
      ),
    );
  }
}

/// `<Navigate to="/login" replace />`
class _Redirect extends StatefulWidget {
  const _Redirect(this.route);

  final String route;

  @override
  State<_Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<_Redirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(widget.route, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: KV.black);
}
