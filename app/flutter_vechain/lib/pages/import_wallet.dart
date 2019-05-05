import 'package:flutter/material.dart';
import '../widgets/myicon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../router/routers.dart';
import '../models/privkey.dart';
import '../controller/sql.dart';

//  ImportWalletPage 导入钱包页面
class ImportWalletPage extends StatefulWidget {
  @override
  _ImportWalletPageState createState() => _ImportWalletPageState();
}

class _ImportWalletPageState extends State<ImportWalletPage> {
  bool isCreating = false;
  bool buttonEnable = false;
  TextEditingController privCtl = TextEditingController();
  TextEditingController walletpasswd = TextEditingController();
  TextEditingController walletpasswdck = TextEditingController();
  TextEditingController walletName = TextEditingController();

  // 检查创建钱包是否使能
  _checkBtnEnable() {
    if (privCtl.text != "" &&
        walletpasswd.text != "" &&
        walletpasswdck.text != "" &&
        walletpasswd.text == walletpasswdck.text &&
        walletName.text != "") {
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
    privCtl.addListener(_checkBtnEnable);
    walletpasswd.addListener(_checkBtnEnable);
    walletpasswdck.addListener(_checkBtnEnable);
    walletName.addListener(_checkBtnEnable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("导入钱包"),
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
                  controller: privCtl,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "请输入16进制私钥"),
                  maxLines: 5,
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: TextField(
                  autofocus: true,
                  controller: walletName,
                  decoration: InputDecoration(
                      // labelText: "",
                      hintText: "输入钱包名称",
                      prefixIcon: Icon(
                        MyIcon.wallet,
                        size: 20,
                      )),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: TextField(
                  controller: walletpasswd,
                  decoration: InputDecoration(
                      // labelText: "密码",
                      hintText: "钱包密码",
                      prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: TextField(
                  controller: walletpasswdck,
                  decoration: InputDecoration(
                      // labelText: "密码",
                      hintText: "再次输入钱包密码",
                      prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
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
                    _createWallet(walletName.text, walletpasswd.text);
                  },
                  child: Text(
                    "导入钱包",
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

  _createWallet(String walletName, String pw) async {
    if (!buttonEnable) {
      return;
    }
    // todo:: 此处需要更改
    if (privCtl.text.length != 64 && privCtl.text.length != 66) {
      showInfo("私钥格式错误, ${privCtl.text.length}");
      return;
    }

    // 开启加载动画
    setState(() {
      isCreating = true;
    });

    // 检查钱包名称是否存在
    // 打开数据库
    var db = SQLDAO();
    await db.openSqlite();
    var isExist = await db.isExistWallet(walletName);
    if (isExist) {
      await db.close();
      showInfo("钱包名称已经存在");
      setState(() {
        isCreating = false;
      });
      return;
    }

    // 检查私钥格式是否正确
    if (!PrivkeyManager.checkPrivateKey(privCtl.text)) {
      await db.close();
      showInfo("私钥格式错误");
      setState(() {
        isCreating = false;
      });
      return;
    }

    var pk = PrivkeyManager.fromHexString(privCtl.text);
    pk.passwd = pw;
    pk.walletName = walletName;
    await db.insert(pk);
    await db.close();
    setState(() {
      isCreating = false;
    });

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
                  // 第一次弹回本页面
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
