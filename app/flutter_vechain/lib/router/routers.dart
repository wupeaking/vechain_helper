import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import './handler.dart';


class GlobalRouter {
  static Router r;

   // 路由路径
  static String root = "/";
  static String createWallet = "/create_wallet";
  static String importWallet = "/import_wallet";
  static String listWallet = "/list_wallet";
  static String addToken = "/add_token";

  static void configureRoutes(Router router) {
    r = router;
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define(root, handler: rootHandler);
    router.define(createWallet, handler: createWalletHandler);
    router.define(importWallet, handler: importWalletHandler);
    router.define(listWallet, handler: listWalletHandler);
    router.define(addToken, handler: addTokenHandler);
  }
}