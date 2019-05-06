package apihandler

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/labstack/echo"
	"github.com/wupeaking/vechainhelper/initialization"
	"github.com/wupeaking/vechainhelper/utils"
	"github.com/wupeaking/vechainhelper/vechainclient"
	"math/big"
	"net/http"
	"strings"
)

// Balance 查询账户余额 get /balance/:account?currency=vet,vtho,0x12121,0x43434
func Balance(ctx echo.Context) error {

	c, ok := ctx.(*initialization.CustomContext)
	if !ok {
		return errors.New("转换自定义上下文异常")
	}

	account := c.Param("account")
	currency := c.QueryParam("currency")

	var allCurrency []string
	if currency == "" {
		allCurrency = []string{"vet"}
	} else {
		allCurrency = strings.Split(currency, ",")
	}

	type resultT struct {
		Contract string `json:"contract_address"`
		Balance  string `json:"balance"`
	}

	var balanceResults []resultT

	for i := 0; i < len(allCurrency); i++ {
		balance, err := queryBalance(allCurrency[i], account, c.BlockClient)
		if err != nil {
			ctx.Logger().Errorf("查询token余额出错, err: %v", err.Error())
			balanceResults = append(balanceResults, resultT{Contract: allCurrency[i], Balance: "0"})
		}else{
			balanceResults = append(balanceResults, resultT{Contract: allCurrency[i], Balance: balance.String()})
		}
	}

	// 封装数据 返回
	result := struct {
		Code string      `json:"code"`
		Msg  string      `json:"message"`
		Data interface{} `json:"data"`
	}{
		Code: initialization.Success.ErrCode(),
		Msg:  initialization.Success.ErrMsg(),
		Data: balanceResults,
	}
	c.JSON(http.StatusOK, result)
	return nil
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

	if !utils.CheckAddress(currency) {
		return nil, errors.New("无效合约地址")
	}

	/*
	   function balanceOf(address _owner) public view returns (uint256 balance)
	*/

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
		"0", currency)

	if err != nil {
		return nil, err
	}

	if result.VMErr != "" {
		return nil, errors.New(result.VMErr)
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
