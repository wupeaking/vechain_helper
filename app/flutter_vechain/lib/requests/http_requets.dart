import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import '../configure/urls.dart';
import 'dart:convert';
import './vetrequest_models.dart';

Future vetBalance(String address) async {
  // 创建DIO
  var dio = Dio();
  // 设置请求头为 application/x-www-form-urlencoded
  try {
    // dio.options.contentType =
    //     ContentType.parse("application/x-www-form-urlencoded");
    var query = {'address': 'address'};
    Response<Map<String, dynamic>> resp =
        await dio.get(APIS['vetBalances'], queryParameters: query);
    if (resp.statusCode != 200) {
      return "网络请求失败";
    }
    print(resp.data);
    return  VETRequest.fromJson(resp.data);
  } catch (e) {
    return e.toString();
  }
}