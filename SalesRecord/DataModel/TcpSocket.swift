//
//  TcpSocket.swift
//  SalesRecord
//
//  Created by James Thang on 7/6/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class MySocket: NSObject, GCDAsyncSocketDelegate {

    var mSocket: GCDAsyncSocket!
    var ipAdress: String?
    
    var port: UInt16?

    init(address: String, portConnect: UInt16) {
        super.init()
        self.ipAdress = address
        self.port = portConnect

        mSocket = GCDAsyncSocket.init(delegate: self, delegateQueue: .main)
        
        do {
            if let address = ipAdress, let port = port {
                try mSocket.connect(toHost: address, onPort: port)
                print("Connecing to socket server...")
            }
        } catch let error {
            print(error)
        }
    }

    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        UserDefaults.standard.set(ipAdress, forKey: "tcpPrinterIP")
    }

    func sendContent(_ data: Data) {
        //Send Data
        self.mSocket?.write(data, withTimeout: 10, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("Suceess")
    }
    
    func printTicket(_ content: ESCPOSCommandsCreator, encoding: String.Encoding = String.GBEncoding.GB_18030_2000) {

        for data in content.data(using: encoding) {
            self.mSocket?.write(data, withTimeout: 10, tag: 0)
        }
    }
    
    func printTicketVN(_ content: ESCPOSCommandsCreator, encoding: String.Encoding = String.Encoding.utf8) {
        for data in content.data(using: encoding) {
            self.mSocket?.write(data, withTimeout: 10, tag: 0)
        }
    }
    
    func cutPaper() {
        self.mSocket?.write(Data([29]), withTimeout: 10, tag: 0)
        self.mSocket?.write(Data([86]), withTimeout: 10, tag: 0)
        self.mSocket?.write(Data([66]), withTimeout: 10, tag: 0)
        self.mSocket?.write(Data([0]), withTimeout: 10, tag: 0)
    }
    
    func openDrawer() {
        self.mSocket?.write(Data([27]), withTimeout: 10, tag: 0)
        self.mSocket?.write(Data([112]), withTimeout: 10, tag: 0)
        self.mSocket?.write(Data([48]), withTimeout: 10, tag: 0)
        self.mSocket?.write(Data([55]), withTimeout: 10, tag: 0)
        self.mSocket?.write(Data([121]), withTimeout: 10, tag: 0)
    }
    
    func disConnect() {
        mSocket.disconnect()
    }
}

public protocol ESCPOSCommandsCreator {
    
    func data(using encoding: String.Encoding) -> [Data]
}

