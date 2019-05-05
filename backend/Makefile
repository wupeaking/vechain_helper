CUR_DIR := $(shell pwd)
gitcommit := $(shell git rev-parse --short=8 HEAD)
build:
	# go.mod 中包名被定义为github.com/wupeaking/CDIB  所以传递连接参数要加上包名
	export GO111MODULE=on && go build -ldflags "-X github.com/wupeaking/CDIB/initialization.Version=${gitcommit}"  -o contractserver.x cmd/contractsrv/main.go
	go build -ldflags "-X github.com/wupeaking/CDIB/initialization.Version=`git rev-parse --short=8 HEAD`"  -o asynctasks.x cmd/asyncnotify/main.go


.PHONY: clean

clean:
	rm -rf asynctasks.x
	rm -rf contractserver.x
