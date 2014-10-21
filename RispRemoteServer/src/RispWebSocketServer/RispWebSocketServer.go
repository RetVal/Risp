//
//  RispWebSocketServer.go
//  Risp
//
//  Created by closure on 7/31/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

package main

import (
	"code.google.com/p/go.net/websocket"
	"fmt"
	"log"
	"net/http"
	"runtime"
	"bufio"
	"os"
	"C"
	"RispRemoteInit"
	"RispPathHelper"
	"io/ioutil"
)

type Message struct {
	message string
}

var RispSDK *RispRemoteInit.Configuration

func dispatch (reg chan *websocket.Conn, unreg chan *websocket.Conn, messageChan chan Message, SDK *RispRemoteInit.Configuration) {
	conns := make(map[*websocket.Conn] int)
	for {
		select {
			case c := <- reg: 
				fmt.Println("notice: new client")
				conns[c] = 1
				if RispSDK != nil && len(RispSDK.Code) > 0 {
					websocket.Message.Send(c, RispSDK.Code)	
				} else {
					fmt.Println("notic: RispSDK is nil, using SDK")
					if SDK != nil && len(SDK.Code) > 0 {
						websocket.Message.Send(c, SDK.Code)
					} else {
						fmt.Println("notic: SDK is nil")
					}
				}
			case c := <- unreg:
				delete(conns, c)
			case msg := <- messageChan:
				go func () {
					for c := range conns {
						websocket.Message.Send(c, msg.message)	
					}
				}()
		}
	}
}

func server (reg chan *websocket.Conn, unreg chan *websocket.Conn, messageChan chan Message, SDK *RispRemoteInit.Configuration) {
	http.Handle("/", websocket.Handler(func (ws *websocket.Conn) {
		reg <- ws
		for {
			var message string
			err := websocket.Message.Receive(ws, &message)
			if err != nil {
				fmt.Println("Can not receive")
				unreg <- ws
				break
			}
			fmt.Print("Received back from client: " + message)
		}
	}))
	err := http.ListenAndServe(":9000", nil)
	if err != nil {
		log.Fatal("ListenAndServer:", err)
		panic("ListenAndServe: " + err.Error())
	}
}

func loadConfiguration () *RispRemoteInit.Configuration {
	configuration := RispRemoteInit.NewConfiguration("Risp.plist")
	if configuration != nil {
		code, err := ioutil.ReadFile(RispPathHelper.StandardizingPath(configuration.Code));
		if err != nil {
			configuration.Code = ""
		} else {
			configuration.Code = string(code)
		}
	}
	return configuration
}

func main () {
	RispSDK = loadConfiguration()
	fmt.Println(RispSDK)
	runtime.GOMAXPROCS(256)
	reg := make(chan *websocket.Conn)
	unreg := make(chan *websocket.Conn)
	messageChan := make(chan Message)
	go server(reg, unreg, messageChan, RispSDK)
	go dispatch(reg, unreg, messageChan, RispSDK)

	fmt.Println("running...")
	
	reader := bufio.NewReader(os.Stdin)
	shouldExit := false
	shouldSkip := false
	for {
		shouldSkip = false
		message, err := reader.ReadString('\n')
		if err == nil {
			message = message[:len(message) - 1]	// remove \n

			fmt.Println("input code: ", message)
			switch message {
			case "(exit)":
				fmt.Println("goodbye")
				shouldExit = true
				break
			case "(refresh)":
				RispSDK = loadConfiguration()
				message = "(reconnect)"
				break
			case "(hello)":

				break
			}
			if (shouldExit) {
				break
			}

			if (!shouldSkip) {
				messageChan <- Message{message}
			}
		} else {
			fmt.Println("error ->", err)
		}
	}
}