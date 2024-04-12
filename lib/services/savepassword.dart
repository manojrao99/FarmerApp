import 'dart:async';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final String tableName = 'user';
  Database? _db;

  Future<void> initDatabase() async {
    _db = await openDatabase('my_database.db', version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
        CREATE TABLE $tableName (
          id INTEGER PRIMARY KEY,
          username TEXT NOT NULL,
          password TEXT NOT NULL
        )
      ''');
        });
  }

  Future<void> closeDatabase() async {
    await _db?.close();
  }

  Future<int> insertUser(String username, String password) async {
    // Clear existing user data (assuming there is only one user)
    await _db!.delete(tableName);

    // Insert the new user data
    return await _db!.insert(tableName, {
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, dynamic>?> getUser() async {
    final List<Map<String, dynamic>> maps = await _db!.query(tableName);
    if (maps.isEmpty) {
      return null;
    }
    return maps.first;
  }

  Future<int> updateUser(String username, String password) async {
    // Get the current user data
    final currentUser = await getUser();

    // If a user exists, update the data; otherwise, insert a new user
    if (currentUser != null) {
      return await _db!.update(
        tableName,
        {
          'username': username,
          'password': password,
        },
        where: 'id = ?',
        whereArgs: [currentUser['id']],
      );
    } else {
      return await insertUser(username, password);
    }
  }

  Future<int> deleteUser() async {
    final currentUser = await getUser();
    if (currentUser != null) {
      return await _db!.delete(tableName, where: 'id = ?', whereArgs: [currentUser['id']]);
    }
    return 0; // No user to delete
  }
}
