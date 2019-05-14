import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluro/fluro.dart';
import 'package:provide/provide.dart';
import './router/routers.dart';
import './pages/home.dart';
import './pages/wallet_list.dart';
import './widgets/myicon.dart';
import './provide/wallet.dart';
import './provide/token.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import './requests/http_requets.dart';
import './requests/unsign_tx_models.dart';

void main() {
  // 创建Provide对象
  final provides = Providers()
    ..provide(Provider.function((context) => CurrentWalletState()))
    ..provide(Provider.function((context) => TokensState()));

  // 初始化全局路由
  GlobalRouter.configureRoutes(Router());
  runApp(ProviderNode(
    providers: provides,
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '唯链支付助手',
      theme: ThemeData(
          primaryColor: Color.fromRGBO(82, 195, 216, 1),
          primarySwatch: Colors.blue,
          // textTheme APPbar上如果没有设置textTheme 会使用这个
          primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white)),
          // 主要的ICON颜色 在APPbar上 如果没有设置iconTheme 会使用这个
          primaryIconTheme: IconThemeData(color: Colors.white)
          // accentColor: Colors.white,
          // brightness: Brightness.light
          ),
      home: IndexPage(title: 'Vechain Helper'),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: GlobalRouter.r.generator,
    );
  }
}

class IndexPage extends StatefulWidget {
  IndexPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    //  初始化屏幕
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: HomePage(),
      floatingActionButton: Container(
        width: ScreenUtil.getInstance().setWidth(220),
        child: FloatingActionButton(
          backgroundColor: Color.fromRGBO(82, 195, 216, 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () {
            scanTransaction();
          },
          tooltip: '扫描支付',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(MyIcon.srcode),
              Text(
                " 扫码交易",
                style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(26)),
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // 设置抽屉
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('wupeaking'),
              accountEmail: Text('wupeaking@gmail.com'),
              currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage("images/ethereum.jpg")),
              //onDetailsPressed: () {},
            ),
            ClipRect(
              child: ListTile(
                leading: Icon(
                  MyIcon.scan,
                  color: Colors.black,
                ),
                title: Text(
                  '扫码交易',
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.getInstance().setSp(30),
                      fontWeight: FontWeight.normal),
                ),
                onTap: () => {scanTransaction()},
              ),
            ),
            ClipRect(
              child: ListTile(
                  leading: Icon(
                    MyIcon.wallet,
                    color: Colors.black,
                  ),
                  title: Text(
                    '查看钱包',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil.getInstance().setSp(30),
                        fontWeight: FontWeight.normal),
                  ),
                  onTap: () =>
                      {GlobalRouter.r.navigateTo(context, "list_wallet")}),
            ),
            ClipRect(
              child: ListTile(
                leading: Icon(
                  MyIcon.createWallt,
                  color: Colors.black54,
                ),
                title: Text(
                  '创建钱包',
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.getInstance().setSp(30),
                      fontWeight: FontWeight.normal),
                ),
                onTap: () =>
                    {GlobalRouter.r.navigateTo(context, "create_wallet")},
              ),
            ),
            ClipRect(
              child: ListTile(
                leading: Icon(
                  MyIcon.importWallt,
                  color: Colors.black54,
                ),
                title: Text(
                  '导入钱包',
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.getInstance().setSp(30),
                      fontWeight: FontWeight.normal),
                ),
                onTap: () =>
                    {GlobalRouter.r.navigateTo(context, "import_wallet")},
              ),
            ),
            ClipRect(
              child: ListTile(
                leading: Icon(
                  MyIcon.about,
                  color: Colors.black54,
                ),
                title: Text(
                  '关于',
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.getInstance().setSp(30),
                      fontWeight: FontWeight.normal),
                ),
                onTap: () => {_showAbout()},
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: "唯链支付助手",
      applicationVersion: 'v0.1',
      applicationIcon: const FlutterLogo(),
      applicationLegalese: '© 2019 wupeaking@gmail.com',
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  style: TextStyle(color: Colors.black54),
                  text: '这是作者使用flutter构建的一个练手项目, 你可以在github',
                ),
                TextSpan(
                    text: '(https://github.com/wupeaking/vechain_helper)',
                    style: TextStyle(
                        color: Colors.green,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch("https://github.com/wupeaking/vechain_helper",
                            forceSafariVC: false);
                      }),
                TextSpan(
                  style: TextStyle(color: Colors.black54),
                  text: '上查看源码. 期望能为你学习flutter，区块链技术提供帮助。但是��止用于商业目的.',
                ),
              ],
            ),
          ),
        ),
      ],
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

  Future scanTransaction() async {
    try {
      final cur = Provide.value<CurrentWalletState>(context);
      if (cur.privKey == null) {
        showInfo("当前没有可用钱包");
        return;
      }

      String barcode = await BarcodeScanner.scan();
      var u = Uri.parse(barcode);
      // 解析参数
      String to = u.queryParameters["to"];
      String amount = u.queryParameters["amount"];
      String currency = u.queryParameters["currency"];
      String data =
          u.queryParameters["data"] == null ? "0x" : u.queryParameters["data"];
      String txType = u.queryParameters["txType"] == null
          ? "vet"
          : u.queryParameters["txType"];

      if (to == null || amount == null || currency == null) {
        showInfo("无效的二维码数据");
        return;
      }
      // 开始网络请求 创建交易
      var result = await unsigntx_request(
          cur.privKey.addrToString(), to, amount, currency, txType);
      if (result is String) {
        showInfo(result);
        return;
      }
      var r = (result as UnsignTxModel);
      if (r.code != "0") {
        showInfo(r.message);
        return;
      }
      // /send_tx/:to/:value/:data/:currency/:txType/:needSign:/requestID
      GlobalRouter.r.navigateTo(context,
          "/send_tx/${to}/${amount}/${data}/${currency}/${r.data.txType}/${r.data.needSignContent}/${r.data.requestId}");
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        showInfo("无访问相机权限");
      } else {
        print("未知错误");
      }
    } catch (e) {
      print("未知错误!");
    }
  }
}

