import 'package:shared_preferences/shared_preferences.dart';

/// Guarda o cookie de sessão `kv.sid` do backend (express-session).
///
/// No app mobile/desktop o pacote `http` não mantém cookies sozinho, então
/// guardamos o valor aqui (e em disco, para a sessão sobreviver ao app fechado,
/// como o cookie do navegador faz no projeto web).
/// No Flutter Web o navegador cuida do cookie e esta classe não é usada.
class CookieStore {
  static const String _prefsKey = 'kv.sid';

  String? _value;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _value = prefs.getString(_prefsKey);
    } catch (_) {
      _value = null;
    }
  }

  /// Valor para o cabeçalho `Cookie`, ou null se não há sessão.
  String? get header =>
      (_value == null || _value!.isEmpty) ? null : 'kv.sid=$_value';

  /// Lê o cabeçalho `Set-Cookie` da resposta e atualiza a sessão.
  /// (O `http` junta vários Set-Cookie numa única string; por isso a regex.)
  Future<void> updateFrom(String? setCookieHeader) async {
    if (setCookieHeader == null) return;
    final match = RegExp(r'kv\.sid=([^;,\s]*)').firstMatch(setCookieHeader);
    if (match == null) return;
    final value = match.group(1) ?? '';
    // O backend limpa o cookie no logout enviando `kv.sid=;` com data expirada.
    await _save(value.isEmpty ? null : value);
  }

  Future<void> clear() => _save(null);

  Future<void> _save(String? value) async {
    _value = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value == null) {
        await prefs.remove(_prefsKey);
      } else {
        await prefs.setString(_prefsKey, value);
      }
    } catch (_) {
      // Sem persistência a sessão continua valendo até fechar o app.
    }
  }
}
