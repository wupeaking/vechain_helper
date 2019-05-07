import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import '../provide/wallet.dart';
import '../models/privkey.dart';
import '../requests/http_requets.dart';
import '../requests/push_tx_models.dart';
import '../router/routers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

// 发起交易页

class TransactionPage extends StatefulWidget {
  // 发起方地址
  String to;
  // 金额
  String value;
  // 携带数据
  String data;
  // 币种
  String currency;
  // txType 交易类型 VET VTHO ERC20 CALL
  String txType;
  // 待签名内容
  String needSign;
  // 请求ID
  String requestID;
  TransactionPage(this.to, this.value, this.data, this.currency, this.txType,
      this.needSign, this.requestID)
      : super();

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool isSending = false;
  List<Widget> _listW = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cur = Provide.value<CurrentWalletState>(context);
    if (cur.privKey == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text("发起交易"),
          ),
          body: Center(
            child: Text("当前钱包不存在, 不能创建任何交易~"),
          ));
    }

    _listW.clear();
    _listW.add(_coustomText("发起方地址:"));
    _listW.add(_coustomTextFiled(cur.privKey.addrToString()));

    _listW.add(_coustomText("\n接收方地址:"));
    _listW.add(
      _coustomTextFiled(widget.to),
    );

    _listW.add(_coustomText("\n交易类型:"));
    _listW.add(_coustomTextFiled(widget.txType.toUpperCase()));

    if (widget.txType.toLowerCase() == "erc20") {
      _listW.add(_coustomText("\n合约地址:"));
      _listW.add(
        _coustomTextFiled(widget.currency),
      );
    }

    _listW.add(_coustomText("\nValue:"));
    _listW.add(
      _coustomTextFiled(widget.value),
    );

    _listW.add(_coustomText("\ndata:"));
    _listW.add(
      _coustomTextFiled(widget.data, maxLine: 5),
    );

    _listW.add(_coustomButton(widget.needSign, cur.privKey));
    _listW.add(_loadingBuild());

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _listW,
          ),
        ),
      ),
    );
  }

  Widget _coustomTextFiled(String c, {int maxLine = 1}) {
    return TextField(
      maxLines: maxLine,
      maxLengthEnforced: false,
      style: TextStyle(color: Color.fromRGBO(82, 195, 216, 1)),
      enabled: false,
      controller: TextEditingController(text: c),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 5),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        fillColor: Color.fromRGBO(82, 195, 216, 1),
      ),
    );
  }

  Widget _coustomText(String c, {int maxLine = 1}) {
    return Text(c,
        style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(30)));
  }

  Widget _coustomButton(String hash, PrivkeyManager priv) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: double.maxFinite,
      height: ScreenUtil.getInstance().setHeight(90),
      child: FlatButton(
        color: Color.fromRGBO(82, 195, 216, 1),
        onPressed: () {
          if (isSending) {
            return;
          }
          _signTx(hash, priv);
        },
        child: Text(
          isSending ? "正在交易..." : "发起交易",
          style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(35)),
        ),
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _loadingBuild() {
    print("加载-------");
    if (isSending) {
      print("正在加载---------------");
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

  //
  _signTx(String hash, PrivkeyManager priv) async {
    setState(() {
      isSending = true;
    });
    String signConent = priv.signMsg(hash);
    var result = await pushtx_request(widget.requestID, signConent);
    await Future.delayed(Duration(seconds: 3));
    if (result is String) {
      showInfo(result);
      setState(() {
        isSending = false;
      });
      return;
    }
    var r = (result as PushTxModel);
    if (r.code != "0") {
      showInfo(r.message);
      setState(() {
        isSending = false;
      });
      return;
    }
    _showDetails(r.data.txId);
    setState(() {
      isSending = false;
    });
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

  _showDetails(String txID) {
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
            title: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "交易发起成功！可以点击下方链接查看详情~ \n",
                    style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: txID,
                    style: TextStyle(
                        color: Colors.green,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch(
                            "https://testnet.veforge.com/transactions/${txID}",
                            forceSafariVC: false);
                      }),
              ]),
            ),
          );
        });
  }
}