/** 
先来看看ThemeData的主要属性（水平有限，对着文档和翻译软件写的）：

accentColor - Color类型，前景色（文本、按钮等）
accentColorBrightness - Brightness类型，accentColor的亮度。 用于确定放置在突出颜色顶部的文本和图标的颜色（例如FloatingButton上的图标）。
accentIconTheme - IconThemeData类型，与突出颜色对照的图片主题。
accentTextTheme - TextTheme类型，与突出颜色对照的文本主题。
backgroundColor - Color类型，与primaryColor对比的颜色(例如 用作进度条的剩余部分)。
bottomAppBarColor - Color类型，BottomAppBar的默认颜色。
brightness - Brightness类型，应用程序整体主题的亮度。 由按钮等Widget使用，以确定在不使用主色或强调色时要选择的颜色。
buttonColor - Color类型，Material中RaisedButtons使用的默认填充色。
buttonTheme - ButtonThemeData类型，定义了按钮等控件的默认配置，像RaisedButton和FlatButton。
canvasColor - Color类型，MaterialType.canvas Material的默认颜色。
cardColor - Color类型，Material被用作Card时的颜色。
chipTheme - ChipThemeData类型，用于渲染Chip的颜色和样式。
dialogBackgroundColor - Color类型，Dialog元素的背景色。
disabledColor - Color类型，用于Widget无效的颜色，无论任何状态。例如禁用复选框。
dividerColor - Color类型，Dividers和PopupMenuDividers的颜色，也用于ListTiles中间，和DataTables的每行中间.
errorColor - Color类型，用于输入验证错误的颜色，例如在TextField中。
hashCode - int类型，这个对象的哈希值。
*highlightColor - Color类型，用于类似墨水喷溅动画或指示菜单被选中的高亮颜色。
hintColor - Color类型，用于提示文本或占位符文本的颜色，例如在TextField中。
iconTheme - IconThemeData类型，与卡片和画布颜色形成对比的图标主题。
indicatorColor - Color类型，TabBar中选项选中的指示器颜色。
inputDecorationTheme - InputDecorationTheme类型，InputDecorator，TextField和TextFormField的默认InputDecoration值基于此主题。
platform - TargetPlatform类型，Widget需要适配的目标类型。
primaryColor - Color类型，App主要部分的背景色（ToolBar,Tabbar等）。
primaryColorBrightness - Brightness类型，primaryColor的亮度。
primaryColorDark - Color类型，primaryColor的较暗版本。
primaryColorLight - Color类型，primaryColor的较亮版本。
primaryIconTheme - IconThemeData类型，一个与主色对比的图片主题。
primaryTextTheme - TextThemeData类型，一个与主色对比的文本主题。
scaffoldBackgroundColor - Color类型，作为Scaffold基础的Material默认颜色，典型Material应用或应用内页面的背景颜色。
secondaryHeaderColor - Color类型，有选定行时PaginatedDataTable标题的颜色。
selectedRowColor - Color类型，选中行时的高亮颜色。
sliderTheme - SliderThemeData类型，用于渲染Slider的颜色和形状。
splashColor - Color类型，墨水喷溅的颜色。
splashFactory - InteractiveInkFeatureFactory类型，定义InkWall和InkResponse生成的墨水喷溅的外观。
textSelectionColor - Color类型，文本字段中选中文本的颜色，例如TextField。
textSelectionHandleColor - Color类型，用于调整当前文本的哪个部分的句柄颜色。
textTheme - TextTheme类型，与卡片和画布对比的文本颜色。
toggleableActiveColor - Color类型，用于突出显示切换Widget（如Switch，Radio和Checkbox）的活动状态的颜色。
unselectedWidgetColor - Color类型，用于Widget处于非活动（但已启用）状态的颜色。 例如，未选中的复选框。 通常与accentColor形成对比。
runtimeType - Type类型，表示对象的运行时类型。
*/
