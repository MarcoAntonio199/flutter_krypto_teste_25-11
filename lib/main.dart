import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'services/api_service.dart';
import 'services/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carrega o cookie de sessão salvo e prepara o cliente HTTP.
  await Api.instance.init();
  runApp(const KryptoVaultApp());
  // Pergunta ao backend se a sessão ainda é válida (GET /api/auth/me).
  unawaited(AuthState.instance.bootstrap());
}
