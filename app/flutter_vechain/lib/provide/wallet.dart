import 'package:flutter/material.dart';
import '../models/privkey.dart';

// 代表当前钱包数据
class CurrentWalletState with ChangeNotifier {
  PrivkeyManager privKey;

  changePrivKey(PrivkeyManager p) {
    privKey = p;
    notifyListeners();
  }
}
