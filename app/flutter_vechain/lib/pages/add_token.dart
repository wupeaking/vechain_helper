import 'package:flutter/material.dart';
import '../widgets/myicon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../router/routers.dart';
import '../models/tokens.dart';
import '../controller/tokensql.dart';
import '../provide/token.dart';
import 'package:provide/provide.dart';

// 添加token页面
class AddTokenPage extends StatefulWidget {
  @override
  _AddTokenPageState createState() => _AddTokenPageState();
}

class _AddTokenPageState extends State<AddTokenPage> {
  TextEditingController tokenName = TextEditingController();
  TextEditingController tokenSymbol = TextEditingController();
  TextEditingController tokenBits = TextEditingController();

  bool buttonEnable = false;
  // 是否正在创建
  bool isCreating = false;

  // 检查创建钱包是否使能
  _checkBtnEnable() {
    if (tokenName.text != "" &&
        tokenSymbol.text != "" &&
        tokenBits.text != "" ) {
      setState(() {
        buttonEnable = true;
      });
    } else {
      setState(() {
        buttonEnable = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    tokenName.addListener(_checkBtnEnable);
    tokenSymbol.addListener(_checkBtnEnable);
    tokenBits.addListener(_checkBtnEnable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("添加Token"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(80)),
          padding: EdgeInsets.only(
              left: ScreenUtil.getInstance().setWidth(40),
              right: ScreenUtil.getInstance().setWidth(40)),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: TextField(
                  autofocus: true,
                  controller: tokenName,
                  decoration: InputDecoration(
                      // labelText: "",
                      hintText: "输入token地址",
                      prefixIcon: Icon(
                        MyIcon.address,
                        size: 20,
                      )),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: TextField(
                  controller: tokenSymbol,
                  decoration: InputDecoration(
                      // labelText: "密码",
                      hintText: "symbol",
                      prefixIcon: Icon(MyIcon.symbol)),
                  obscureText: false,
                  
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: TextField(
                  controller: tokenBits,
                  decoration: InputDecoration(
                      // labelText: "密码",
                      hintText: "bits",
                      prefixIcon: Icon(MyIcon.bits)),
                  keyboardType: TextInputType.number,
                ),
              ),
              Container(
                width: double.maxFinite,
                height: ScreenUtil.getInstance().setHeight(90),
                child: FlatButton(
                  color: buttonEnable
                      ? Color.fromRGBO(82, 195, 216, 1)
                      : Colors.grey,
                  onPressed: () {
                    _addToken(tokenName.text, tokenSymbol.text, int.parse(tokenBits.text));
                  },
                  child: Text(
                    "添加Token",
                    style:
                        TextStyle(fontSize: ScreenUtil.getInstance().setSp(35)),
                  ),
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              _loadingBuild(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingBuild() {
    if (isCreating) {
      print("is loading");
      return Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    return Container(
      width: 0,
      height: 0,
    );
  }

  showInfo(String content) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: <Widget>[
              RaisedButton(
                color: Color.fromRGBO(82, 195, 216, 1),
                textColor: Colors.white,
                child: Text("确定"),
                onPressed: () {
                  GlobalRouter.r.pop(context);
                },
              )
            ],
            title: Text(content),
          );
        });
  }

  _addToken(String tokenAddr, String symbol, int bits ) async {
    if (!buttonEnable) {
      return;
    }
    // 开启加载动画
    setState(() {
      isCreating = true;
    });

    var token = Token(tokenAddr, symbol, bits: bits);
    // 打开数据库
    var db = TokenSQL();
    await db.openSqlite();
    var isExist = await db.isExist(tokenAddr);
    if (isExist) {
      await db.close();
      showInfo("token已经被添加");
      setState(() {
        isCreating = false;
      });
      return;
    }

    await db.insert(token);
    await db.close();
    setState(() {
      isCreating = false;
    });

    final cur =  Provide.value<TokensState>(context);
    if(cur.tokens != null){
      var tks = cur.tokens;
      tks.add(token);
      cur.changeTokens(tks);
    }
    
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: <Widget>[
              RaisedButton(
                color: Color.fromRGBO(82, 195, 216, 1),
                textColor: Colors.white,
                child: Text("确定"),
                onPressed: () {
                  // 第一次弹回本面
                  GlobalRouter.r.pop(context);
                  // 第二次弹回上一个页面
                  GlobalRouter.r.pop(context);
                },
              )
            ],
            title: Text("创建成功"),
          );
        });
  }
}
