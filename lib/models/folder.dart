class Folder {
  /// Special folder ID for the root folder
  static const int rootFolderId = 0;
  static Folder rootFolder() => Folder(id: rootFolderId, name: '(root)', parentId: rootFolderId);
  final int id;
  /// Reference to parent folder, 0 if it's a root folder. Parent folder for the root folder is itself.
  final int parentId; 
  final String name;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Folder({
    required this.id,
    required this.name,
    required this.parentId,
    this.color = '#3498db', // Default blue color
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Folder copyWith({
    int? id,
    String? name,
    String? color,
    int? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'parent_id': parentId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      name: map['name'],
      color: map['color'] ?? '#3498db',
      parentId: map['parent_id'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  @override
  String toString() {
    return 'Folder(id: $id, name: $name, parentId: $parentId, color: $color)';
  }
}
