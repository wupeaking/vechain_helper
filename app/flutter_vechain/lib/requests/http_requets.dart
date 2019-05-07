import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import '../configure/urls.dart';
import './unsign_tx_models.dart';
import './vetrequest_models.dart';
import './push_tx_models.dart';

Future getBalance(String account, String currency) async {
  // 创建DIO
  var dio = Dio();
  // 设置请求头为 application/x-www-form-urlencoded
  try {
    // dio.options.contentType =
    //     ContentType.parse("application/x-www-form-urlencoded");
    var query = {'currency': currency};
    Response<Map<String, dynamic>> resp =
        await dio.get(APIS['balances']+account, queryParameters: query);
    if (resp.statusCode != 200) {
      return "网络请求失败";
    }
    print(resp.data);
    return  VETRequest.fromJson(resp.data);
  } catch (e) {
    return e.toString();
  }
}

Future unsigntx_request(String from, String to, String amount, String currency, String txType) async {
  // 创建DIO
  var dio = Dio();
  try {
    dio.options.contentType =
        ContentType.parse("application/json");
    var query = {
      'from': from,
      'to': to,
      'amount': amount,
      'currency': currency,
      'txType': txType,
    };
    Response<Map<String, dynamic>> resp =
        await dio.put(APIS['unsignTx'], data: query);
    if (resp.statusCode != 200) {
      return "网络请求失败";
    }
    print(resp.data);
    return  UnsignTxModel.fromJson(resp.data);
  } catch (e) {
    return e.toString();
  }
}

Future pushtx_request(String requestID, String sign) async {
  // 创建DIO
  var dio = Dio();
  try {
    dio.options.contentType =
        ContentType.parse("application/json");
    var query  = {
      "request_id": requestID, 
      "sign": sign
    };
    Response<Map<String, dynamic>> resp =
        await dio.put(APIS['pushTx'], data: query);
    if (resp.statusCode != 200) {
      return "网络请求失败";
    }
    print(resp.data);
    return  PushTxModel.fromJson(resp.data);
  } catch (e) {
    return e.toString();
  }
}