import 'package:http/http.dart' as http;

import 'cookie_store.dart';

/// Cliente HTTP para Android, iOS e desktop: envia e guarda o cookie de sessão.
class _CookieClient extends http.BaseClient {
  _CookieClient(this._inner, this._store);

  final http.Client _inner;
  final CookieStore _store;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final cookie = _store.header;
    if (cookie != null) {
      request.headers['cookie'] = cookie;
    }
    final response = await _inner.send(request);
    await _store.updateFrom(response.headers['set-cookie']);
    return response;
  }

  @override
  void close() => _inner.close();
}

http.Client createClient(CookieStore store) =>
    _CookieClient(http.Client(), store);
