class Folder {
  final int? id;
  final String name;
  final String color;
  final int? parentId; // Reference to parent folder, null for root folders
  final DateTime createdAt;
  final DateTime updatedAt;

  Folder({
    this.id,
    required this.name,
    this.color = '#3498db', // Default blue color
    this.parentId, // null means it's a root folder
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

  // Check if this folder is a root folder
  bool get isRoot => parentId == null;

  @override
  String toString() {
    return 'Folder(id: $id, name: $name, parentId: $parentId, color: $color)';
  }
}
