import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/models.dart';
import 'client_factory_io.dart'
    if (dart.library.js_interop) 'client_factory_web.dart';
import 'cookie_store.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Equivalente ao `services/api.js` do projeto React.
class Api {
  Api._();

  static final Api instance = Api._();

  final CookieStore _cookies = CookieStore();
  late final http.Client _client;

  Future<void> init() async {
    await _cookies.load();
    _client = createClient(_cookies);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api$path');
    final request = http.Request(method, uri);
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    if (body != null) {
      request.body = jsonEncode(body);
    }

    http.Response response;
    try {
      final streamed =
          await _client.send(request).timeout(const Duration(seconds: 15));
      response = await http.Response.fromStream(streamed);
    } catch (_) {
      throw ApiException(
        'Não foi possível conectar ao servidor. '
        'Verifique sua conexão e o endereço da API.',
      );
    }

    var data = <String, dynamic>{};
    if (response.statusCode != 204 && response.bodyBytes.isNotEmpty) {
      try {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {
        // Corpo que não é JSON: segue com o mapa vazio.
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = data['error'];
      throw ApiException(
        error is String ? error : 'Não foi possível concluir a operação.',
      );
    }
    return data;
  }

  // ---- Autenticação -------------------------------------------------------

  Future<AppUser> me() async {
    final data = await _request('GET', '/auth/me');
    final user = data['user'];
    if (user is! Map<String, dynamic>) {
      throw ApiException('Sessão não autenticada.');
    }
    return AppUser.fromJson(user);
  }

  Future<AppUser> register(String email, String password) async {
    final data = await _request(
      'POST',
      '/auth/register',
      body: {'email': email, 'password': password},
    );
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<AppUser> login(String email, String password) async {
    final data = await _request(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _request('POST', '/auth/logout');
    } finally {
      await _cookies.clear();
    }
  }

  // ---- Painel e histórico -------------------------------------------------

  Future<DashboardData> dashboard() async {
    final data = await _request('GET', '/dashboard');
    return DashboardData.fromJson(data);
  }

  // ---- Cofre --------------------------------------------------------------

  Future<List<VaultItem>> items() async {
    final data = await _request('GET', '/vault');
    final list = data['items'];
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(VaultItem.fromJson)
        .toList();
  }

  Future<void> addItem(Map<String, dynamic> item) =>
      _request('POST', '/vault', body: item);

  Future<void> updateItem(int id, Map<String, dynamic> item) =>
      _request('PUT', '/vault/$id', body: item);

  Future<void> deleteItem(int id) => _request('DELETE', '/vault/$id');

  // ---- Continuidade -------------------------------------------------------

  Future<List<ContinuityPlan>> plans() async {
    final data = await _request('GET', '/continuity/plans');
    final list = data['plans'];
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ContinuityPlan.fromJson)
        .toList();
  }

  /// Devolve a mensagem do servidor ("Plano salvo. ...").
  Future<String> addPlan(Map<String, dynamic> plan) async {
    final data = await _request('POST', '/continuity/plans', body: plan);
    return (data['message'] ?? 'Plano salvo.').toString();
  }

  Future<List<ChecklistItem>> checklist() async {
    final data = await _request('GET', '/continuity/checklist');
    final list = data['checks'];
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ChecklistItem.fromJson)
        .toList();
  }
}
