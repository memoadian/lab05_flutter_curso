import 'dart:async';
 
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:lab_02/models_sqlite/Fav.dart';
 
class FavHelper {
  static final FavHelper _instance = new FavHelper.internal();
 
  factory FavHelper() => _instance;
 
  final String tableFav = 'favTable';
  final String columnId = 'id';
  final String columnName = 'name';
  final String columnAge = 'age';
  final String columnImage = 'image';
 
  static Database _db;
 
  FavHelper.internal();
 
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
 
    return _db;
  }
 
  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'favs.db');
 
    //await deleteDatabase(path); // just for testing
 
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }
 
  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableFav($columnId INTEGER PRIMARY KEY, $columnName TEXT, $columnAge TEXT, $columnImage TEXT)');
  }
 
  Future<int> saveFav(Fav fav) async {
    var dbClient = await db;
    var result = await dbClient.insert(tableFav, fav.toMap());
    // var result = await dbClient.rawInsert(
    // 'INSERT INTO $tableFav ($columnName, $columnAge) VALUES (\'${fav.name}\', \'${fav.age}\')');
 
    return result;
  }
 
  Future<List> getAllFavs() async {
    var dbClient = await db;
    var result = await dbClient.query(tableFav, columns: [columnId, columnName, columnAge, columnImage]);
    // var result = await dbClient.rawQuery('SELECT * FROM $tableFav');
 
    return result.toList();
  }
 
  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $tableFav'));
  }
 
  Future<Fav> getFav(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(tableFav,
        columns: [columnId, columnName, columnAge, columnImage],
        where: '$columnId = ?',
        whereArgs: [id]);
        // var result = await dbClient.rawQuery('SELECT * FROM $tableFav WHERE $columnId = $id');
 
    if (result.length > 0) {
      return new Fav.fromMap(result.first);
    }
 
    return null;
  }
 
  Future<int> deleteFav(int id) async {
    var dbClient = await db;
    return await dbClient.delete(tableFav, where: '$columnId = ?', whereArgs: [id]);
    // return await dbClient.rawDelete('DELETE FROM $tableFav WHERE $columnId = $id');
  }
 
  Future<int> updateFav(Fav fav) async {
    var dbClient = await db;
    return await dbClient.update(tableFav, fav.toMap(), where: "$columnId = ?", whereArgs: [fav.id]);
    // return await dbClient.rawUpdate(
    // 'UPDATE $tableFav SET $columnName = \'${fav.name}\', $columnAge = \'${fav.age}\' WHERE $columnId = ${fav.id}');
  }
 
  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}