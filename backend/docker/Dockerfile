FROM golang:1.11-alpine3.8
LABEL author="wupenxin  <wupeaking@gamil.com>"

ARG  GIT_PWD=abcd

ENV HOME /opt/vechain_helper


# 更新软件包 下载源码 编译 删除不需要的内容  只有放在同一层 才会缩小构建出的镜像
RUN mkdir -p $HOME/bin && mkdir -p $HOME/src && apk update && apk add curl && apk add git && apk add gcc && \
apk add libc-dev && \
mkdir -p /go/src/github.com/wupeaking && cd /go/src/github.com/wupeaking && git clone https://github.com/wupeaking/vechain_helper.git vechain_helper && \
cd vechain_helper/backend && export GO111MODULE=on && export GOPROXY=https://goproxy.io && go build -ldflags "-X github.com/wupeaking/vechain_helper/initialization.Version=`git rev-parse --short=8 HEAD`"  -o contractserver.x cmd/contractsrv/main.go && \
mv contractserver.x $HOME/bin && chmod +x $HOME/bin/contractserver.x && \
rm -rf /go/src/github.com/wupeaking/vechain_helper && apk del git && apk del gcc && rm -rf /go/pkg/mod


# 安装守护进程
RUN curl -L https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 -o /usr/local/bin/dumb-init && \
chmod +x /usr/local/bin/dumb-init

WORKDIR $HOME/bin/

COPY start.sh $HOME/bin
RUN chmod +x start.sh

ENTRYPOINT ["dumb-init", "--"]
CMD ["sh", "-x", "/opt/vechain_helper/bin/start.sh"]