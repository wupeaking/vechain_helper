FROM golang:1.11-alpine3.8
LABEL author="wupenxin  <wupeaking@gamil.com>"

ARG  GIT_PWD=abcd

ENV HOME /opt/cdib


# 更新软件包 下载源码 编译 删除不需要的内容  只有放在同一层 才会缩小构建出的镜像
RUN mkdir -p $HOME/bin && mkdir -p $HOME/src && apk update && apk add curl && apk add git && apk add gcc && \
apk add libc-dev && \
mkdir -p /go/src/github.com/wupeaking && cd /go/src/github.com/wupeaking && git clone https://wupeaking:${GIT_PWD}@github.com/wupeaking/CDIB.git CDIB && \
cd CDIB && export GO111MODULE=on && go build -ldflags "-X github.com/wupeaking/CDIB/initialization.Version=`git rev-parse --short=8 HEAD`"  -o contractserver.x cmd/contractsrv/main.go && \
mv contractserver.x $HOME/bin && chmod +x $HOME/bin/contractserver.x && \
GO111MODULE=on go build -ldflags "-X github.com/wupeaking/CDIB/initialization.Version=`git rev-parse --short=8 HEAD`"  -o asynctasks.x cmd/asyncnotify/main.go && \
mv asynctasks.x $HOME/bin && chmod +x $HOME/bin/asynctasks.x && mv abi.json $HOME/bin/abi.json &&\
rm -rf /go/src/github.com/wupeaking/CDIB && apk del git && apk del gcc && rm -rf /go/pkg/mod


# 安装守护进程
RUN curl -L https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 -o /usr/local/bin/dumb-init && \
chmod +x /usr/local/bin/dumb-init

WORKDIR $HOME/bin/

COPY start.sh $HOME/bin
RUN chmod +x start.sh

ENTRYPOINT ["dumb-init", "--"]
CMD ["sh", "-x", "/opt/cdib/bin/start.sh"]