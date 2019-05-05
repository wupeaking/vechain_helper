package initialization

import (
	"fmt"
	_ "github.com/go-sql-driver/mysql" //init mysql
	"github.com/jmoiron/sqlx"
	"time"
)

//MySQLInit mysql的初始化
func MySQLInit() (*sqlx.DB, error) {

	dbURI := fmt.Sprintf(
		"%s:%s@tcp(%s)/%s?parseTime=true&charset=utf8mb4",
		DBUser,
		DBPasswd,
		DBAddr,
		DBName)

	DB, err := sqlx.Open("mysql", dbURI)
	if err != nil {
		return nil, err
	}

	DB.SetConnMaxLifetime(time.Millisecond * time.Duration(DBMaxIdleTime))
	DB.SetMaxIdleConns(DBMaxIdle)
	DB.SetMaxOpenConns(DBMaxOverflow + DBMaxIdle)

	err = DB.Ping()
	if err != nil {
		return nil, err
	}
	return DB, nil
}
