import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/tokens.dart';
import '../provide/token.dart';
import '../provide/wallet.dart';
import '../controller/tokensql.dart';
import 'package:provide/provide.dart';
import '../router/routers.dart';
import '../requests/http_requets.dart';
import '../requests/vetrequest_models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'dart:math';

class SelfTokenList extends StatefulWidget {
  @override
  _SelfTokenListState createState() => _SelfTokenListState();
}

class _SelfTokenListState extends State<SelfTokenList> {
  List<Token> _tokenList = [];

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  _loadTokens() async {
    var sql = TokenSQL();
    await sql.openSqlite();
    List<Token> tks = await sql.queryAll();
    await sql.close();
    if (tks != null) {
      setState(() {
        _tokenList = tks;
      });
    } else {
      return;
    }
    // 加载成功之后 要告诉状态管理
    if (tks.length != 0) {
      final cur = Provide.value<TokensState>(context);
      cur.changeTokens(tks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(20),
      height: ScreenUtil.getInstance().setHeight(800),
      child: Column(
        children: <Widget>[
          // 列表头
          _titleBuild(),
          // token list
          Expanded(
            flex: 1,
            child: _tokenListBuild(),
          ),
          // 占位
          Container(
            height: 0,
            child: Provide<TokensState>(
              builder: (context, child, value) {
                //
                if (value.tokens.length != 0) {
                  _tokenList = value.tokens;
                }
                // 拼接tokens
                List<String> tokens = _tokenList.map((e) {
                  return e.address;
                }).toList();

                final wallet = Provide.value<CurrentWalletState>(context);
                if (wallet.privKey != null) {
                  // 调用接口 请求余额
                  _request_balance(
                      wallet.privKey.addrToString(), tokens.join(","));
                }

                print("token 列表发送变化 ${_tokenList}");
                return Text("");
              },
            ),
          ),
          Container(
            height: 0,
            child: Provide<CurrentWalletState>(
              builder: (context, child, value) {
                //
                print("钱包状态发生变化: ${value.privKey}");
                if (value.privKey == null) {
                  return Text("");
                }
                if (_tokenList.length == 0) {
                  return Text("");
                }
                // 拼接tokens
                List<String> tokens = _tokenList.map((e) {
                  return e.address;
                }).toList();
                _request_balance(
                    value.privKey.addrToString(), tokens.join(","));
                return Text("");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleBuild() {
    return Row(
      children: <Widget>[
        Text(
          "Tokens",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ScreenUtil.getInstance().setSp(58),
          ),
        ),
        // 拉伸
        Expanded(
          flex: 1,
          child: Text(""),
        ),
        IconButton(
          icon: Icon(Icons.add_circle),
          color: Color.fromRGBO(82, 195, 216, 1),
          onPressed: () {
            GlobalRouter.r.navigateTo(context, "add_token");
          },
        )
      ],
    );
  }

  Widget _tokenListBuild() {
    if (_tokenList.length == 0) {
      return Container(
        margin: EdgeInsets.only(top: 20),
        child: Text(
          "当前没有添加任何token信息 点击+号进行添加",
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: ScreenUtil.getInstance().setSp(38),
            color: Colors.black12,
          ),
        ),
      );
    }

    return Container(
        child: ListView.builder(
      itemBuilder: (c, i) {
        return ListTile(
          leading: IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {},
            color: Color.fromRGBO(82, 195, 216, 0.5),
          ),
          title: Row(
            children: <Widget>[
              Text(
                _tokenList[i].symbol,
                style: TextStyle(color: Colors.black),
              ),
              Expanded(
                flex: 1,
                child: Text(""),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "余额: ${_tokenList[i].balance}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black12),
                ),
              ),
            ],
          ),
          subtitle: Text(
            _tokenList[i].address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            print("点击合约详情");
            _showDetails(_tokenList[i].address, _tokenList[i].symbol,
                _tokenList[i].balance, _tokenList[i].bits);
          },
        );
      },
      itemCount: _tokenList.length,
    ));
  }

  Future<bool> _request_balance(String addr, String tokens) async {
    var onValue = await getBalance(addr, tokens);

    if (onValue is String) {
      print("请求异常: ${onValue}");
    } else if (onValue is VETRequest) {
      if (onValue.code != "0") {
        print("请求接口异常: ${onValue.message}");
        return false;
      }
      Map<String, String> tokensBalance = {};

      for (var i = 0; i < onValue.data.length; i++) {
        tokensBalance[onValue.data[i].contractAddress] =
            onValue.data[i].balance;
      }

      for (var i = 0; i < _tokenList.length; i++) {
        if (tokensBalance[_tokenList[i].address] != null) {
          _tokenList[i].balance = tokensBalance[_tokenList[i].address];
        }
      }
      print("请求成功: ${onValue.data}");
    }

    return true;
  }

  _showDetails(String contract, String symbol, String balance, int bits) {
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
                    text: '${contract}',
                    style: TextStyle(
                        color: Colors.green,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch(
                            "https://testnet.veforge.com/accounts/${contract}/tokenTransfers",
                            forceSafariVC: false);
                      }),
                TextSpan(
                  text: '\n\n Symbol: ${symbol}',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '\n\n 余额: ${double.parse(balance) / pow(10, 18)}',
                  style: TextStyle(color: Colors.black),
                ),
              ]),
            ),
          );
        });
  }
}
