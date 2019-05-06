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

  UnsignTxResult({this.needSignContent, this.requestId});

  UnsignTxResult.fromJson(Map<String, dynamic> json) {
    needSignContent = json['need_sign_content'];
    requestId = json['request_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['need_sign_content'] = this.needSignContent;
    data['request_id'] = this.requestId;
    return data;
  }
}
