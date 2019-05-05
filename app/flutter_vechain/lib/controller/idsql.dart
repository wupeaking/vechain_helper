import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class WalletID {
  static final String tableName = "wallet_id_table";
  int id;
  // toMap 为了写入SQL
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "id": id,
      "wallet_id": "wallet_id",
    };
    return map;
  }

  static WalletID fromMap(Map<String, dynamic> map) {
    int id = map["id"];
    return WalletID()..id = id;
  }
}

// 查询当前选择的钱包ID
class WalletIDSQL {
  Database db;

  openSqlite() async {
    // 获取数据库文件的存储路径
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'flutter_vechain.db');

//根据数据库文件路径和数据库版本号创建数据库表
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // 创建数据表
      await db.execute('''
          CREATE TABLE ${WalletID.tableName} (
            id INTEGER, 
            wallet_id TEXT)
          ''');
    });
  }

  // 插入当前ID
  Future<WalletID> replaceInto(WalletID e) async {
    List<Map> maps = await db.query(WalletID.tableName,
        columns: [
          "id",
          "wallet_id",
        ],
        where: 'wallet_id = ?',
        whereArgs: ["wallet_id"]);
    if (maps == null || maps.length == 0) {
      // 直接插入 
      e.id = await db.insert(WalletID.tableName, e.toMap());
      return e;
    } else {
      // 更新
      await db.update(WalletID.tableName, e.toMap(), where: 'wallet_id = ?', whereArgs: ["wallet_id"]);
      return e;
    }
  }


  // 根据ID查找书籍信息
  Future<WalletID> currentWalletID() async {
    List<Map> maps = await db.query(WalletID.tableName,
        columns: [
          "id",
        ],
        where: 'wallet_id= ?',
        whereArgs: ['wallet_id']);
    if (maps.length > 0) {
      return WalletID.fromMap(maps.first);
    }
    return null;
  }

  // 记得及时关闭数据库，防止内存泄漏
  close() async {
    await db.close();
  }
}
