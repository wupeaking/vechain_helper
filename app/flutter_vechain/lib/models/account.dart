class Accout {
  // 账户地址
  String address;
  // Vet 余额
  double balance;
  // 私钥
  String privKey;

  Accout(this.address, this.privKey, {this.balance: 0});

}