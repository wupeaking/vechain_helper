package vechain

// vechain RPC客户端包

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	gorequest "github.com/wupeaking/vechainhelper/utils"
	"math/big"
	"time"
)

// Client vechain客户端
type Client struct {
	Addr    string // rpc地址
	User    string // rpc用户名
	Passwd  string // rpc密码
	timeout int    // 超时时间
}

var (
	//ErrNotExist 不存在错误
	ErrNotExist = errors.New("not exist")
)

// NewVeChainClient 新的客户端
func NewVeChainClient(rawurl string, rpcUser, rpcPasswd string, timeout int) (*Client, error) {
	xCli := new(Client)
	xCli.Addr = rawurl
	xCli.User = rpcUser
	xCli.Passwd = rpcPasswd
	xCli.timeout = timeout
	return xCli, nil
}

// BlockInfo 获取最新区块信息
func (vc *Client) BlockInfo(ctx context.Context, blkNum uint64) (*BlockDetail, error) {
	request := gorequest.New()
	request.Header.Set("Content-type", "application/json")
	var path string
	if blkNum == 0 {
		path = "/blocks/best"
	} else {
		path = fmt.Sprintf("/blocks/%d", blkNum)
	}
	url := gorequest.SpliceURL(vc.Addr, path)
	_, respBody, err := request.Get(url).Timeout(time.Duration(vc.timeout) * time.Second).End()
	if err != nil {
		return nil, err[0]
	}

	respStru := struct {
		BlockDetail
	}{}
	e := json.Unmarshal([]byte(respBody), &respStru)
	if e != nil {
		return nil, e
	}
	if respStru.BlockDetail.BlockNum == 0 {
		return nil, errors.New("返回区块高度为0")
	}

	return &respStru.BlockDetail, nil
}

// GetTxReceiptByhash  获取交易hash获取交易简介
func (vc *Client) GetTxReceiptByhash(ctx context.Context, txHash string) (*TransactionReceipt, error) {
	request := gorequest.New()
	request.Header.Set("Content-type", "application/json")
	url := gorequest.SpliceURL(vc.Addr, fmt.Sprintf("/transactions/%s/receipt", txHash))
	_, respBody, err := request.Get(url).Timeout(time.Duration(vc.timeout) * time.Second).End()
	if err != nil {
		return nil, err[0]
	}
	if respBody == "null" {
		return nil, ErrNotExist
	}

	respStru := struct {
		TransactionReceipt
	}{}
	e := json.Unmarshal([]byte(respBody), &respStru)
	if e != nil {
		return nil, e
	}
	if respStru.GasUsed == 0 {
		return nil, errors.New("交易不存在")
	}

	return &respStru.TransactionReceipt, nil
}

// GetTxInfoByhash  获取交易hash获取交易简介
func (vc *Client) GetTxInfoByhash(ctx context.Context, txHash string) (*Transaction, error) {
	request := gorequest.New()
	request.Header.Set("Content-type", "application/json")
	url := gorequest.SpliceURL(vc.Addr, fmt.Sprintf("/transactions/%s", txHash))
	_, respBody, err := request.Get(url).Timeout(time.Duration(vc.timeout) * time.Second).End()
	if err != nil {
		return nil, err[0]
	}

	if respBody == "null" {
		return nil, ErrNotExist
	}

	respStru := struct {
		Transaction
	}{}
	e := json.Unmarshal([]byte(respBody), &respStru)
	if e != nil {
		return nil, e
	}
	if respStru.Hash == "" {
		return nil, errors.New("交易不存在")
	}

	return &respStru.Transaction, nil
}

