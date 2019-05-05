import 'package:flutter/material.dart';
import '../models/privkey.dart';
import '../controller/sql.dart';
import '../controller/idsql.dart';
import 'package:provide/provide.dart';
import '../provide/wallet.dart';

class WalletListPage extends StatefulWidget {
  @override
  _WalletListPageState createState() => _WalletListPageState();
}

class _WalletListPageState extends State<WalletListPage> {
  List<PrivkeyManager> _priKeys = [];
  int _curIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  _loadWallet() async {
    var db = SQLDAO();
    await db.openSqlite();
    _priKeys = await db.queryAll();
    // print("${_priKeys.length}");
    await db.close();

    // 查询钱包ID
    var dbID = WalletIDSQL();
    await dbID.openSqlite();
    WalletID wid = await dbID.currentWalletID();
    if (wid != null) {
      _curIndex = wid.id;
    } else {
      _curIndex = 0;
    }
    await dbID.close();
    setState(() {});
  }

  _updateWalletID(int id) async {
    var dbID = WalletIDSQL();
    await dbID.openSqlite();
    await dbID.replaceInto(WalletID()..id = id);
    await dbID.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("钱包列表"),
      ),
      body: Container(
        child: Center(
          child: _buildList(),
        ),
      ),
    );
  }

  Widget _buildList() {
    final currentWallet = Provide.value<CurrentWalletState>(context);
    if (_priKeys==null || _priKeys.length == 0) {
      return Text("不存在");
    }
    return ListView.builder(
      itemCount: _priKeys.length,
      itemBuilder: (context, index) {
        return ListTile(
          subtitle: Text("${_priKeys[index].addrToString()}"),
          title: Text("${_priKeys[index].walletName}"),
          leading: Icon(
            Icons.money_off,
            color: _curIndex == _priKeys[index].id ? Colors.green : Colors.grey,
          ),
          onTap: () {
            print("钱包ID: ${_priKeys[index].id}");
            setState(() {
              _curIndex = _priKeys[index].id;
            });
            _updateWalletID(_priKeys[index].id);

            currentWallet.changePrivKey(_priKeys[index]);
            print("当前钱包改变");
          },
        );
      },
    );
  }
}
