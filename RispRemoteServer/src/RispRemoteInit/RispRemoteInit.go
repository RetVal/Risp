package RispRemoteInit

import (
	"io/ioutil"
	"fmt"
	"github.com/DHowett/go-plist"
	"RispPathHelper"
)

const (
	RispRemoteControllerPath = "RispRemoteControllerPath"
)

type Configuration struct {
	Code string
	plist *map[string]interface{}
}

func (c *Configuration) String() string {
	return c.Code
}

func NewConfiguration(codePath string) *Configuration {
	b, err := ioutil.ReadFile(RispPathHelper.StandardizingPath(codePath))
	if err != nil {
		fmt.Println(err)
		return nil
	}

	var result map[string]interface{}
	_, err1 := plist.Unmarshal(b, &result)
	if err1 != nil {
		fmt.Println(err1)
		return nil
	}
	code, ok := result[RispRemoteControllerPath].(string)
	if ok {
		c := &Configuration {plist: &result, Code: code}		
		return c
	}
	return nil
}


