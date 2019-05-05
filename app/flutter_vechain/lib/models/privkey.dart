import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/src/utils/crypto.dart' as crypto;
import "package:web3dart/src/utils/numbers.dart" as numbers;
import 'dart:convert';
import 'dart:math';

dmeo() {
  // 加载私钥
  Credentials fromHex = Credentials.fromPrivateKeyHex(
      "FE63CAA490F55068F89FF4A5E4B5FA94CCF2A32F8CDCF02555B2B0290AB00CFB");

  //List<int> list = '中文'.codeUnits;

  List<int> list = Utf8Encoder().convert('hello world');

  //String.fromCharCodes (inputAsUint8List)
  Uint8List bytes = Uint8List.fromList(list);
  crypto.MsgSignature msgSign =
      crypto.sign(crypto.sha3(bytes), numbers.intToBytes(fromHex.privateKey));
  print(numbers.bytesToHex(numbers.intToBytes(msgSign.r)));
  print(numbers.bytesToHex(numbers.intToBytes(msgSign.s)));
  print(numbers.toHex(msgSign.v));

  print(numbers.bytesToHex(crypto.sha3(bytes)));
}

// PrivkeyManager 私钥管理
class PrivkeyManager {
  Credentials c;
  String passwd; // 私钥密码
  String walletName;
  int id;
  static String tableName = "wallet";

  PrivkeyManager(this.c, {this.passwd: "", this.walletName: ""});

  static PrivkeyManager randomGenerate() {
    var rng = Random.secure();
    return PrivkeyManager(Credentials.createRandom(rng));
  }

  static bool checkPrivateKey(String priv) {
    try {
      Credentials.fromPrivateKeyHex(priv);
    } catch (e) {
      return false;
    }
    return true;
  }

  static PrivkeyManager fromHexString(String priv) {
    if (priv.length == 66) {
      return PrivkeyManager(Credentials.fromPrivateKeyHex(priv.substring(2)));
    }
    return PrivkeyManager(Credentials.fromPrivateKeyHex(priv));
  }

  static PrivkeyManager fromMap(Map<String, dynamic> map) {
    int id = map["id"];
    String pri = map["privkey"];
    String pw = map["passwd"];
    String wn = map["walletname"];
    return PrivkeyManager(Credentials.fromPrivateKeyHex(pri),
        passwd: pw, walletName: wn)
      ..id = id;
  }

  String addrToString() {
    return c.address.toString();
  }

  // 十六进制格式的私钥
  String hexPrivkey() {
    return numbers.bytesToHex(numbers.intToBytes(c.privateKey));
  }

  //
  setPasswd(String pw) {
    passwd = pw;
  }

  // toMap 为了写入SQL
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "privkey": hexPrivkey(),
      "passwd": passwd,
      "walletname": walletName,
    };
    return map;
  }
}
