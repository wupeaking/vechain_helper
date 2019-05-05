package apihandler

import (
	"github.com/labstack/echo"
	"github.com/wupeaking/vechainhelper/initialization"
	"net/http"
)

func errPackage(ctx echo.Context, err initialization.ErrDesc) {
	// 封装数据 返回
	ctx.JSON(http.StatusOK,
		struct {
			Code string `json:"errCode"`
			Msg  string `json:"errMsg"`
		}{
			Code: err.ErrCode(),
			Msg:  err.ErrMsg(),
		},
	)
}
