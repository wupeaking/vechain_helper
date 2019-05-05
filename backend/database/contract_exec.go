package database

import (
	"github.com/jmoiron/sqlx"
)

// 数据库层相关的操作

// InsertContractExecLog  插入智能合约执行记录 此函数表示一个交易中只有一个clause
func InsertContractExecLog(db *sqlx.DB, requestID, txID string,
	methodName, args string,
	sender, contract string) error {

	sqlStr := `insert into contract_exec_log (request_id, tx_id,
 					method_name, args, clauses,
					sender, contract_address) values (?, ?,
					?, ?, ?,
					?, ?)`

	_, err := db.Exec(sqlStr, requestID, txID,
		methodName, args, 0,
		sender, contract)

	return err
}

// UpdateContractExecLog  更新合约执行状态
func UpdateContractExecStatus(db *sqlx.DB, gasUsed uint64, vtho string,
	vet string, status int, blockNum uint64, txID string) error {

	sqlStr := `update contract_exec_log set gas_used=?, vtho_used=?, vet=?, status=?, block_num=? where tx_id=?`

	_, err := db.Exec(sqlStr, gasUsed, vtho, vet, status, blockNum, txID)

	return err
}

// QueryUnCommitContractTx  查询还未确认其执行结果的智能合约交易
func QueryUnCommitContractTx(db *sqlx.DB) ([]string, error) {

	sqlStr := `select  tx_id from contract_exec_log where status = 0 limit 0, 100`

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
