# vechian_helper
一个唯链支付助手后端服务



![build status](https://travis-ci.com/wupeaking/CDIB.svg?token=hr2sptwtPB3qdtD9pcsz&branch=master)

## 如何部署私有的后端应用

### 启动唯链客户端

```shell
$> docker run  --privileged -d \
-v /root/.org.vechain.thor:/root/.org.vechain.thor -p 8669:8669 -p 11235:11235 -p 11235:11235/udp \
--name thor-node vechain/thor --network test --api-addr 0.0.0.0:8669
```


### 部署方式

#### 二进制形式编译

```shell
# 克隆源码 
$> git clone github.com/wupeaking/vechain_helper.git

# 编译
$> cd vechain_helper/backend && make

# backend目录下会生成contractserver.x二进制文件
        
```

#### docker形式编译

```shell
# docker镜像已经加入了CI中 只需要拉取镜像即可
$> docker pull wupengxin/vechain_helper
```    

#### 启动参数说明

```shell
./contractserver.x --help
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
 
```

#### 启动示例
```shell
# 二进制文件启动示例
$> contractserver.x  -rpcaddr http://192.168.2.144:8669

# docker启动示例

# 启动合约服务
$> docker run --name cdib-web -p 31312:31312 -d wupengxin/cdib ./contractserver.x \
 -rpcaddr http://192.168.2.144:8669 -dbaddr 127.0.0.1:3306 -dbpasswd passwd \
 -dbuser user -dbname cdib -produce true 


```

