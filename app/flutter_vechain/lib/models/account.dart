class Accout {
  // 账户地址
  String address;
  //  余额
  String balance;

  // 
  String vthoBalance;
  // 私钥
  String privKey;

  Accout(this.address, this.privKey, {this.balance: "0", this.vthoBalance: "0"});

}