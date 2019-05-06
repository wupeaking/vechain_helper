class PushTxModel {
  String code;
  String message;
  PushTxResult data;

  PushTxModel({this.code, this.message, this.data});

  PushTxModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new PushTxResult.fromJson(json['data']) : null;
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

class PushTxResult {
  String txId;
  String requestId;

  PushTxResult({this.txId, this.requestId});

  PushTxResult.fromJson(Map<String, dynamic> json) {
    txId = json['tx_id'];
    requestId = json['request_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tx_id'] = this.txId;
    data['request_id'] = this.requestId;
    return data;
  }
}
