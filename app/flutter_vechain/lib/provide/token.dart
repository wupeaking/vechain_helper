import 'package:flutter/material.dart';
import '../models/tokens.dart';

// 代表当前token列表数据
class TokensState with ChangeNotifier {
  List<Token> tokens = [];

  changeTokens(List<Token> l) {
    tokens = l;
    notifyListeners();
  }
}