// BalanceByAddress  获取账户余额
func (vc *Client) BalanceByAddress(ctx context.Context, addr string) (*Balances, error) {
	request := gorequest.New()
	request.Header.Set("Content-type", "application/json")
	url := gorequest.SpliceURL(vc.Addr, fmt.Sprintf("/accounts/%s", addr))
	_, respBody, err := request.Get(url).Timeout(time.Duration(vc.timeout) * time.Second).End()
	if err != nil {
		return nil, err[0]
	}

	balance := new(Balances)
	balance.Balance, _ = new(big.Int).SetString("0", 0)
	balance.Energy, _ = new(big.Int).SetString("0", 0)

	respStru := struct {
		Balance string `json:"balance"`
		Energy  string `json:"energy"`
		HasCode bool   `json:"hasCode"`
	}{}

	e := json.Unmarshal([]byte(respBody), &respStru)
	if e != nil {
		return balance, e
	}
	if respStru.Balance == "" {
		return balance, nil
	}

	b, bf := new(big.Int).SetString(respStru.Balance, 0)
	if !bf {
		return balance, errors.New("解析余额参数失败")
	}
	energey, ef := new(big.Int).SetString(respStru.Energy, 0)
	if !ef {
		return balance, errors.New("解析余额参数失败")
	}
	balance.Balance = b
	balance.Energy = energey

	return balance, nil
}

// PushTx 推送交易
func (vc *Client) PushTx(ctx context.Context, content string) (string, error) {
	request := gorequest.New()
	request.Header.Set("Content-type", "application/json")
	url := gorequest.SpliceURL(vc.Addr, "/transactions")
	requestBody := fmt.Sprintf(`{"raw": "0x%s"}`, content)

	resp, respBody, err := request.Post(url).Timeout(time.Duration(vc.timeout) * time.Second).
		SendString(requestBody).End()

	if err != nil {
		return "", err[0]
	}
	if resp.StatusCode != 200 {
		return "", fmt.Errorf("resp: %v, respBody: %v", resp, respBody)
	}

	respStru := struct {
		TxID string `json:"id"`
	}{}

	e := json.Unmarshal([]byte(respBody), &respStru)
	if e != nil {
		return "", e
	}
	return respStru.TxID, nil
}

// SimulateContract  模拟执行账户
func (vc *Client) SimulateContract(ctx context.Context, data string, value string, contractAddr string) (ContractRet, error) {
	request := gorequest.New()
	request.Header.Set("Content-type", "application/json")
	url := gorequest.SpliceURL(vc.Addr, fmt.Sprintf("accounts/*?revision=best"))

	// 构建请求参数
	requestBody := fmt.Sprintf(`
	{
		"clauses": [
    		{
      			"to": "%s",
      			"value": "0x%s",
      			"data": "%s"
    		}
  		],
		"gas"   :  30000000,
		"gasPrice" : "0"
	}`, contractAddr, value, data)

	ret := make([]ContractRet, 0)
	resp, respBody, err := request.Post(url).Timeout(time.Duration(vc.timeout) * time.Second).
		SendString(requestBody).End()
	if err != nil {
		return ContractRet{}, err[0]
	}

	if resp.StatusCode != 200 {
		return ContractRet{}, fmt.Errorf("resp: %v, respBody: %v", resp, respBody)
	}

	e := json.Unmarshal([]byte(respBody), &ret)
	if e != nil {
		return ContractRet{}, e
	}

	return ret[0], nil
}

// FilterEventLog  过滤事件日志
func (vc *Client) FilterEventLog(ctx context.Context, sBlock, eBlock uint64, addr, topic string) ([]EventLog, error) {
	request := gorequest.New()
	request.Header.Set("Content-type", "application/json")
	url := gorequest.SpliceURL(vc.Addr, fmt.Sprintf("/logs/event"))

	// 构建请求参数
	requestBody := fmt.Sprintf(`
	{
  			"range": {
    			"unit": "block",
				"from": %d,
				"to": %d
			},
  		"criteriaSet": [
    		{
      			"address": "%s",
      			"topic0": "%s"
			}
  		],
  		"order": "asc"
	}`, sBlock, eBlock, addr, topic)

	ret := make([]EventLog, 0)
	resp, respBody, err := request.Post(url).Timeout(time.Duration(vc.timeout) * time.Second).
		SendString(requestBody).End()
	if err != nil {
		return ret, err[0]
	}

	if resp.StatusCode != 200 {
		return ret, fmt.Errorf("resp: %v, respBody: %v", resp, respBody)
	}

	e := json.Unmarshal([]byte(respBody), &ret)
	if e != nil {
		return ret, e
	}

	return ret, nil
}
