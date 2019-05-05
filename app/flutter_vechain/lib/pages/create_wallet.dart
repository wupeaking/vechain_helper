import 'package:flutter/material.dart';
import '../widgets/myicon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../router/routers.dart';
import '../models/privkey.dart';
import '../controller/sql.dart';
import '../provide/wallet.dart';
import 'package:provide/provide.dart';

/**
    AppBar({
    Key key,
    this.leading,//在标题前面显示的一个控件，在首页通常显示应用的 logo；在其他界面通常显示为返回按钮
    this.automaticallyImplyLeading = true,
    this.title,//Toolbar 中主要内容，通常显示为当前界面的标题文字
    this.actions,//一个 Widget 列表，代表 Toolbar 中所显示的菜单，对于常用的菜单，通常使用 IconButton 来表示；对于不常用的菜单通常使用 PopupMenuButton 来显示为三个点，点击后弹出二级菜单
    this.flexibleSpace,//一个显示在 AppBar 下方的控件，高度和 AppBar 高度一样，可以实现一些特殊的效果，该属性通常在 SliverAppBar 中使用
    this.bottom,//一个 AppBarBottomWidget 对象，通常是 TabBar。用来在 Toolbar 标题下面显示一个 Tab 导航栏
    this.elevation = 4.0,//纸墨设计中控件的 z 坐标顺序，默认值为 4，对于可滚动的 SliverAppBar，当 SliverAppBar 和内容同级的时候，该值为 0， 当内容滚动 SliverAppBar 变为 Toolbar 的时候，修改 elevation 的值
    this.backgroundColor,//APP bar 的颜色，默认值为 ThemeData.primaryColor。改值通常和下面的三个属性一起使用
    this.brightness,//App bar 的亮度，有白色和黑色两种主题，默认值为 ThemeData.primaryColorBrightness
    this.iconTheme,//App bar 上图标的颜色、透明度、和尺寸信息。默认值为 ThemeData.primaryIconTheme
    this.textTheme,//App bar 上的文字样式。默认值为 ThemeData.primaryTextTheme
    this.primary = true,
    this.centerTitle,//标题是否居中显示，默认值根据不同的操作系统，显示方式不一样,true居中 false居左
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    })
 */

// 创建钱包页面
class CreateWalletPage extends StatefulWidget {
  @override
  _CreateWalletPageState createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  TextEditingController walletName = TextEditingController();
  TextEditingController walletpasswd = TextEditingController();
  TextEditingController walletpasswdck = TextEditingController();

  bool buttonEnable = false;
  // 是否正在创建钱包
  bool isCreating = false;

  // 检查创建钱包是否使能
  _checkBtnEnable() {
    if (walletName.text != "" &&
        walletpasswd.text != "" &&
        walletpasswdck.text != "" &&
        walletpasswd.text == walletpasswdck.text) {
      setState(() {
        buttonEnable = true;
        print("ok------");
      });
    } else {
      setState(() {
        buttonEnable = false;
        print("not ok------");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    walletName.addListener(_checkBtnEnable);
    walletpasswd.addListener(_checkBtnEnable);
    walletpasswdck.addListener(_checkBtnEnable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("创建钱包"),
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
                    "创建钱包",
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
    // 开启加载动画
    setState(() {
      isCreating = true;
    });

    var pk = PrivkeyManager.randomGenerate();
    pk.passwd = pw;
    pk.walletName = walletName;
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

    await db.insert(pk);
    await db.close();
    setState(() {
      isCreating = false;
    });

    final cur =  Provide.value<CurrentWalletState>(context);
    if(cur.privKey == null){
      cur.changePrivKey(pk);
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
