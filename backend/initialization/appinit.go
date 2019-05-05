package initialization

import (
	"fmt"
	"github.com/jmoiron/sqlx"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	"github.com/labstack/gommon/log"
	"github.com/wupeaking/vechainhelper/vechainclient"
	"net/http"
)

var (
	// WebApp web实例
	WebApp *echo.Echo
	// DB 数据实例
	DB *sqlx.DB

	//Version
	Version string
)

// CustomContext 自定义上下文
type CustomContext struct {
	echo.Context
	// 数据库实例
	DB *sqlx.DB
	// vechain 客户端
	BlockClient *vechain.Client
}

// NewDB 新的全局DB
func NewDB() (*sqlx.DB, error) {
	if DB != nil {
		return DB, nil
	}
	// 初始化数据库
	var db *sqlx.DB
	db, err := MySQLInit()
	DB = db
	return DB, err
}

// NewWebApp 新的web实例
func NewWebApp() (*echo.Echo, error) {
	if WebApp != nil {
		return WebApp, nil
	}
	WebApp = echo.New()
	WebApp.HideBanner = true
	WebApp.HTTPErrorHandler = httpErrorHandler
	WebApp.Use(middleware.LoggerWithConfig(middleware.LoggerConfig{
		Format: "[${time_rfc3339}] method=${method} uri=${uri} status=${status} remote_ip=${remote_ip} \n",
	}))
	WebApp.Logger.(*log.Logger).SetHeader(`[${time_rfc3339_nano}] ` +
		`${long_file}@${line}`)
	if Debug {
		WebApp.Logger.SetLevel(log.DEBUG)
	} else {
		WebApp.Logger.SetLevel(log.INFO)
	}

	db, err := NewDB()
	if err != nil {
		WebApp.Logger.Fatal("连接数据库失败: ", err.Error())
		return WebApp, err
	}

	// 创建一个全局客户端
	vc, _ := vechain.NewVeChainClient(RPCAddr, RPCUser, RPCPassword, TimeOut)

	// 使用一个自定义中间件 将db注入上下文中
	WebApp.Use(func(h echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			cc := &CustomContext{c, db, vc}
			return h(cc)
		}
	})
	return WebApp, nil
}

func httpErrorHandler(err error, c echo.Context) {
	var (
		code = http.StatusInternalServerError
		msg  interface{}
	)
	if he, ok := err.(*echo.HTTPError); ok {
		code = he.Code
		msg = he.Message
		if he.Internal != nil {
			msg = fmt.Sprintf("%v, %v", err, he.Internal)
		}
	} else if WebApp.Debug {
		msg = err.Error()
	} else {
		msg = http.StatusText(code)
	}

	// Send response
	if !c.Response().Committed {
		if c.Request().Method == echo.HEAD {
			err = c.NoContent(code)
		} else {
			//
			err = c.JSON(200, map[string]string{"errCode": InternalServerError.ErrCode(), "data": "", "errMsg": msg.(string)})
		}
		if err != nil {
			WebApp.Logger.Error(err)
		}
	}
}
