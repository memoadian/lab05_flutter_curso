import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:lab_05_flutter_curso/models_sqlite/Fav.dart';

class FavHelper {
  //creamos una clase singleton
  static final FavHelper _instance = FavHelper.internal();

  FavHelper.internal();

  //creamos una instancia de esta clase
  factory FavHelper() => _instance;

  //declaramos el nombre de la tabla
  final String tableFav = 'favTable';
  final String columnId = 'id'; //y sus columnas id
  final String columnName = 'name'; // nombre
  final String columnAge = 'age'; //edad
  final String columnImage = 'image'; //imagen

  //declaramos la variable Database
  static Database? _db;

  //obtenemos la base de datos
  Future<Database?> get db async {
    //si ya fue creada
    if (_db != null) {
      return _db; //retornamos la db existente
    }
    //si no, creamos una nueva con la funcion initDb
    _db = await initDb();
    //y la retornamos
    return _db;
  }

  //iniciar base de datos
  initDb() async {
    //obtenemos el path base
    String databasesPath = await getDatabasesPath();
    //obtenemos el path del archivo favs.db
    String path = join(databasesPath, 'favs.db');

    //await deleteDatabase(path); //solo para pruebas

    //abrimos la base de datos
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    //retornamos la base de datos
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableFav($columnId INTEGER PRIMARY KEY, $columnName TEXT, $columnAge TEXT, $columnImage TEXT)');
  }

  Future<int> saveFav(Fav fav) async {
    var dbClient = await db;
    var result = await dbClient!.insert(tableFav, fav.toMap());
    // var result = await dbClient.rawInsert(
    // 'INSERT INTO $tableFav ($columnName, $columnAge) VALUES (\'${fav.name}\', \'${fav.age}\')');

    return result;
  }

  Future<List> getAllFavs() async {
    var dbClient = await db;
    var result = await dbClient!.query(tableFav,
        columns: [columnId, columnName, columnAge, columnImage]);
    // var result = await dbClient.rawQuery('SELECT * FROM $tableFav');

    return result.toList();
  }

  Future<int?> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
      await dbClient!.rawQuery('SELECT COUNT(*) FROM $tableFav'),
    );
  }

  Future<Fav?> getFav(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient!.query(tableFav,
        columns: [columnId, columnName, columnAge, columnImage],
        where: '$columnId = ?',
        whereArgs: [id]);
    // var result = await dbClient.rawQuery('SELECT * FROM $tableFav WHERE $columnId = $id');

    if (result.length > 0) {
      print(result);
      return Fav.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteFav(int? id) async {
    var dbClient = await db;
    return await dbClient!.delete(
      tableFav,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    // return await dbClient.rawDelete('DELETE FROM $tableFav WHERE $columnId = $id');
  }

  Future<int> updateFav(Fav fav) async {
    var dbClient = await db;
    return await dbClient!.update(tableFav, fav.toMap(),
        where: "$columnId = ?", whereArgs: [fav.id]);
    // return await dbClient.rawUpdate(
    // 'UPDATE $tableFav SET $columnName = \'${fav.name}\', $columnAge = \'${fav.age}\'
    // WHERE $columnId = ${fav.id}');
  }

  Future close() async {
    var dbClient = await db;
    return dbClient!.close();
  }
}
