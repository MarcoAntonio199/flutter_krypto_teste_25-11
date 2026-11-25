import 'package:flutter/foundation.dart';

import '../models/models.dart';
import 'api_service.dart';

/// Estado de autenticação global (o `user`/`loading` do App.jsx).
class AuthState extends ChangeNotifier {
  AuthState._();

  static final AuthState instance = AuthState._();

  AppUser? user;
  bool loading = true;

  /// Pergunta ao backend se já existe uma sessão válida (GET /auth/me).
  Future<void> bootstrap() async {
    try {
      user = await Api.instance.me();
    } catch (_) {
      user = null;
    }
    loading = false;
    notifyListeners();
  }

  void setUser(AppUser? value) {
    user = value;
    notifyListeners();
  }

  /// Encerra a sessão. As telas protegidas redirecionam para /login sozinhas
  /// quando `user` vira null.
  Future<void> logout() async {
    try {
      await Api.instance.logout();
    } catch (_) {
      // Mesmo que o servidor não responda, a sessão local é descartada.
    } finally {
      setUser(null);
    }
  }
}
