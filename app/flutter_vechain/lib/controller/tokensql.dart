import '../models/tokens.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TokenSQL {
  Database db;

  openSqlite() async {
    // 获取数据库文件的存储路径
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'flutter_vechain.db');

//根据数据库文件路径和数据库版本号创建数据库表
    db = await openDatabase(
      path,
      version: 1,
    );
  }

  // 插入一条钱包信息
  Future<Token> insert(Token e) async {
    e.id = await db.insert(Token.tableName, e.toMap());
    return e;
  }

  Future<bool> isExist(String address) async {
    List<Map> maps = await db.query(Token.tableName,
        columns: [
          "id",
        ],
        where: 'address = ?',
        whereArgs: [address]);
    if (maps == null || maps.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  // 查找所有
  Future<List<Token>> queryAll() async {
    List<Map> maps = await db.query(Token.tableName, columns: [
      "id",
      "address",
      "symbol",
      "bits",
    ]);

    if (maps == null || maps.length == 0) {
      return null;
    }

    List<Token> tks = [];
    for (int i = 0; i < maps.length; i++) {
      tks.add(Token.fromMap(maps[i]));
    }
    return tks;
  }

  // 根据ID查找书籍信息
  Future<Token> getToken(String address) async {
    List<Map> maps = await db.query(Token.tableName,
        columns: [
          "id",
          "address",
          "symbol",
          "bits",
        ],
        where: 'address = ?',
        whereArgs: [address]);
    if (maps.length > 0) {
      return Token.fromMap(maps.first);
    }
    return null;
  }

  // 更新
  Future<int> update(Token e) async {
    return await db.update(Token.tableName, e.toMap(),
        where: 'address = ?', whereArgs: [e.address]);
  }

  // 记得及时关闭数据库，防止内存泄漏
  close() async {
    await db.close();
  }
}
