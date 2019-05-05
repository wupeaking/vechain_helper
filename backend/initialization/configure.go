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
MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAMVBWpA2gh9nlq3nwYxCVXfBQE0sVS53+z9JDT7wVTBxfnbU0kZPbA1hpExaI00hYqmHXaXTktm4RxE+nWLtWaM+loQarnitGFrEL65BJTSTsW6UMzbI0sp7UFDHUVTuhc+JrAqPObCygYWVI4UFvcJ1nj8+aqaQxyfKsiVQB73LAgMBAAECgYBPuXJZBy7gcoW8FAduIQFaPYk3p8tl1Kh/k47++TP1OGncrXevYzpQzj4Rffz2l5/A1S1McI7R4GEY3y3NZhDr69g169wjmQnNNUhh/ynP4vyP3BctBJhRxBU0k756Y7RESogSjqvgreZbX51mQ7vkj8pBaO08/Hys9wR2+aAEwQJBAO23dalibGm1HSzy42/OfcDHmQ/a55sINWEcZMMMvTTbennouEjdkbHsUYlJkFSXqW8D8y1I0yzODjwBM5iUR6cCQQDUbToqTJgoqSctaZD8/JINKxAeI8y0+A+vqyPUw+BOSJoyDM04/7t6DwtRvUqU1F6nW7w5gVVsOuIpd9NZXV09AkASZbBle4iIZcvsPp/7dy+kS848u+RQy0HWUiw6LDI4dQP1i103xm4QJwnoZhkVcudaACRBzPEK9qeDXVRw6ojhAkB/o94mWn23OOSciekfyler5+s4YQR43PD3+hp+lu/pugBFAKIzlJ4+2llP1TDCOtVhNGLmHsuIS91nU2PAN7R1AkB5CX+q2QFC9AfBr8KMOi/gsOcWD3t+L2R81kcCjUXbVTdgPscfCqLmoHSlk3bV2codhSlf04Tdo1iKosZRKlrp
-----END PRIVATE KEY-----`

//TestPublicKey 测试环境 公钥
const TestPublicKey = `-----BEGIN RSA PUBLICK KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDFQVqQNoIfZ5at58GMQlV3wUBNLFUud/s/SQ0+8FUwcX521NJGT2wNYaRMWiNNIWKph12l05LZuEcRPp1i7VmjPpaEGq54rRhaxC+uQSU0k7FulDM2yNLKe1BQx1FU7oXPiawKjzmwsoGFlSOFBb3CdZ4/PmqmkMcnyrIlUAe9ywIDAQAB
-----END RSA PUBLICK KEY-----`

// ProducePrivateKey 生产环境
const ProducePrivateKey = `-----BEGIN PRIVATE KEY-----
MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAIvJNzHdpYTcSffVfx2Pu+rnO/0ON8HtoJ4TnTBCf89AFfCPCXx8WYXpnNbVbNDK6GNAjv2jsBT0udiGFXlyib23Y/NFzOr8en0ZIs0q0cMYZG4jpv2wMQunKXnZcRDhv8pv64jtviRi8a+8GLUH0QGL96KhEZ0ifQ5UoMqTiZjFAgMBAAECgYAaJ23CULw1XZohWrrL5ya7zsP0lwJrsHBK41SXwPl054KzXa/isMl3Orxznb8cWbqdR2j5n/TEFv3muz+tV3bZ117CUPXMW4rOle0VOKBpEaf5d9VPlK1EcKsjGR+iFwTO5kaz9xcW8+bcexUZ70mrOSao0TZ0ujrhqGIUJeDGwQJBAMfo+CRzrxv1cMzoqQku4WqpECaybPWf1SgPZiLni7Ghow2aR4IQbjaRrakS4Z+xA15LzjVxphB6C0UF4qSyspkCQQCzAbBvuGhm0kAZteEJgnG7Z+AZyrKCQ4Z1bGw6bQ9MyORNiB3Zg5R00ujwX/QicbJgPS380n1sdhdT1prFRh8NAkBMgKM1j+/bSzo3sHG/yekJ4FkF9hIsjVYNVpdHlESpXaoAcqIa7B7BU06Z/VfKvPsFAw2O9kcO1yWo7G+nh5tBAkAPLD57ScM3q+yZAUyg1Li1LNnW9dJprjWQcG9ACIx6crC/TaFSFZAY0uPBtDBqVv7Kn4TtYB4Xem8BwTf/LrFlAkA5wgGDsh4zOjHzKDiqoyVJ3p80MCnWCWwp5AxqB5dwsqv2APXne+SbaZUXYK7pzaNOtqC3/ZQts6Z3nPIl+I3C
-----END PRIVATE KEY-----`

//ProducePublicKey 生产环境 公钥
const ProducePublicKey = `-----BEGIN RSA PUBLICK KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCLyTcx3aWE3En31X8dj7vq5zv9DjfB7aCeE50wQn/PQBXwjwl8fFmF6ZzW1WzQyuhjQI79o7AU9LnYhhV5com9t2PzRczq/Hp9GSLNKtHDGGRuI6b9sDELpyl52XEQ4b/Kb+uI7b4kYvGvvBi1B9EBi/eioRGdIn0OVKDKk4mYxQIDAQAB
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
