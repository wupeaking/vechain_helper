import 'package:flutter/material.dart';
import '../widgets/card.dart';
import '../widgets/token.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/tokens.dart';
import '../provide/token.dart';
import '../controller/tokensql.dart';
import 'package:provide/provide.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  _loadTokens() async {
    final curTkProvide = Provide.value<TokensState>(context);
    var sql = TokenSQL();
    await sql.openSqlite();
    List<Token> tks = await sql.queryAll();
    await sql.close();
    curTkProvide.changeTokens(tks);
  }

  @override
  Widget build(BuildContext context) {
    // 首页布局
    // 1. 一个类似公交卡组件 显示当前选择的钱包信息
    // 2. 列出当前所有添加的token
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: ScreenUtil.getInstance().setWidth(750),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SelfCard(), 
              // 展示当前token信息
              SelfTokenList(),
            ],
          ),
        ),
      ),
    );
  }
}
