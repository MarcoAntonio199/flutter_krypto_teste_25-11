import 'dart:convert';

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

class AppUser {
  const AppUser({required this.id, required this.email});

  final int id;
  final String email;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: _asInt(json['id']),
        email: (json['email'] ?? '').toString(),
      );
}

/// Item do cofre, como devolvido por GET /api/vault.
/// O backend entrega `content: { content: "<texto>" }`; guardamos o texto bruto.
class VaultItem {
  const VaultItem({
    required this.id,
    required this.title,
    required this.category,
    required this.rawContent,
  });

  final int id;
  final String title;
  final String category;
  final String rawContent;

  factory VaultItem.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    String raw = '';
    if (content is Map && content['content'] != null) {
      raw = content['content'].toString();
    }
    return VaultItem(
      id: _asInt(json['id']),
      title: (json['title'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      rawContent: raw,
    );
  }
}

/// Equivalente a readContent() do Vault.jsx: o conteúdo pode ser um JSON
/// estruturado (`__kryptovault_format == 1`) ou texto livre (registros antigos).
class VaultContent {
  const VaultContent._({this.fields, this.legacy});

  final Map<String, dynamic>? fields;
  final String? legacy;

  bool get isLegacy => fields == null;

  String? field(String key) {
    final value = fields?[key];
    return value is String ? value : null;
  }

  factory VaultContent.parse(String raw) {
    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map<String, dynamic> &&
          parsed['__kryptovault_format'] == 1) {
        return VaultContent._(fields: parsed);
      }
    } catch (_) {
      // Compatibilidade com registros antigos em texto livre.
    }
    return VaultContent._(legacy: raw);
  }
}

class ContinuityPlan {
  const ContinuityPlan({
    required this.id,
    required this.title,
    required this.instructions,
    required this.waitingDays,
    required this.status,
  });

  final int id;
  final String title;
  final String instructions;
  final int waitingDays;
  final String status;

  factory ContinuityPlan.fromJson(Map<String, dynamic> json) => ContinuityPlan(
        id: _asInt(json['id']),
        title: (json['title'] ?? '').toString(),
        instructions: (json['instructions'] ?? '').toString(),
        waitingDays: _asInt(json['waitingDays']),
        status: (json['status'] ?? '').toString(),
      );
}

class ChecklistItem {
  const ChecklistItem({required this.id, required this.label});

  final String id;
  final String label;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: (json['id'] ?? '').toString(),
        label: (json['label'] ?? '').toString(),
      );
}

class ActivityEvent {
  const ActivityEvent({required this.event, required this.createdAt});

  final String event;
  final DateTime? createdAt;

  factory ActivityEvent.fromJson(Map<String, dynamic> json) => ActivityEvent(
        event: json['event'] is String
            ? json['event'] as String
            : 'evento_desconhecido',
        createdAt: _parseDate(json['createdAt']),
      );
}

class DashboardData {
  const DashboardData({
    required this.itemCount,
    required this.planCount,
    required this.events,
  });

  final int itemCount;
  final int planCount;
  final List<ActivityEvent> events;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'];
    return DashboardData(
      itemCount: _asInt(json['itemCount']),
      planCount: _asInt(json['planCount']),
      events: rawEvents is List
          ? rawEvents
              .whereType<Map<String, dynamic>>()
              .map(ActivityEvent.fromJson)
              .toList()
          : const [],
    );
  }
}
