package vechain

import (
	"math/big"
)

/*
{
  "number": 1,
  "id": "0x00000001c458949985a6d86b7139690b8811dd3b4647c02d4f41cdefb7d32327",
  "size": 238,
  "parentID": "0x00000002a0c772179aa43cb6bb55d0b31369f9e92014c88a50b2cb99f9be1c5d",
  "timestamp": 1523156271,
  "gasLimit": 10000000,
  "beneficiary": "0x7567d83b7b8d80addcb281a71d54fc7b3364ffed",
  "gasUsed": 0,
  "totalScore": 101,
  "txsRoot": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
  "stateRoot": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
  "receiptsRoot": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
  "signer": "0x7567d83b7b8d80addcb281a71d54fc7b3364ffed",
  "isTrunk": true,
  "transactions": [
    "0x4de71f2d588aa8a1ea00fe8312d92966da424d9939a511fc0be81e65fad52af8"
  ]
}
*/

// BlockDetail 区块详情
type BlockDetail struct {
	BlockNum     uint64   `json:"number"`
	Hash         string   `json:"id"`           //区块hash
	TimeStamp    uint64   `json:"timestamp"`    // 时间戳
	Trxs         []string `json:"transactions"` // 交易列表
	Producer     string   `json:"signer"`
	PrvBlock     string   `json:"parentID"`  // 前一个区块
	TrxMroot     string   `json:"txsRoot"`   // 交易默克尔树
	StatMroot    string   `json:"stateRoot"` // 交易默克尔树
	ReceiptMroot string   `json:"receiptsRoot"`
}

/*
{
  "id": "0x4de71f2d588aa8a1ea00fe8312d92966da424d9939a511fc0be81e65fad52af8",
  "chainTag": 1,
  "blockRef": "0x00000001511fc0be",
  "expiration": 30,
  "clauses": [],
  "gasPriceCoef": 128,
  "gas": 21000,
  "origin": "0x7567d83b7b8d80addcb281a71d54fc7b3364ffed",
  "nonce": "0xd92966da424d9939",
  "dependsOn": "null",
  "size": 180,
  "meta": {
    "blockID": "0x00000001c458949985a6d86b7139690b8811dd3b4647c02d4f41cdefb7d32327",
    "blockNumber": 1,
    "blockTimestamp": 1523156271
  },
  "raw": "0xf86981ba800adad994000000000000000000000000000000000000746f82271080018252088001c0b8414792c9439594098323900e6470742cd877ec9f9906bca05510e421f3b013ed221324e77ca10d3466b32b1800c72e12719b213f1d4c370305399dd27af962626400"
}
*/

// Transaction ...
type Transaction struct {
	Hash         string `json:"id"`
	BlockRef     string `json:"blockRef"`
	Expiration   int    `json:"expiration"`
	GasPriceCoef int    `json:"gasPriceCoef"`
	Gas          int    `json:"gas"`
	Origin       string `json:"origin"`
	Nonce        string `json:"nonce"`
	Meta         struct {
		BlockID        string `json:"blockID"`
		BlockNum       int64  `json:"blockNumber"`
		BlockTimeStamp int64  `json:"blockTimestamp"`
	} `json:"meta"`
}

/*
{
  "gasUsed": 21000,
  "gasPayer": "0x7567d83b7b8d80addcb281a71d54fc7b3364ffed",
  "paid": "0x723daf2",
  "reward": "0x723daf2",
  "reverted": false,
  "outputs": [
    {
      "contractAddress:'0x7567d83b7b8d80addcb281a71d54fc7b3364ffed'": null,
      "events": [
        {
          "address": "0x7567d83b7b8d80addcb281a71d54fc7b3364ffed",
          "topics": "0x4de71f2d588aa8a1ea00fe8312d92966da424d9939a511fc0be81e65fad52af8",
          "data": "0x4de71f2d588aa8a1ea00fe8312d92966da424d9939a511fc0be81e65fad52af8"
        }
      ],
      "transfers": [
        {
          "sender": "0x7567d83b7b8d80addcb281a71d54fc7b3364ffed",
          "recipient": "0x7567d83b7b8d80addcb281a71d54fc7b3364ffed",
          "amount": "0x123f"
        }
      ]
    }
  ],
  "meta": {
    "blockID": "0x00000001c458949985a6d86b7139690b8811dd3b4647c02d4f41cdefb7d32327",
    "blockNumber": 1,
    "blockTimestamp": 1523156271,
    "txID": "0x4de71f2d588aa8a1ea00fe8312d92966da424d9939a511fc0be81e65fad52af8",
    "txOrigin": "0x7567d83b7b8d80addcb281a71d54fc7b3364ffed"
  }
}
*/

// TransactionReceipt 交易收据格式
type TransactionReceipt struct {
	GasUsed  int64  `json:"gasUsed"`
	GasPayer string `json:"gasPayer"`
	Reverted bool   `json:"reverted"`
	Meta     struct {
		BlockID        string `json:"blockID"`
		BlockNum       int64  `json:"blockNumber"`
		BlockTimeStamp int64  `json:"blockTimestamp"`
		TxID           string `json:"txID"`
		TxOrigin       string `json:"txOrigin"`
	} `json:"meta"`
	Outputs []output `json:"outputs"`
}

// output 输出信息
type output struct {
	ContractAddress string     `json:"contractAddress"`
	Events          []event    `json:"events"`
	Transfers       []transfer `json:"transfers"`
}

type event struct {
	Address string   `json:"address"`
	Topics  []string `json:"topics"`
	Data    string   `json:"data"`
}

type meta struct {
	BlockID        string `json:"blockID"`
	BlockNum       int64  `json:"blockNumber"`
	BlockTimeStamp int64  `json:"blockTimestamp"`
	TxID           string `json:"txID"`
	TxOrigin       string `json:"txOrigin"`
}

type transfer struct {
	Sender    string `json:"sender"`
	Recipient string `json:"recipient"`
	Amount    string `json:"amount"`
}

// Balances 余额详情
type Balances struct {
	Balance *big.Int
	Energy  *big.Int
}

/*
{
  "data": "0x",
  "events": [],
  "transfers": [],
  "gasUsed": 0,
  "reverted": true,
  "vmError": "insufficient balance for transfer"
}
*/

// ContractRet 执行合约返回的结果
type ContractRet struct {
	Data     string  `json:"data"`
	Events   []event `json:"events"`
	GasUsed  uint64  `json:"gasUsed"`
	Reverted bool    `json:"reverted"`
	VMErr    string  `json:"vmError"`
}

// EventLog 事件日志
type Event = event
type EventLog struct {
	Event     `json:",inline"`
	Meta      meta `json:"meta"`
	EventName string
}
