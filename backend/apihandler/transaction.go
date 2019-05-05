package apihandler

import (
	"context"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/rlp"
	"github.com/go-sql-driver/mysql"
	"github.com/labstack/echo"
	"github.com/vechain/thor/thor"
	"github.com/vechain/thor/tx"
	"github.com/wupeaking/vechainhelper/database"
	"github.com/wupeaking/vechainhelper/initialization"
	"github.com/wupeaking/vechainhelper/utils"
	"github.com/wupeaking/vechainhelper/utils/sign"
	"github.com/wupeaking/vechainhelper/vechainclient"
	"math/big"
	"net/http"
	"strings"
	"time"
)

// 和账户交易相关的API放在此文件下

// Balance 查询账户余额 get /balance/:account?currency=vet/vtho...
func Balance(ctx echo.Context) error {

	c, ok := ctx.(*initialization.CustomContext)
	if !ok {
		return errors.New("转换自定义上下文异常")
	}

	account := c.Param("account")
	currency := c.QueryParam("currency")

	if currency == "" {
		currency = "vet"
	}

	balance, err := queryBalance(currency, account, c.BlockClient)
	if err != nil {
		ctx.Logger().Errorf("查询token余额出错, err: %v", err.Error())
		errPackage(c, initialization.CallContractErr)
		return nil
	}

	// 封装数据 返回
	result := struct {
		Code string      `json:"errCode"`
		Msg  string      `json:"errMsg"`
		Data interface{} `json:"data"`
	}{
		Code: initialization.Success.ErrCode(),
		Msg:  initialization.Success.ErrMsg(),
		Data: balance.String(),
	}
	c.JSON(http.StatusOK, result)
	return nil
}

//Transaction 发起交易 put /transactions
// { "currency": "xxx", "from": "0x01",
//    "clauses": [{"to": "0x02", "amount": "123421"}],
//    "privKey"： "sss" "requestID": "unique" }
func Transaction(ctx echo.Context) error {
	c, ok := ctx.(*initialization.CustomContext)
	if !ok {
		return errors.New("转换自定义上下文异常")
	}

	//解析请求参数
	request := struct {
		PrivateKey string `json:"privKey"`
		From       string `json:"from"`
		Clauses    []struct {
			To     string `json:"to"`
			Amount string `json:"amount"`
		} `json:"clauses"`
		RequestID string `json:"requestID"`
		Currency  string `json:"currency"`
	}{}
	if err := ctx.Bind(&request); err != nil {
		ctx.Logger().Warnf("进行转账过程中, 请求参数反序列化失败: %s", err.Error())
		errPackage(c, initialization.ParamError)
		return nil
	}

	if request.PrivateKey == "" || !utils.CheckAddress(request.From) || request.RequestID == "" ||
		len(request.Clauses) == 0 {
		ctx.Logger().Errorf("进行转账过程中, 缺少必要参数或者参数错误, args: %v", request)
		errPackage(c, initialization.ParamError)
		return nil
	}

	clauses := make([]database.Clause, 0, len(request.Clauses))
	for clause := range request.Clauses {
		amount, suc := new(big.Int).SetString(request.Clauses[clause].Amount, 0)
		if !utils.CheckAddress(request.Clauses[clause].To) || !suc {
			ctx.Logger().Errorf("进行转账过程中, 缺少必要参数或者参数错误, args: %v", request)
			errPackage(c, initialization.ParamError)
			return nil
		}
		clauses = append(clauses,
			database.Clause{To: request.Clauses[clause].To, Amount: amount})
	}

	// 私钥
	privateKeyByte, err := base64.StdEncoding.DecodeString(request.PrivateKey)
	privkey, err := sign.RSADecrypt(privateKeyByte, []byte(initialization.PrivateKey))
	if err != nil {
		ctx.Logger().Errorf("进行转账过程中, 秘钥解密失败：%s, 交易编号[%s], address: %s",
			err.Error(), request.RequestID, request.From)
		errPackage(c, initialization.PrivKeyError)
		return nil
	}

	ctx.Logger().Infof("收到转账交易请求, 交易编号%s，币种:%s from地址:%s，clauses: %v",
		request.RequestID, request.Currency, request.From, clauses)

	// 查询当前区块号
	blk, err := c.BlockClient.BlockInfo(context.Background(), 0)
	if err != nil {
		ctx.Logger().Errorf("进行转账过程中, 查询参考区块信息出错, 交易编号[%s], err: %s", request.RequestID, err.Error())
		errPackage(c, initialization.CallAPIErr)
		return nil
	}

	// 1. 模拟出需要的gas数量
	// 2. 计算是否vtho够用
	// 3. 插入交易订单表  后期 下面这些可能需要做成异步
	// 4. 构造原始交易
	// 5. 插入交易记录表
	// 6. 广播交易
	// 7. 返回
	gasUsed, err := calcTransferGasUsed(request.Currency, clauses[0].Amount, clauses, c.BlockClient)
	if err != nil {
		ctx.Logger().Errorf("进行转账过程中, 模拟计算gas使用出错, 交易编号[%s], err: %s",
			request.RequestID, err.Error())
		errPackage(c, initialization.CallAPIErr)
		return nil
	}

	allVtho, err := queryBalance("vtho", request.From, c.BlockClient)
	if err != nil {
		ctx.Logger().Errorf("进行转账过程中, 查询vtho余额出错, 交易编号[%s], err: %s",
			request.RequestID, err.Error())
		errPackage(c, initialization.CallAPIErr)
		return nil
	}
	// gas --> vtho(wei)  (gas/1000)*10^18=gas*10^15
	totalUsedVtho := new(big.Int).Mul(big.NewInt(int64(gasUsed)), big.NewInt(10e15))
	if allVtho.Cmp(totalUsedVtho) < 0 {
		ctx.Logger().Errorf("进行转账过程中, vtho不足以支付矿工费用, 交易编号[%s]", request.RequestID)
		errPackage(c, initialization.BalanceErr)
		return nil
	}

	err = database.InsertTxOrder(c.DB, request.RequestID, request.From, request.Currency,
		fmt.Sprintf("%d", gasUsed), 1, clauses)
	if err != nil {
		me, _ := err.(*mysql.MySQLError)
		if me.Number == 1062 {
			ctx.Logger().Errorf("进行转账过程中, 交易订单号重复, 交易编号:[%s], err: %s",
				request.RequestID, err.Error())
			errPackage(c, initialization.TransferErr)
			return nil
		}
		ctx.Logger().Errorf("进行转账过程中, 添加交易订单信息到数据库出错, 交易编号:[%s], err: %s",
			request.RequestID, err.Error())
		errPackage(c, initialization.DataBaseErr)
		return nil
	}

	// 构造交易 创建原始交易
	_, rawTx, err := constructTxData(privkey, request.Currency, uint32(blk.BlockNum), clauses, gasUsed)
	if err != nil {
		ctx.Logger().Errorf("进行转账过程中, 构造原始交易出错, 交易编号[%s], address: %s, err:%s",
			request.RequestID, request.From, err.Error())
		errPackage(c, initialization.TransferErr)
		return nil
	}

	// 广播交易 这一步很重要 如果广播之后是不能撤回的  金额也就收不回来了 要谨慎
	txid, err := c.BlockClient.PushTx(context.Background(), rawTx)
	if err != nil {
		ctx.Logger().Errorf("进行转账过程中,账户%s广播原始交易出错, 交易编号[%s], err: %s",
			request.From, request.RequestID, err.Error())
		errPackage(c, initialization.TransferErr)
		return nil
	}

	err = database.InsertTxStatus(c.DB, txid, request.RequestID, 0)
	if err != nil {
		ctx.Logger().Errorf("进行转账过程中, 添加交易hash到数据库失败, 交易编号[%s], err:%s",
			request.RequestID, err.Error())
	}
	// 封装数据 返回
	result := struct {
		Code string      `json:"errCode"`
		Msg  string      `json:"errMsg"`
		Data interface{} `json:"data"`
	}{
		Code: initialization.Success.ErrCode(),
		Msg:  initialization.Success.ErrMsg(),
		Data: txid,
	}
	c.JSON(http.StatusOK, result)
	return nil
}

