package initialization

var (
	// vechain 节点配置
	// RPCAddr rpc地址
	RPCAddr string
	// RPCUser rpc用户名
	RPCUser string
	// RPCPassword rpc密码
	RPCPassword string
	// TimeOut http超时时间 单位为S
	TimeOut = 10
	// ChainTag 链标签 测试链为0x27 生产链为0x4a
	ChainTag byte

	// Port 服务端口号
	Port = "31312"
	// Debug 是否开启debug模式
	Debug = false

	// mysql 配置
	// DBAddr mysql地址
	DBAddr = "127.0.0.1:3306"
	// DBUser 用户名
	DBUser = "root"
	// DBPasswd 密码
	DBPasswd = "888888"
	// DBName 数据库名
	DBName = "cdib"
	// DBMaxIdleTime 数据库连接池最大保持空闲时间ms
	DBMaxIdleTime = 1000
	// DBMaxIdle 数据库连接池最大保持空闲个数
	DBMaxIdle = 1
	// DBMaxOverflow 最大容许溢出数量
	DBMaxOverflow = 50

	// IsProduce 是否是生产环境
	IsProduce bool

	// ABIFile abi路径
	ABIFile = "./abi.json"
	//ContractAddr 合约地址 测试环境为0x55cac45d72232217fe868d29df309b4f17c10911
	ContractAddr = "0x55cac45d72232217fe868d29df309b4f17c10911"

	//TokenContractMap 符合和地址映射
	TokenContractMap = map[string]string{
		"vet":  "",
		"vtho": "0x0000000000000000000000000000456E65726779",
		"vtt":  "0x0000000000000000000000000000456E65726779",
	}
)

//PrivateKey 私钥
var PrivateKey string

//PublicKey 公钥 `
var PublicKey string

//TestPrivateKey 测试环境 私钥
const TestPrivateKey = `-----BEGIN PRIVATE KEY-----
-----END PRIVATE KEY-----`

//TestPublicKey 测试环境 公钥
const TestPublicKey = `-----BEGIN RSA PUBLICK KEY-----
-----END RSA PUBLICK KEY-----`

// ProducePrivateKey 生产环境
const ProducePrivateKey = `-----BEGIN PRIVATE KEY-----
-----END PRIVATE KEY-----`

//ProducePublicKey 生产环境 公钥
const ProducePublicKey = `-----BEGIN RSA PUBLICK KEY-----
-----END RSA PUBLICK KEY-----`

//SwitchKey 根据环境切换公私
func SwitchKey() {
	if IsProduce {
		PrivateKey = ProducePrivateKey
		PublicKey = ProducePublicKey
	} else {
		PrivateKey = TestPrivateKey
		PublicKey = TestPublicKey
	}
}
