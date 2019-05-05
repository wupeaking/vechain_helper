class Token {
  // 合约地址
  String address;
  // token 符号
  String symbol;
  // 余额
  String balance;

  static final String tableName = "token";

  // 位数
  int bits;

  int id;

  Token(this.address, this.symbol,  {this.balance: "0", this.bits: 18});

 // toMap 为了写入SQL
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "address": address,
      "symbol": symbol,
      "bits": bits,
    };
    return map;
  }

  static Token fromMap(Map<String, dynamic> map) {
    int id = map["id"];
    String addr = map["address"];
    String sy = map["symbol"];
    int b = map["bits"];
    return Token(addr, sy, bits: b)
      ..id = id;
  }


}