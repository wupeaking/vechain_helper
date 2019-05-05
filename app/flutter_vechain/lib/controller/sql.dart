import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/privkey.dart';
import './idsql.dart';
import '../models/tokens.dart';

class SQLDAO {
  Database db;

  openSqlite() async {
    // 获取数据库文件的存储路径
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'flutter_vechain.db');

//根据数据库文件路径和数据库版本号创建数据库表
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // 创建钱包数据表
      await db.execute('''
          CREATE TABLE ${PrivkeyManager.tableName} (
            id INTEGER PRIMARY KEY, 
            privkey TEXT, 
            passwd TEXT, 
            walletname TEXT )
          ''');

      // 创建当前选择的钱包数据表
      await db.execute('''
          CREATE TABLE ${WalletID.tableName} (
            id INTEGER, 
            wallet_id TEXT)
          ''');
      // 创建token数据表
      await db.execute('''
          CREATE TABLE ${Token.tableName} (
            id INTEGER PRIMARY KEY, 
            address TEXT,
            symbol TEXT,
            bits INTEGER)
          ''');
    });
  }

  // 插入一条钱包信息
  Future<PrivkeyManager> insert(PrivkeyManager e) async {
    e.id = await db.insert(PrivkeyManager.tableName, e.toMap());
    return e;
  }

  Future<bool> isExistWallet(String name) async {
    List<Map> maps = await db.query(PrivkeyManager.tableName,
        columns: [
          "id",
          "privkey",
          "passwd",
          "walletname",
        ],
        where: 'walletname = ?',
        whereArgs: [name]);
    if (maps == null || maps.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  // 查找所有书籍信息
  Future<List<PrivkeyManager>> queryAll() async {
    List<Map> maps = await db.query(PrivkeyManager.tableName, columns: [
      "id",
      "privkey",
      "passwd",
      "walletname",
    ]);

    if (maps == null || maps.length == 0) {
      return null;
    }

    List<PrivkeyManager> pks = [];
    for (int i = 0; i < maps.length; i++) {
      pks.add(PrivkeyManager.fromMap(maps[i]));
    }
    return pks;
  }

  // 根据ID查找书籍信息
  Future<PrivkeyManager> getPrivkeyManager(int id) async {
    List<Map> maps = await db.query(PrivkeyManager.tableName,
        columns: [
          "id",
          "privkey",
          "passwd",
          "walletname",
        ],
        where: 'id = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return PrivkeyManager.fromMap(maps.first);
    }
    return null;
  }

  // 根据ID删除
  // Future<int> delete(int id) async {
  //   return await db.delete(tableBook, where: '$columnId = ?', whereArgs: [id]);
  // }

  // 更新
  Future<int> update(PrivkeyManager pk) async {
    return await db.update(PrivkeyManager.tableName, pk.toMap(),
        where: 'id = ?', whereArgs: [pk.id]);
  }

  // 记得及时关闭数据库，防止内存泄漏
  close() async {
    await db.close();
  }
}
