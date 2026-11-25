import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

import 'cookie_store.dart';

/// No navegador, o cookie HTTP-only é gerenciado pelo próprio browser.
/// `withCredentials` equivale ao `credentials: "include"` do fetch no React.
http.Client createClient(CookieStore store) {
  final client = BrowserClient();
  client.withCredentials = true;
  return client;
}
