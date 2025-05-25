class Folder {
  /// Special folder ID for the root folder
  static const int rootFolderId = 0;
  final int id;

  /// Reference to parent folder, 0 if it's a root folder. Parent folder for the root folder is itself.
  final int parentId;
  final String name;
  /// If icon is empty string, it means default icon.
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  Folder({
    required this.id,
    required this.name,
    required this.parentId,
    this.icon = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Folder copyWith({
    int? id,
    String? name,
    String? icon,
    int? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'parent_id': parentId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      name: map['name'],
      icon: map['icon'] ?? '#3498db',
      parentId: map['parent_id'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  @override
  String toString() {
    return 'Folder(id: $id, name: $name, parentId: $parentId, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Folder &&
        other.id == id &&
        other.name == name &&
        other.parentId == parentId &&
        other.icon == icon;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ parentId.hashCode ^ icon.hashCode;
  }
}
