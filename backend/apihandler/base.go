package apihandler

import (
	"context"
	"fmt"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/rlp"
	"github.com/labstack/echo"
	"github.com/vechain/thor/thor"
	"github.com/vechain/thor/tx"
	"github.com/wupeaking/vechainhelper/database"
	"github.com/wupeaking/vechainhelper/initialization"
	"github.com/wupeaking/vechainhelper/vechainclient"
	"math/big"
	"net/http"
	"strings"
	"time"
)

func errPackage(ctx echo.Context, err initialization.ErrDesc) {
	// 封装数据 返回
	ctx.JSON(http.StatusOK,
		struct {
			Code string `json:"code"`
			Msg  string `json:"message"`
		}{
			Code: err.ErrCode(),
			Msg:  err.ErrMsg(),
		},
	)
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

// constructUnSignTxData 构造未签名交易 返回值： hex(rlp(原始交易内容)) needSignContent(需要签名的内容)  错误
func constructUnSignTxData(currency string, blockNum uint32, clauses []database.Clause, gas uint64) (string, string, error) {
	currency = strings.ToLower(currency)
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
		var tokenContarct string
		if currency == "vtho" {
			tokenContarct, _ = initialization.TokenContractMap[currency]
		} else {
			tokenContarct = currency
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
	d, err := rlp.EncodeToBytes(trxBuild)
	if err != nil {
		return "", "", err
	}

	return fmt.Sprintf("%0x", d),
		fmt.Sprintf("%0x", trxBuild.SigningHash().Bytes()),
		nil
}
