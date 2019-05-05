import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/tokens.dart';
import '../provide/token.dart';
import '../controller/tokensql.dart';
import 'package:provide/provide.dart';
import '../router/routers.dart';

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

                print("token 列表发送变化 ${_tokenList}");
                return Text("");
              },
            ),
          )
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
          leading: Icon(
            Icons.info,
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
              Text(
                "余额: ${_tokenList[i].balance}",
                style: TextStyle(color: Colors.black12),
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
          },
        );
      },
      itemCount: _tokenList.length,
    ));
  }
}