//calcTransferGasUsed 模拟计算实际转账需要的gas
func calcTransferGasUsed(curreny string, amount *big.Int, clauses []database.Clause, cli *vechain.Client) (uint64, error) {
	// https://github.com/vechain/thor/wiki/FAQ#what-is-intrinsic-gas-
	if strings.ToLower(curreny) == "vet" {
		return 5000 + uint64(len(clauses))*16000, nil
	}

	tokenContarct, ok := initialization.TokenContractMap[curreny]
	if !ok {
		return 0, fmt.Errorf("未知的token: %s", curreny)
	}
	//address _to, uint256 _value
	method := abi.Method{Name: "transfer", Const: false}
	addressType, _ := abi.NewType("address", nil)
	uin256Type, _ := abi.NewType("uint256", nil)

	_to := abi.Argument{Name: "_to", Type: addressType, Indexed: false}
	_value := abi.Argument{Name: "_value", Type: uin256Type, Indexed: false}
	method.Inputs = abi.Arguments{_to, _value}

	toAddr := common.HexToAddress("0xb9b7e0cb2edf5ea031c8b297a5a1fa20379b6a0a")
	argsData, _ := method.Inputs.Pack(toAddr, amount)
	data := append(method.Id(), argsData...)

	result, err := cli.SimulateContract(context.Background(), fmt.Sprintf("0x%0x", data),
		"0", tokenContarct)

	if err != nil {
		return 0, err
	}
	if result.Reverted {
		return 0, fmt.Errorf("虚拟机执行reverted")
	}
	// txGas + (clauses.type + dataGas + vmGas)*len(clauses)

	// 精确datagas计算
	//dataGas := func (input []byte) uint64 {
	//	const zgas = 4
	//	const nzgas = 68
	//	var gas uint64
	//	for i := 0; i<len(input); i++ {
	//		if input[i] == 0{
	//			gas += zgas
	//		}else{
	//			gas += nzgas
	//		}
	//	}
	//	return gas
	//}
	dataGas := func(input []byte) uint64 {
		const nzgas = 68
		return uint64(len(input)) * nzgas
	}

	return (result.GasUsed+16000+dataGas(data))*uint64(len(clauses)) + 5000, nil

}

