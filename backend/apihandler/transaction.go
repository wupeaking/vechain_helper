package apihandler

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"github.com/ethereum/go-ethereum/rlp"
	"github.com/labstack/echo"
	"github.com/satori/go.uuid"
	"github.com/vechain/thor/tx"
	"github.com/wupeaking/vechainhelper/database"
	"github.com/wupeaking/vechainhelper/initialization"
	"github.com/wupeaking/vechainhelper/utils"
	"math/big"
	"net/http"
)

// 和账户交易相关的API放在此文件下

// UnSignTx 创建未签名的交易 put /unsign_tx {"currency": "xxx",  }
func UnSignTx(ctx echo.Context) error {
	c, ok := ctx.(*initialization.CustomContext)
	if !ok {
		return errors.New("转换自定义上下文异常")
	}
	//解析请求参数
	request := struct {
		From     string `json:"from"`
		To       string `json:"to"`
		Amount   string `json:"amount"`
		Currency string `json:"currency"`
	}{}
	if err := ctx.Bind(&request); err != nil {
		ctx.Logger().Warnf("创建未签名交易过程中, 请求参数反序列化失败: %s", err.Error())
		errPackage(c, initialization.ParamError)
		return nil
	}

	amount, suc := new(big.Int).SetString(request.Amount, 0)
	if !utils.CheckAddress(request.To) || !suc {
		ctx.Logger().Errorf("创建未签名交易过程中, 缺少必要参数或者参数错误, args: %v", request)
		errPackage(c, initialization.ParamError)
		return nil
	}

	ctx.Logger().Infof("收到创建未签名交易请求, 币种:%s from地址:%s，to: %s, amount: %v",
		request.Currency, request.From, request.To, request.Amount)

	// 查询当前区块号
	blk, err := c.BlockClient.BlockInfo(context.Background(), 0)
	if err != nil {
		ctx.Logger().Errorf("创建未签名交易过程中, 查询参考区块信息出错, err: %s", err.Error())
		errPackage(c, initialization.CallAPIErr)
		return nil
	}

	// 1. 模拟出需要的gas数量
	// 2. 计算是否vtho够用
	// 3. 构造未签名的原始交易
	// 5. 插入数据库
	// 6. 广播交易
	// 7. 返回
	clause := []database.Clause{{To: request.To, Amount: amount}}
	gasUsed, err := calcTransferGasUsed(request.Currency, amount,
		clause, c.BlockClient)

	if err != nil {
		ctx.Logger().Errorf("创建未签名交易过程中, 模拟计算gas使用出错, err: %s", err.Error())
		errPackage(c, initialization.CallAPIErr)
		return nil
	}

	allVtho, err := queryBalance("vtho", request.From, c.BlockClient)
	if err != nil {
		ctx.Logger().Errorf("创建未签名交易过程中, 查询vtho余额出错, err: %s", err.Error())
		errPackage(c, initialization.CallAPIErr)
		return nil
	}
	// gas --> vtho(wei)  (gas/1000)*10^18=gas*10^15
	totalUsedVtho := new(big.Int).Mul(big.NewInt(int64(gasUsed)), big.NewInt(10e15))
	if allVtho.Cmp(totalUsedVtho) < 0 {
		ctx.Logger().Errorf("创建未签名交易过程中, vtho不足以支付矿工费用")
		errPackage(c, initialization.BalanceErr)
		return nil
	}

	// 构造未签名的原始交易
	encode, needSign, err := constructUnSignTxData(request.Currency, uint32(blk.BlockNum), clause, gasUsed)
	if err != nil {
		ctx.Logger().Errorf("创建未签名交易过程中, 构造原始交易出错, address: %s, err:%s",
			request.From, err.Error())
		errPackage(c, initialization.TransferErr)
		return nil
	}
	u4 := uuid.NewV4()
	id := u4.String()

	// 插入数据
	if err := database.InsertTxOrder(c.DB, id, request.From, request.To,
		request.Currency, request.Amount, fmt.Sprintf("%d", gasUsed), 0, encode); err != nil {
		ctx.Logger().Errorf("创建未签名交易过程中, 添加交易订单信息到数据库出错, 交易编号:[%s], err: %s",
			id, err.Error())
		errPackage(c, initialization.DataBaseErr)
		return nil
	}

	// 封装数据 返回
	result := struct {
		Code string      `json:"code"`
		Msg  string      `json:"message"`
		Data interface{} `json:"data"`
	}{
		Code: initialization.Success.ErrCode(),
		Msg:  initialization.Success.ErrMsg(),
		Data: struct {
			NeedSignContent string `json:"need_sign_content"`
			ID              string `json:"request_id"`
		}{NeedSignContent: needSign, ID: id},
	}
	c.JSON(http.StatusOK, result)
	return nil

}

