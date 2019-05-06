
class VETRequest {
  String code;
  String message;
  List<BalanceResult> data;

  VETRequest({this.code, this.message, this.data});

  VETRequest.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<BalanceResult>();
      json['data'].forEach((v) {
        data.add(new BalanceResult.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BalanceResult {
  String contractAddress;
  String balance;

  BalanceResult({this.contractAddress, this.balance});

  BalanceResult.fromJson(Map<String, dynamic> json) {
    contractAddress = json['contract_address'];
    balance = json['balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['contract_address'] = this.contractAddress;
    data['balance'] = this.balance;
    return data;
  }
}