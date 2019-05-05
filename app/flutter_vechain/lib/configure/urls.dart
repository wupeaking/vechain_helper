// 整个URL列表
final rootURL = "https://easy-mock.com/mock/5cce53e24e96d856ac4be2ef/vechain_apis/";


final Map<String, String> APIS = {
  "vetBalances": rootURL+"vet_balances", // get方法 获取某些账户的VET余额 ?address=xxx
  "erc20Banlances": rootURL+"erc20_balances", // get 方法 获取账户的ERC20余额  address=xxx&tokens=abc,efg,xxx

};