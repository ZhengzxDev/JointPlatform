//
//  TcpGameRoomManager.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/21.
//

import Foundation
import CocoaAsyncSocket
import SwiftyJSON



class UdpGameRoomAnnouncer:NSObject,GameRoomAnnouncer{
    
    
    var announcing: Bool{
        return isBroadcasting
    }
    
    private var udpClient:GCDAsyncUdpSocket?
    
    private var udpTimeout:TimeInterval = -1
    
    private var udpResendTimeout:TimeInterval = 1.5
    
    private var udpSendTag:Int = 1
    
    private var udpTimer:Timer!
    
    private var udpPort:UInt16 = LANGamePort
    
    private var isBroadcasting:Bool = false
    
    private var roomInfo:GameRoom!
    
    private var dataSource:GameRoomAnnouncerDataSource?
    
    func setDataSource(_ dataSource: GameRoomAnnouncerDataSource) {
        self.dataSource = dataSource
    }
    
    func startServer() -> Bool {
        guard !isBroadcasting else { return true }
        guard dataSource != nil else { return false }
        terminateServer()
        do{
            if udpClient == nil{
                udpClient = GCDAsyncUdpSocket(delegate: self, delegateQueue: .main)
            }
            try udpClient?.enableBroadcast(true)
            udpTimer = Timer.scheduledTimer(timeInterval: udpResendTimeout, target: self, selector: #selector(doBroadcastProcedure), userInfo: nil, repeats: true)
            udpTimer.fire()
            isBroadcasting = true
            return true
            
        }catch let error{
            debugLog("[UdpAnnouncer] start server error \(error.localizedDescription)")
            return false
        }
    }
    
    
    func terminateServer() {
        isBroadcasting = false
        udpTimer?.invalidate()
        udpClient?.close()
    }
    
    
    @objc private func doBroadcastProcedure(){
        guard let roomDictionary:[String:Any] = dataSource?.roomAnnouncerRequestForRoom().propertyDictionary(false) else {
            debugLog("[UdpAnnouncer] start server error , datasource is nil")
            terminateServer()
            return
        }
        let json = JSON(roomDictionary)
        let jsonString = json.description
        guard let jsonData = jsonString.data(using: .utf8) else {
            debugLog("[UdpAnnouncer] broadcast failed")
            udpTimer.invalidate()
            return
        }
        udpClient?.send(jsonData, toHost: "255.255.255.255", port: udpPort, withTimeout: udpTimeout, tag: udpSendTag)
    }
    
}


extension UdpGameRoomAnnouncer:GCDAsyncUdpSocketDelegate{
    
}
