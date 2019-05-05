# CDIB
the car's data in the blockchain
汽车数据上链服务

![build status](https://travis-ci.com/wupeaking/CDIB.svg?token=hr2sptwtPB3qdtD9pcsz&branch=master)

### 启动唯链客户端

```shell
$> docker run  --privileged -d \
-v /root/.org.vechain.thor:/root/.org.vechain.thor -p 8669:8669 -p 11235:11235 -p 11235:11235/udp \
--name thor-node vechain/thor --network test --api-addr 0.0.0.0:8669
```


### 服务说明

- 合约服务(contractserver.x)

    >典型的web服务， 用于提供API接口进行合约的创建, 调用， 以及唯链本币和各种ERC20代币的转账服务

- 异步通知服务(asynctash.x)

    > 由于区块链的非实时性, 该服务用于进行合约状态确认, 交易状态更新， 时间日志记录等功能的实现
    

### 部署方式

#### 二进制形式编译

```shell
# 克隆源码 
$> git clone github.com/wupeaking/CDIB.git

# 编译
$> cd CDIB && make

# CDIB目录下会生成contractserver.x和asynctash.x二进制文件
        
```

#### docker形式编译
```shell
# docker镜像已经加入了CI中 只需要拉取镜像即可
$> docker pull wupengxin/cdib
```    

#### 启动参数说明
```shell
./contractserver.x --help
  -abipath string
    	abi文件路径 (default "./abi.json")
  -dbaddr string
    	数据库ip:port (default "127.0.0.1:3306")
  -dbname string
    	数据库名称 (default "cdib")
  -dbpasswd string
    	数据库密码 (default "888888")
  -dbuser string
    	数据库用户名 (default "root")
  -debug
    	开启debug模式
  -port string
    	服务端监听端口 (default "31312")
  -produce
    	是否是生产环境
  -rpcaddr string
    	rpc地址 (default "http://127.0.0.1:8669")
  -rpcpassword string
    	rpc地址 (default "admin")
  -rpcuser string
    	rpc地址 (default "admin")
 
 ./asynctasks.x --help
   -dbaddr string
     	数据库ip:port (default "127.0.0.1:3306")
   -dbname string
     	数据库名称 (default "cdib")
   -dbpasswd string
     	数据库密码 (default "888888")
   -dbuser string
     	数据库用户名 (default "root")
   -debug
     	开启debug模式
   -produce
     	是否是生产环境
   -rpcaddr string
     	rpc地址 (default "http://127.0.0.1:8669")
   -rpcpassword string
     	rpc地址 (default "admin")
   -rpcuser string
     	rpc地址 (default "admin")
 
```

#### 启动示例
```shell
# 二进制文件启动示例
$> contractserver.x  -rpcaddr http://192.168.2.144:8669
$> asynctasks.x  -rpcaddr http://192.168.2.144:8669

# docker启动示例

# 启动合约服务
$> docker run --name cdib-web -p 31312:31312 -d wupengxin/cdib ./contractserver.x \
 -rpcaddr http://192.168.2.144:8669 -dbaddr 127.0.0.1:3306 -dbpasswd passwd \
 -dbuser user -dbname cdib -produce true -abipath ./abi.json
 
 # 启动异步任务服务
$> docker run --name cdib-web -p 31312:31312 -d wupengxin/cdib ./asynctasks.x \
 -rpcaddr http://192.168.2.144:8669 -dbaddr 127.0.0.1:3306 -dbpasswd passwd \
 -dbuser user -dbname cdib  -produce true

```

### 开发测试
    
- 使用的测试账户私钥和名称
    > privkey:
51600340663997437947925368612617324146046492262312153951917683564987362429915
或者 
7214c201af45969199012141984ee7898721e4fa7f232975ad58d1661335cbdb(hex)

    > address:
0x0bc61a68a88fac3081548fc9f185f08b3ab6077c

- 测试链合约地址
    > contract address:
0x55cac45d72232217fe868d29df309b4f17c10911
