class Accout {
  // 账户地址
  String address;
  //  余额
  String balance;
  // 私钥
  String privKey;

  Accout(this.address, this.privKey, {this.balance: "0"});

}