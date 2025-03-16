import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/models/totp_entry.dart';

// Provider for the DatabaseService
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'totp_folder.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create folders table
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT NOT NULL,
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
        folder_id INTEGER,
        digits INTEGER NOT NULL,
        period INTEGER NOT NULL,
        algorithm TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE SET NULL
      )
    ''');
  }

  // Folder operations
  Future<int> insertFolder(Folder folder) async {
    final db = await database;
    return await db.insert('folders', folder.toMap());
  }

  Future<int> updateFolder(Folder folder) async {
    final db = await database;
    return await db.update(
      'folders',
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  Future<int> deleteFolder(int id) async {
    final db = await database;
    return await db.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Folder>> getFolders({int? parentId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'folders',
      where: parentId != null ? 'parent_id = ?' : 'parent_id IS NULL',
      whereArgs: parentId != null ? [parentId] : null,
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
  Future<int> insertTotpEntry(TotpEntry entry) async {
    final db = await database;
    return await db.insert('totp_entries', entry.toMap());
  }

  Future<int> updateTotpEntry(TotpEntry entry) async {
    final db = await database;
    return await db.update(
      'totp_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteTotpEntry(int id) async {
    final db = await database;
    return await db.delete(
      'totp_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
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
    return List.generate(maps.length, (i) => TotpEntry.fromMap(maps[i]));
  }

  Future<TotpEntry?> getTotpEntry(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'totp_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return TotpEntry.fromMap(maps.first);
    }
    return null;
  }
}
