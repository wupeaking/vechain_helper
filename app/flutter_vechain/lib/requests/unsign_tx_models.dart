class UnsignTxModel {
  String code;
  String message;
  UnsignTxResult data;

  UnsignTxModel({this.code, this.message, this.data});

  UnsignTxModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new UnsignTxResult.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class UnsignTxResult {
  String needSignContent;
  String requestId;
  String from;
  String to;
  String amount;
  String txType;

  UnsignTxResult(
      {this.needSignContent,
      this.requestId,
      this.from,
      this.to,
      this.amount,
      this.txType});

  UnsignTxResult.fromJson(Map<String, dynamic> json) {
    needSignContent = json['need_sign_content'];
    requestId = json['request_id'];
    from = json['from'];
    to = json['to'];
    amount = json['amount'];
    txType = json['tx_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['need_sign_content'] = this.needSignContent;
    data['request_id'] = this.requestId;
    data['from'] = this.from;
    data['to'] = this.to;
    data['amount'] = this.amount;
    data['tx_type'] = this.txType;
    return data;
  }
}