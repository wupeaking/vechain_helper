import 'package:flutter/widgets.dart';

// 自己的ICON
class MyIcon {
  // 二维码
  static const IconData srcode = const _MyIconData(0xe646);
  // 钱包
  static const IconData wallet = const _MyIconData(0xe609);
  // 扫一扫
  static const IconData scan = const _MyIconData(0xe60b);
  // 创建钱包
  static const IconData createWallt = const _MyIconData(0xe619);

  // 地址
  static const IconData address = const _MyIconData(0xe63e);
  // 符号
  static const IconData symbol = const _MyIconData(0xe607);
  // 位数
  static const IconData bits = const _MyIconData(0xe61f);
  // 关于
  static const IconData about = const _MyIconData(0xe6a1);
  // 导入钱包
  static const IconData importWallt = const _MyIconData(0xe621);
  // 切换钱包
  static const IconData change = const _MyIconData(0xe629);
}

class _MyIconData extends IconData {
  const _MyIconData(int codePoint)
      : super(
    codePoint,
    fontFamily: 'selfIcon',
  );
}