package RispPathHelper

import (
	"strings"
	"os/user"
	"os"
)

func StandardizingPath(path string) string {
	if path[:2] == "~/" {
		usr, _ := user.Current()
		dir := usr.HomeDir
    	path = strings.Replace(path, "~", dir, 1)
    	return path
	} else if path[:1] != "/" {
		dir, _ := os.Getwd()
		path = dir + "/" + path
		return path
	}
	return path
}