//PushTx  put /sign_tx  广播签名的交易  {"request_id": xxxx, "sign": xxxx}
func PushTx(ctx echo.Context) error {
	c, ok := ctx.(*initialization.CustomContext)
	if !ok {
		return errors.New("转换自定义上下文异常")
	}
	return nil
	//解析请求参数
	request := struct {
		ID   string `json:"request_id"`
		Sign string `json:"sign"`
	}{}
	if err := ctx.Bind(&request); err != nil {
		ctx.Logger().Warnf("广播交易过程中, 请求参数反序列化失败: %s", err.Error())
		errPackage(c, initialization.ParamError)
		return nil
	}

	/*
		1. 查询数据库中是否有此交易
		2. 对交易进行rlp解码
		3. 放入签名内容
		4. 进行rlp编码之后 广播
	*/

	rlpData, err := database.SelectTxRlp(c.DB, request.ID)
	if err != nil {
		ctx.Logger().Warnf("广播交易过程中, 此请求的ID不存在: %s", err.Error())
		errPackage(c, initialization.DataBaseErr)
		return nil
	}

	rlpBytes, err := hex.DecodeString(rlpData)
	if err != nil {
		ctx.Logger().Warnf("广播交易过程中, rlp转换为字节失败: %s", err.Error())
		errPackage(c, initialization.EncodeError)
		return nil
	}

	signByts, err := hex.DecodeString(request.Sign)
	if err != nil {
		ctx.Logger().Warnf("广播交易过程中, sign转换失败: %s", err.Error())
		errPackage(c, initialization.EncodeError)
		return nil
	}

	trx := tx.Transaction{}
	if rlp.DecodeBytes(rlpBytes, &trx) != nil {
		ctx.Logger().Warnf("广播交易过程中, rlp解码未签名交易失败: %s", err.Error())
		errPackage(c, initialization.EncodeError)
		return nil
	}

	signTx := trx.WithSignature(signByts)
	d, err := rlp.EncodeToBytes(signTx)
	if err != nil {
		ctx.Logger().Warnf("广播交易过程中, rlp转换签名交易失败: %s", err.Error())
		errPackage(c, initialization.EncodeError)
		return nil
	}
	txID, err := c.BlockClient.PushTx(context.Background(), hex.EncodeToString(d))
	if err != nil {
		ctx.Logger().Warnf("广播交易过程中, 广播交易失败: %s", err.Error())
		errPackage(c, initialization.CallAPIErr)
		return nil
	}

	// 封装数据 返回
	result := struct {
		Code string      `json:"code"`
		Msg  string      `json:"message"`
		Data interface{} `json:"data"`
	}{
		Code: initialization.Success.ErrCode(),
		Msg:  initialization.Success.ErrMsg(),
		Data: struct {
			TxID string `json:"tx_id"`
			ID   string `json:"request_id"`
		}{TxID: txID, ID: request.ID},
	}
	c.JSON(http.StatusOK, result)
	return nil
}
