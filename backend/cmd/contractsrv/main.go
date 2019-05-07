package main

import (
	"flag"
	"github.com/wupeaking/vechainhelper/apihandler"
	"github.com/wupeaking/vechainhelper/initialization"
)

func init() {
	// rpc 配置
	flag.StringVar(&initialization.RPCAddr, "rpcaddr", "http://127.0.0.1:8669", "rpc地址")
	flag.StringVar(&initialization.RPCUser, "rpcuser", "admin", "rpc地址")
	flag.StringVar(&initialization.RPCPassword, "rpcpassword", "admin", "rpc地址")

	flag.StringVar(&initialization.Port, "port", initialization.Port, "服务端监听端口")
	flag.BoolVar(&initialization.Debug, "debug", initialization.Debug, "开启debug模式")

	// 数据库
	flag.StringVar(&initialization.DBAddr, "dbaddr", initialization.DBAddr, "数据库ip:port")
	flag.StringVar(&initialization.DBName, "dbname", initialization.DBName, "数据库名称")
	flag.StringVar(&initialization.DBUser, "dbuser", initialization.DBUser, "数据库用户名")
	flag.StringVar(&initialization.DBPasswd, "dbpasswd", initialization.DBPasswd, "数据库密码")
	flag.BoolVar(&initialization.IsProduce, "produce", false, "是否是生产环境")

	flag.StringVar(&initialization.ABIFile, "abipath", initialization.ABIFile, "abi文件路径")

	flag.Parse()
}

func main() {
	// 创建web实例
	app, err := initialization.NewWebApp()
	if err != nil {
		app.Logger.Fatal(err)
	}
	app.Debug = initialization.Debug

	if initialization.IsProduce {
		initialization.ChainTag = 0x4a
	} else {
		initialization.ChainTag = 0x27
	}
	initialization.SwitchKey()

	// Routes
	app.GET("/balance/:account", apihandler.Balance)
	app.PUT("/unsigned_tx", apihandler.UnSignTx)
	app.PUT("/push_tx", apihandler.PushTx)

	// Start server
	app.Logger.Info("version: ", initialization.Version)
	app.Logger.Fatal(app.Start(":" + initialization.Port))
}
