//
//  ws.go
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
)

type Message struct {
	message string
}

func dispatch (reg chan *websocket.Conn, unreg chan *websocket.Conn, messageChan chan Message) {
	conns := make(map[*websocket.Conn] int)
	for {
		select {
			case c := <- reg: 
				fmt.Println("notice: new client")
				conns[c] = 1
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

func server (reg chan *websocket.Conn, unreg chan *websocket.Conn, messageChan chan Message) {
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
			fmt.Println("Received back from client: " + message)
		}
	}))
	err := http.ListenAndServe(":9000", nil)
	if err != nil {
		log.Fatal("ListenAndServer:", err)
		panic("ListenAndServe: " + err.Error())
	}
}

func main () {
	fmt.Println("current runtime.GOMAXPROCS -> ", runtime.GOMAXPROCS(256))
	fmt.Println("now runtime.GOMAXPROCS -> ", runtime.GOMAXPROCS(256))
	reg := make(chan *websocket.Conn)
	unreg := make(chan *websocket.Conn)
	messageChan := make(chan Message)
	go server(reg, unreg, messageChan)
	go dispatch(reg, unreg, messageChan)

	fmt.Println("running...")
	
	reader := bufio.NewReader(os.Stdin)
	for {
		message, err := reader.ReadString('\n')
		if err == nil {
			message = message[:len(message) - 1]	// remove \n
			fmt.Println(message)
			if message == "(exit)" {
				fmt.Println("goodbye")
				break
			}
			messageChan <- Message{message}
		} else {
			fmt.Println("error ->", err)
		}
	}
}