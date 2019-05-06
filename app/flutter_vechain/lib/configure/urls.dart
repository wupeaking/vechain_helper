// 整个URL列表
final rootURL = "https://easy-mock.com/mock/5cce53e24e96d856ac4be2ef/vechain_apis/";


final Map<String, String> APIS = {
  "balances": rootURL+"balance/", // get方法 获取某些账户的VET余额 balance/$account?currency=xx,yy,zzz
  "unsignTx": rootURL+"unsigned_tx", // put方法 创建交易请求
  "pushTx": rootURL+"sign_tx" // put方法 广播交易
};