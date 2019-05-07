package database

import (
	"fmt"
	"github.com/jmoiron/sqlx"
	"math/big"
)

// 数据库层相关的操作
type Clause struct {
	To     string
	Amount *big.Int
}

// InsertTxOrder  插入交易请求
func InsertTxOrder(db *sqlx.DB, requestID, from, to, currency, amount, gasUsed string, status int, rlp string) error {
	// 拼接SQL
	sqlStr := fmt.Sprintf("insert into transaction_records (request_id, `from`,"+
		" `to`, currency, amount, gas_used, status, rlp) values ('%s', '%s', '%s', '%s', '%s', '%s', '%d', '%s') ",
		requestID, from, to, currency, amount, gasUsed, status, rlp)

	println(sqlStr)
	_, err := db.Exec(sqlStr)
	return err
}

// InsertTxStatus  插入交易状态
func InsertTxStatus(db *sqlx.DB, txID, requestID string, status int) error {
	sqlStr := fmt.Sprintf(`insert into transfer_status (tx_hash, request_id, status) values ( '%s', '%s', %d )`,
		txID, requestID, status)

	_, err := db.Exec(sqlStr)
	return err

}

//SelectTxRlp 查询交易的RLP内容
func SelectTxRlp(db *sqlx.DB, id string) (string, error) {
	sqlStr := fmt.Sprintf(`select rlp from  transaction_records where request_id = '%s'`,
		id)
	var result string
	err := db.QueryRowx(sqlStr).Scan(&result)

	return result, err

}