//queryBalance 查询本币或者token余额
func queryBalance(currency string, account string, cli *vechain.Client) (*big.Int, error) {
	currency = strings.ToLower(currency)
	if currency == "vet" || currency == "vtho" {
		balance, err := cli.BalanceByAddress(context.Background(), account)
		if err != nil {
			return nil, err
		}
		if currency == "vet" {
			return balance.Balance, nil
		}
		return balance.Energy, nil
	}

	/*
	   function balanceOf(address _owner) public view returns (uint256 balance)
	*/
	tokenContarct, ok := initialization.TokenContractMap[currency]
	if !ok {
		return nil, fmt.Errorf("未知的token: %s", currency)
	}

	method := abi.Method{Name: "balanceOf", Const: false}
	addressType, _ := abi.NewType("address", nil)
	uin256Type, _ := abi.NewType("uint256", nil)

	_owner := abi.Argument{Name: "_owner", Type: addressType, Indexed: false}
	_value := abi.Argument{Name: "balance", Type: uin256Type, Indexed: false}
	method.Inputs = abi.Arguments{_owner}
	method.Outputs = abi.Arguments{_value}

	toAddr := common.HexToAddress(account)
	argsData, _ := method.Inputs.Pack(toAddr)
	input := append(method.Id(), argsData...)

	result, err := cli.SimulateContract(context.Background(), fmt.Sprintf("0x%0x", input),
		"0", tokenContarct)

	if err != nil {
		return nil, err
	}
	//value := reflect.New(reflect.TypeOf(big.NewInt(0)))
	value := big.NewInt(0)
	resultData, _ := hex.DecodeString(result.Data[2:])

	err = method.Outputs.Unpack(&value, resultData)
	if err != nil {
		return nil, err
	}

	// value.Elem().Interface().(*big.Int)
	return value, nil
}

// constructRawTransfer 构造交易 返回值： 交易ID 原始交易内容 错误
func constructTxData(prvk []byte, currency string, blockNum uint32,
	clauses []database.Clause, gas uint64) (string, string, error) {

	currency = strings.ToLower(currency)

	b, _ := new(big.Int).SetString(string(prvk), 0)

	//   chaintag  创世区块ID 最后一个字节 测试链为0x27 生产链为0x4a
	trx := new(tx.Builder).ChainTag(initialization.ChainTag).
		BlockRef(tx.NewBlockRef(blockNum)).
		Expiration(720).
		GasPriceCoef(0).
		Gas(gas).
		DependsOn(nil).
		Nonce(uint64(time.Now().UnixNano()))

	var tokenAddr thor.Address

	if currency != "vet" {
		tokenContarct, ok := initialization.TokenContractMap[currency]
		if !ok {
			return "", "", fmt.Errorf("未知的token: %s", currency)
		}
		t, err := thor.ParseAddress(tokenContarct)
		if err != nil {
			return "", "", err
		}
		tokenAddr = t
	}

	for _, clause := range clauses {
		toAddr, err := thor.ParseAddress(clause.To)
		if err != nil {
			return "", "", err
		}
		if currency == "vet" {
			trx.Clause(tx.NewClause(&toAddr).WithValue(clause.Amount).WithData(nil))
			continue
		}

		// token 转账
		//address _to, uint256 _value
		method := abi.Method{Name: "transfer", Const: false}
		addressType, _ := abi.NewType("address", nil)
		uin256Type, _ := abi.NewType("uint256", nil)
		_to := abi.Argument{Name: "_to", Type: addressType, Indexed: false}
		_value := abi.Argument{Name: "_value", Type: uin256Type, Indexed: false}
		method.Inputs = abi.Arguments{_to, _value}
		argsData, _ := method.Inputs.Pack(toAddr, clause.Amount)
		input := append(method.Id(), argsData...)
		trx.Clause(tx.NewClause(&tokenAddr).WithValue(big.NewInt(0)).WithData(input))
	}

	trxBuild := trx.Build()
	priv, err := crypto.ToECDSA(b.Bytes()) //  HexToECDSA(b.Text(16))
	if err != nil {
		return "", "", err
	}
	sig, err := crypto.Sign(trxBuild.SigningHash().Bytes(), priv)
	if err != nil {
		return "", "", err
	}

	trxBuild = trxBuild.WithSignature(sig)
	d, err := rlp.EncodeToBytes(trxBuild)
	if err != nil {
		return "", "", err
	}
	return trxBuild.ID().String(), hex.EncodeToString(d), nil
}
