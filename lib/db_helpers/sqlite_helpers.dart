// ignore_for_file: avoid_print

import 'dart:io';
import 'package:db_test/data_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../model.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String _path = path.join(documentsDirectory.path, _databaseName);
    //String _path = await getDatabasesPath();
    return await openDatabase(_path, version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY,
            chatId INTEGER NOT NULL,
            text TEXT NOT NULL,
            sender TEXT NOT NULL,
            time TEXT NOT NULL,
            seenTime TEXT NOT NULL
          )
          ''');
  }

  Future insertMyMessages() async {
    late List<Map<String, dynamic>> rows = [];
    getMessages().forEach((message) {
      rows.add(message.toSqlMap());
    });
    await insertMultipleRow('messages', rows);
  }

  Future<List<Message>> get50Messages() async {
    List<Message> messages = [];
    await rawQuery('SELECT * FROM messages ORDER BY id DESC LIMIT 50').then((rows) => {
          for (var row in rows) {messages.add(Message.fromSqlMap(row))}
        });
    return messages;
  }

  Future<List<Message>> getAllMessages() async {
    List<Message> messages = [];
    await readAllRows('messages').then((rows) => {
          for (var row in rows) {messages.add(Message.fromSqlMap(row))}
        });
    return messages;
  }

  Future deleteAllMessages() async {
    await deleteAll('messages').whenComplete(
      () => print('delete messages ends: ' + DateTime.now().toString()),
    );
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future insert(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    await db.insert(table, row);
  }

  Future insertMultipleRow(String table, List<Map<String, dynamic>> rows) async {
    Database db = await instance.database;
    var batch = db.batch();
    for (var raw in rows) {
      batch.insert(table, raw);
    }
    print('batch insert 5k starts: ' + DateTime.now().toString());
    await batch.commit(noResult: true).whenComplete(() {
      print('batch insert 5k ends: ' + DateTime.now().toString());
    });
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of dbColumns.
  Future<List<Map<String, dynamic>>> readAllRows(String table) async {
    print('read all starts: ' + DateTime.now().toString());
    Database db = await instance.database;
    return await db.query(table).whenComplete(() {
      print('read all ends: ' + DateTime.now().toString());
    });
  }

  Future<List<Map<String, dynamic>>> doesExist(String table, String column, dynamic value) async {
    Database db = await instance.database;
    return await db.query(
      table,
      columns: [column],
      where: '$column = ?',
      whereArgs: [value],
    );
  }

  // Fatch form data
  Future<List<Map<String, dynamic>>> readMessages(String table) async {
    String _query = 'SELECT * FROM $table';
    Database db = await instance.database;
    return await db.rawQuery(_query);
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['row'];
    return await db.update(table, row, where: '{?} = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(String table, String column, List args) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$column = ?', whereArgs: args);
  }

  // Deletes all
  Future<int> deleteAll(String table) async {
    print('delete messages start: ' + DateTime.now().toString());
    Database db = await instance.database;
    return await db.delete(table);
  }

  // All of the methods can also be done using raw SQL commands.
  Future<List<Map<String, dynamic>>> rawQuery(String _query) async {
    //String _query = 'SELECT COUNT(*) FROM ${dbTables[0]}';
    print('rawQuery start: ' + DateTime.now().toString());
    Database db = await instance.database;
    return await db.rawQuery(_query).whenComplete(
          () => print('rawQuery start: ' + DateTime.now().toString()),
        );
  }
}
