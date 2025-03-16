import 'dart:convert';

class TotpEntry {
  final int? id;
  final String name;
  final String secret;
  final String issuer;
  final int? folderId;
  final List<String> tags;
  final int digits;
  final int period;
  final String algorithm;
  final DateTime createdAt;
  final DateTime updatedAt;

  TotpEntry({
    this.id,
    required this.name,
    required this.secret,
    this.issuer = '',
    this.folderId,
    this.tags = const [],
    this.digits = 6,
    this.period = 30,
    this.algorithm = 'SHA1',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TotpEntry copyWith({
    int? id,
    String? name,
    String? secret,
    String? issuer,
    int? folderId,
    List<String>? tags,
    int? digits,
    int? period,
    String? algorithm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TotpEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      secret: secret ?? this.secret,
      issuer: issuer ?? this.issuer,
      folderId: folderId ?? this.folderId,
      tags: tags ?? this.tags,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      algorithm: algorithm ?? this.algorithm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'secret': secret,
      'issuer': issuer,
      'folder_id': folderId,
      'tags': jsonEncode(tags),
      'digits': digits,
      'period': period,
      'algorithm': algorithm,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory TotpEntry.fromMap(Map<String, dynamic> map) {
    return TotpEntry(
      id: map['id'],
      name: map['name'],
      secret: map['secret'],
      issuer: map['issuer'] ?? '',
      folderId: map['folder_id'],
      tags: List<String>.from(jsonDecode(map['tags'] ?? '[]')),
      digits: map['digits'] ?? 6,
      period: map['period'] ?? 30,
      algorithm: map['algorithm'] ?? 'SHA1',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  @override
  String toString() {
    return 'TotpEntry(id: $id, name: $name, issuer: $issuer, folderId: $folderId, tags: $tags)';
  }
}
