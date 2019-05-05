package utils

import (
	"strings"
)

// 小工具

// SpliceURL 拼接URL
func SpliceURL(a ...string) string {
	url := a[0]
	if len(a) < 1 {
		return url
	}

	for _, str := range a[1:] {
		var f, l string
		if strings.HasPrefix(str, "/") {
			l = str[1:]
		} else {
			l = str
		}

		if strings.HasSuffix(url, "/") {
			f = url
		} else {
			f = url + "/"
		}

		url = f + l
	}
	return url
}

//CheckAddress 校验地址是否有效
func CheckAddress(addr string) bool {
	if len(addr) == 42 {
		return true
	} else {
		return false
	}
}
