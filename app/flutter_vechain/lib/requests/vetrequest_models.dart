class VETRequest {
  String message;
  BalanceResult data;
  int code;

  VETRequest({this.message, this.data, this.code});

  VETRequest.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new BalanceResult.fromJson(json['data']) : null;
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['code'] = this.code;
    return data;
  }
}

class BalanceResult {
  String address;
  String vet;
  String vtho;

  BalanceResult({this.address, this.vet, this.vtho});

  BalanceResult.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    vet = json['vet'];
    vtho = json['vtho'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['vet'] = this.vet;
    data['vtho'] = this.vtho;
    return data;
  }
}
