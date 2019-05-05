package database

import (
	"fmt"
	"github.com/jmoiron/sqlx"
	"math/big"
	"strings"
)

// 数据库层相关的操作
type Clause struct {
	To     string
	Amount *big.Int
}

// InsertTxOrder  插入交易请求
func InsertTxOrder(db *sqlx.DB, requestID, from, currency, gasUsed string, status int, clauses []Clause) error {
	// 拼接SQL
	valueArr := make([]string, 0, len(clauses))
	for i := 0; i < len(clauses); i++ {
		valueArr = append(valueArr,
			fmt.Sprintf("('%s', %d, '%s', '%s', "+
				"'%s', '%s', '%s', %d)",
				requestID, i, from, clauses[i].To,
				currency, clauses[i].Amount.String(), gasUsed, status))
	}
	valueStr := strings.Join(valueArr, ",")

	sqlStr := fmt.Sprintf("insert into transfer_order (request_id, clause, `from`,"+
		" `to`, currency, amount, gas_used, status) values %s ", valueStr)

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

// QueryUnCommitTransfer  查询还未确认转账
func QueryUnCommitTransfer(db *sqlx.DB) ([]string, error) {

	sqlStr := `select  tx_hash from transfer_status where status = 0 limit 0, 100`

	rows, err := db.Queryx(sqlStr)
	if err != nil {
		return nil, err
	}
	result := make([]string, 0)

	for rows.Next() {
		var tmp string
		rows.Scan(&tmp)
		result = append(result, tmp)
	}

	return result, nil
}

// UpdateTransferStatus  更新转账状态
func UpdateTransferStatus(db *sqlx.DB, gasUsed uint64, status int, blockNum uint64, txID string) error {

	sqlStr := `update transfer_status set gas_used=?, status=?, block_num=? where tx_hash=?`

	_, err := db.Exec(sqlStr, gasUsed, status, blockNum, txID)

	return err
}
