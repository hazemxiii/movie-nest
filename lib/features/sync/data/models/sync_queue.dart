import 'dart:convert';

class SyncQueue {
  SyncQueue({required this.operations});
  final List<SyncOperation> operations;
}

class SyncOperation {
  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      id: map['id'],
      type: map['type'],
      entityType: map['entityType'],
      entityId: map['entityId'],
      url: map['url'],
      method: map['method'],
      body: jsonDecode(map['body']),
      createdAt: DateTime.parse(map['createdAt']),
      tries: map['tries'] ?? 0,
    );
  }
  SyncOperation({
    required this.id,
    required this.url,
    required this.type,
    required this.method,
    required this.entityId,
    required this.body,
    required this.entityType,
    required this.createdAt,
    this.tries = 0,
  });
  final String id;
  final String type;
  final String entityType;
  final String entityId;
  final String url;
  final String method;
  final int tries;
  final Map<String, dynamic> body;
  final DateTime createdAt;
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'entityType': entityType,
      'entityId': entityId,
      'url': url,
      'method': method,
      'tries': tries,
      'body': jsonEncode(body),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SyncOperationType {
  static const String create = 'create';
}

class SyncOperationEntityType {
  static const String nestList = 'nestList';
}

// enum SyncOperationType { create }

// enum SyncOperationEntityType { nestList }
