import 'package:flutter/foundation.dart';

/// Configuração do app.
///
/// O endereço da API pode ser definido na hora de rodar/compilar:
///   flutter run --dart-define=API_URL=http://192.168.0.10:3000
///
/// Sem `API_URL`, usa um padrão conforme a plataforma:
///  - Android (emulador): 10.0.2.2 aponta para o localhost do computador.
///  - Web, Windows, Linux, macOS e iOS (simulador): localhost.
class AppConfig {
  AppConfig._();

  static const String _fromEnv = String.fromEnvironment('API_URL');

  static String get apiBaseUrl {
    if (_fromEnv.isNotEmpty) {
      return _fromEnv.replaceAll(RegExp(r'/+$'), '');
    }
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
}
