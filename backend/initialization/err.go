package initialization

// ErrDesc 错误列表
type ErrDesc struct {
	errCode string
	errMsg  string
}

func (e ErrDesc) String() string {
	return e.errMsg
}

// ErrCode ...
func (e ErrDesc) ErrCode() string {
	return e.errCode
}

// ErrMsg ...
func (e ErrDesc) ErrMsg() string {
	return e.errMsg
}

func newErr(code, msg string) ErrDesc {
	return ErrDesc{code, msg}
}

// 错误码定义
var (
	InternalServerError = newErr("10500", "内部服务错误")
	Success             = newErr("0", "成功")
	ParamError          = newErr("10000", "参数错误")
	PrivKeyError        = newErr("20000", "私钥错误")
	DeployError         = newErr("20001", "部署合约错误")
	TxSignError         = newErr("20002", "交易签名错误")
	EncodeError         = newErr("20003", "编码错误")
	CallContractErr     = newErr("20004", "调用合约出错")
	DataBaseErr         = newErr("20005", "数据库操作错误")
	CallAPIErr          = newErr("20006", "API调用错误")
	BalanceErr          = newErr("20007", "余额不足")
	TransferErr         = newErr("20008", "交易订单错误")
)
