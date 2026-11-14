import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._init();
  static DbHelper instance = DbHelper._init();
  Database? _database;
  Future<void> _createDb(Database db) async {
    await db.execute("""
CREATE TABLE cart(
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  memberId TEXT NOT NULL,
  productId INTEGER NOT NULL,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  imageUrl TEXT,
  quantity INTEGER NOT NULL DEFAULT 1
);""");
    await db.execute("""
CREATE TABLE category(
  id INTEGER NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  imageUrl TEXT,
  productCount INTEGER NOT NULL DEFAULT 0
);""");
  }

  Future<Database?> _initDb() async {
    String path = join(await getDatabasesPath(), "KhaoSatApp.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => _createDb(db),
    );
  }

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }
}
