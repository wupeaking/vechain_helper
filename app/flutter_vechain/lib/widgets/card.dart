import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controller/sql.dart';
import '../controller/idsql.dart';
import '../models/account.dart';
import '../models/privkey.dart';
import '../widgets/myicon.dart';
import '../router/routers.dart';
import 'package:provide/provide.dart';
import '../provide/wallet.dart';
import '../requests/http_requets.dart';
import '../requests/vetrequest_models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

// 钱包卡组件
class SelfCard extends StatefulWidget {
  @override
  _SelfCardState createState() => _SelfCardState();
}

class _SelfCardState extends State<SelfCard> {
  // 定义当前展示的钱包
  Accout _accout;

  @override
  void initState() {
    super.initState();
    // 尝试从数据库中加载钱包
    _loadWallet();
  }

  _loadWallet() async {
    var sql = SQLDAO();
    await sql.openSqlite();
    List<PrivkeyManager> privs = await sql.queryAll();
    await sql.close();

    if (privs == null) {
      _accout = null;
      return;
    }

    // 查询钱包ID
    var dbID = WalletIDSQL();
    await dbID.openSqlite();
    WalletID wid = await dbID.currentWalletID();
    if (wid == null) {
      wid = WalletID()..id = 0;
    }
    privs.map((e) {
      if (e.id == wid.id) {
        // select = e;
        _accout = Accout(e.addrToString(), e.hexPrivkey());
      }
    });
    if (_accout == null) {
      // select = privs[0];
      _accout = Accout(privs[0].addrToString(), privs[0].hexPrivkey());
    }
    await dbID.close();

    await _request_balance(_accout.address);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // 占满整个宽度
        width: ScreenUtil.getInstance().setWidth(700),
        height: ScreenUtil.getInstance().setHeight(400),
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          //border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
              fit: BoxFit.fill, image: AssetImage("images/ethereum.png")),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(20),
                child: _cardDetailBuild(),
              ),
            ),
            Container(
              // 占位 当有状态发生变化 更新状态
              height: 0,
              child: Provide<CurrentWalletState>(
                builder: (context, child, value) {
                  print("-------------------------");
                  if (value.privKey == null) {
                    return Text("");
                  }

                  _accout = Accout(
                      value.privKey.addrToString(), value.privKey.hexPrivkey(),
                      balance: "0");
                  // 请求网络 更新余额
                  _request_balance(_accout.address);

                  return Text("");
                },
              ),
            ),
          ],
        ));
  }

  // 没有钱包构建
  Widget _noWalletBuild() {
    return Center(
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  MyIcon.wallet,
                  color: Colors.white,
                ),
                onPressed: () {
                  GlobalRouter.r.navigateTo(context, "import_wallet");
                },
                iconSize: 80,
              ),
              Text(
                "导入钱包",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: Text(""),
          ), // 拉伸
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  MyIcon.createWallt,
                  color: Colors.white,
                ),
                onPressed: () {
                  GlobalRouter.r.navigateTo(context, "create_wallet");
                },
                iconSize: 80,
              ),
              Text(
                "创建钱包",
                style: TextStyle(color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _cardDetailBuild() {
    // 如果本地没有发现钱包则显示创建钱包或者导入钱包
    if (_accout == null) {
      return _noWalletBuild();
    }
    // 否则显示当前选择的钱包
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 第一行展示余额
        Expanded(
          child: _firstBuild(),
        ),
        // 第二行展示地址
        Expanded(
          flex: 2,
          child: _secondBuild(),
        ),

        // 第三行展示跳转到此地址详情页
        Expanded(
          child: _thirdBuild(),
        ),
      ],
    );
  }

  Widget _firstBuild() {
    // 展示余额
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          "${_accout.balance}",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil.getInstance().setSp(58)),
        ),
        Text(
          " VET",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil.getInstance().setSp(38)),
        ),
        Expanded(
          flex: 1,
          child: Text(""),
        ), // 拉伸
        IconButton(
          icon: Icon(
            Icons.add_circle,
            color: Colors.white,
          ),
          onPressed: () {
            // 跳转到钱包列表
            GlobalRouter.r.navigateTo(context, "/list_wallet");
          },
        )
      ],
    );
  }

  Widget _secondBuild() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "你的唯链地址:",
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: TextStyle(color: Colors.white30),
          ),
          Text(
            "${_accout.address}",
            style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil.getInstance().setSp(58)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _thirdBuild() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          child: IconButton(
            onPressed: () {
              _showDetails();
              // _request_balance(_accout.address);
            },
            icon: Icon(
              Icons.list,
              color: Colors.white,
              size: 40,
            ),
          ),
        )
      ],
    );
  }

  Future<bool> _request_balance(String addr) async {
    print("请求余额===============>");
    var onValue = await getBalance(addr, "vet");

    if (onValue is String) {
      print("请求异常: ${onValue}");
    } else if (onValue is VETRequest) {
      if(onValue.code != "0") {
        print("请求接口异常: ${onValue.message}");
      }
      _accout.balance = onValue.data[0].balance;
      print("请求成功: ${onValue.data}");
    }

    return true;
  }

  _showDetails() {
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
                  // GlobalRouter.r.pop(context);
                },
              )
            ],
            title: RichText(
              text: TextSpan(children: [
                TextSpan(text: "地址:", style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: '${_accout.address}',
                    style: TextStyle(color: Colors.green, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch("https://testnet.veforge.com/accounts/${_accout.address}/tokenTransfers", forceSafariVC: false);
                      }),
                TextSpan(
                  text: '\n\n VET: ${_accout.balance}',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '',
                ),
              ]),
            ),
          );
        });
  }
}

class DetailDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
