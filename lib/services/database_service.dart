import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:folder_authenticator/models/folder.dart';
import 'package:folder_authenticator/models/totp_entry.dart';
import 'package:folder_authenticator/services/encryption_service.dart';

part 'database_service.g.dart';

// Provider for the DatabaseService
@riverpod
DatabaseService databaseService(Ref ref) {
  final encryptionService = ref.watch(encryptionServiceProvider);
  return DatabaseService(encryptionService);
}

class DatabaseService {
  final EncryptionService _encryptionService;
  Database? _database;
  
  DatabaseService(this._encryptionService);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'folder_authenticator.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create folders table
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL,
        parent_id INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES folders (id) ON DELETE CASCADE
      )
    ''');

    // Create TOTP entries table
    await db.execute('''
      CREATE TABLE totp_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        secret TEXT NOT NULL,
        issuer TEXT,
        digits INTEGER NOT NULL DEFAULT 6,
        period INTEGER NOT NULL DEFAULT 30,
        algorithm TEXT NOT NULL DEFAULT 'SHA1',
        folder_id INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE
      )
    ''');

    // Create the root folder
    await _createRootFolder(db);
  }

  Future<void> _createRootFolder(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('folders', {
      'id': Folder.rootFolderId,
      'name': 'Root',
      'icon': '',
      'parent_id': Folder.rootFolderId,
      'created_at': now,
      'updated_at': now,
    });
  }

  // Folder operations
  Future<int> insertFolder(
    String name,
    String icon,
    int parentId,
    int createdAt,
    int updatedAt,
  ) async {
    final db = await database;
    return await db.insert('folders', {
      'name': name,
      'icon': icon,
      'parent_id': parentId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    });
  }

  Future<int> updateFolder(
    int id,
    DateTime updatedAt, {
    String? name,
    String? icon,
    int? parentId,
  }) async {
    final db = await database;
    final Map<String, dynamic> map = {
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
    if (name != null) map['name'] = name;
    if (icon != null) map['icon'] = icon;
    // Prevent changing the parent of the root folder
    if (parentId != null && id != Folder.rootFolderId) {
      map['parent_id'] = parentId;
    }
    return await db.update('folders', map, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFolder(int id) async {
    // Prevent deletion of root folder
    if (id == Folder.rootFolderId) {
      return 0;
    }
    final db = await database;
    return await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Folder>> getFolders(int parentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'folders',
      where: 'parent_id = ?',
      whereArgs: [parentId],
    );
    return List.generate(maps.length, (i) => Folder.fromMap(maps[i]));
  }

  Future<Folder?> getFolder(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Folder.fromMap(maps.first);
    }
    return null;
  }

  // TOTP entry operations
  Future<int> insertTotpEntry(
    String name,
    String secret,
    String issuer,
    int digits,
    int period,
    String algorithm,
    int folderId,
  ) async {
    // Encrypt the secret before storing
    final encryptedSecret = await _encryptionService.encrypt(secret);
    
    final db = await database;
    final map = {
      'name': name,
      'secret': encryptedSecret,
      'issuer': issuer,
      'digits': digits,
      'period': period,
      'algorithm': algorithm,
      'folder_id': folderId,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    return await db.insert('totp_entries', map);
  }

  Future<int> updateTotpEntry(
    int id,
    String? name,
    String? issuer,
    int? folderId,
    DateTime updatedAt,
  ) async {
    final db = await database;
    final Map<String, dynamic> map = {
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
    if (name != null) map['name'] = name;
    if (issuer != null) map['issuer'] = issuer;
    if (folderId != null) map['folder_id'] = folderId;
    return await db.update(
      'totp_entries',
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTotpEntry(int id) async {
    final db = await database;
    return await db.delete('totp_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TotpEntry>> getTotpEntries({required int folderId}) async {
    final db = await database;
    String? whereClause;
    List<dynamic>? whereArgs;

    whereClause = 'folder_id = ?';
    whereArgs = [folderId];

    final List<Map<String, dynamic>> maps = await db.query(
      'totp_entries',
      where: whereClause,
      whereArgs: whereArgs,
    );
    
    // Decrypt the secrets before returning
    final entries = <TotpEntry>[];
    for (final map in maps) {
      final encryptedSecret = map['secret'] as String;
      final decryptedSecret = await _encryptionService.decrypt(encryptedSecret);
      
      // Create a new map with the decrypted secret
      final decryptedMap = Map<String, dynamic>.from(map);
      decryptedMap['secret'] = decryptedSecret;
      
      entries.add(TotpEntry.fromMap(decryptedMap));
    }
    
    return entries;
  }

  Future<TotpEntry?> getTotpEntry(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'totp_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      final map = maps.first;
      final encryptedSecret = map['secret'] as String;
      final decryptedSecret = await _encryptionService.decrypt(encryptedSecret);
      
      // Create a new map with the decrypted secret
      final decryptedMap = Map<String, dynamic>.from(map);
      decryptedMap['secret'] = decryptedSecret;
      
      return TotpEntry.fromMap(decryptedMap);
    }
    
    return null;
  }
}
