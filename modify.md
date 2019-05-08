## 简介
本项目是包含完整的前后端项目， 如果想在自己的环境搭建一套这样的玩具， 按如下流程修改即可。

### 后端部署

后端可以直接使用我的公有docker镜像仓库直接部署即可(docker pull wupengxin/vechain_helper)。 只需要保证vechain的测试节点正常运行， 数据库相关schema正确构建。 详细的部署文档可以查看后端[readme](./backend/README.md)

### APP端修改

只需要修改 app/flutter_vechain/lib/configure/url.dart文件中的rootURL为自己部署节点的根路径即可。

### web端

WEB端只是生成交易信息的二维码， 不需要任何修改。