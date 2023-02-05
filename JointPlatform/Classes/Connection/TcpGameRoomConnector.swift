//
//  LANTcpRoomConnector.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/4.
//

import UIKit
import CocoaAsyncSocket
import SwiftyJSON

///负责连接验证
///向外发出新连接通知，连接断开通知
///维护所有tcp连接
///其他类只需要监听通知
///至多维持4个连接
class TcpGameRoomConnector:NSObject,GameRoomConnector{
    
    var tcpPort:UInt16{
        get{
            return LANGammTcpPort[0]
        }
    }
    
    var isConnected: Bool{
        get{
            return !(sockets.isEmpty && strangerSockets.isEmpty)
        }
    }
    
    //tcp没有接收到消息自动断开的时间
    var tcpConnectTimeout:TimeInterval = -1
    
    var tcpSendTimeout:TimeInterval = -1
    
    var tcpTag:Int = 121
    
    private weak var dataSource:GameRoomConnectorDataSource?
    
    private var sockets:[String:GCDAsyncSocket] = [:]
    
    private var strangerSockets:[String:GCDAsyncSocket] = [:]
    
    private var gamers:[String:GameUser] = [:]
    
    private var nextDataLengthMap:[String:Int] = [:]
    
    private var allowNewConnection:Bool = true
    
    ///latest delay packet received with specific address
    private var delayPacketsReceivedDate:[String:Date] = [:]
    
    ///用于监听端口接受新连接
    private var serverSocket:GCDAsyncSocket!
    
    ///是否可以已经开启端口
    private var isAcceptOnPort:Bool = false
    
    ///check the socket is still connected
    private var aliveCheckTimer:Timer?
    
    ///check interval
    private let aliveCheckTimerInterval:TimeInterval = 1
    
    private let unavailableThreshold:TimeInterval = 3
    
    func initialize() {
        serverSocket = GCDAsyncSocket(delegate: self, delegateQueue: .main)
        gamers.removeAll()
        sockets.removeAll()
        strangerSockets.removeAll()
        nextDataLengthMap.removeAll()
        delayPacketsReceivedDate.removeAll()
    }

    
    func setDataSource(_ target: GameRoomConnectorDataSource) {
        self.dataSource = target
    }
    
    func startServer() -> Bool {
        guard !isAcceptOnPort else { return true }
        guard dataSource != nil else { return false }
        
        do{
            try serverSocket.accept(onPort: tcpPort)
            isAcceptOnPort = true
            
            //start alive check timer to check socket connection
            aliveCheckTimer = Timer.scheduledTimer(timeInterval: aliveCheckTimerInterval, target: self, selector: #selector(onAliveCheckTimerUpdate), userInfo: nil, repeats: true)
            
            return true
        }
        catch let error{
            debugLog("[Tcp Connector] start Server Error: "+error.localizedDescription)
            return false
        }
    }
    
    func terminalServer() {
        disconnectAll()
        serverSocket.disconnect()
        isAcceptOnPort = false
        aliveCheckTimer?.invalidate()
    }
    
    func disconnectTo(_ player: GameRoomPlayer) -> Bool {
        for ipAddress in sockets.keys{
            if ipAddress == player.ip_v4_address{
                sockets[ipAddress]!.disconnect()
                sockets.removeValue(forKey: ipAddress)
                gamers.removeValue(forKey: ipAddress)
                return true
            }
        }
        return false
    }
    
    func syncTo(_ type: GameSync.Symbol, player: GameRoomPlayer,message:Any?) -> Bool {
        for ipAddress in sockets.keys{
            if ipAddress == player.ip_v4_address{
                return sendWrappedData(for: sockets[ipAddress]!, message: message, type: type)
            }
        }
        return false
    }
    
    func syncExpect(_ type: GameSync.Symbol, player: GameRoomPlayer, message:Any?) -> Bool {
        for ipAddress in sockets.keys{
            if ipAddress != player.ip_v4_address{
                if !sendWrappedData(for: sockets[ipAddress]!, message: message, type: type){
                    return false
                }
            }
        }
        return true
    }
    
    func disconnectAll() {
        for socket in sockets.values{
            socket.disconnect()
        }
        for socket in strangerSockets.values{
            socket.disconnect()
        }
        sockets.removeAll()
        gamers.removeAll()
        nextDataLengthMap.removeAll()
    }
    
    func syncAll(_ type: GameSync.Symbol,message:Any?) -> Bool{
        for socket in sockets.values{
            if !sendWrappedData(for: socket, message: message, type: type){
                return false
            }
        }
        return true
    }
    
    func allowNewConnection(_ value: Bool) {
        self.allowNewConnection = value
    }
    
    private func sendWrappedData(for socket:GCDAsyncSocket,message:Any?,type:GameSync.Symbol) -> Bool {
        if type == .gameAssets{
            
            if let messageDic = message as? [String:Data]{
                for dataPairs in messageDic{
                    if !tcpWrite(data: dataPairs.value, socket: socket, rawData: true, identifier: dataPairs.key){
                        return false
                    }
                }
            }
            else{
                debugLog("[Tcp Connector] tcp wrap data with error : data is not sendable.")
                return false
            }

        }
        else{
            let JsonDic:[String:Any] = [
                "type":type.rawValue,
                "msg":message ?? []
            ]
            return tcpWrite(data: JSON(JsonDic).description.data(using: .utf8), socket: socket)
        }
        return true
    }
    
    
    private func tcpWrite(data:Data?,socket:GCDAsyncSocket,rawData:Bool = false,identifier:String = "") -> Bool {
        //to avoid tcp packet stick together, send two part for each data,first is header describe the length of
        //data which is prepared to send,second is the data.
        guard data != nil else { return false }
        let dataLength = data!.count
        let headerDic:[String:Any] = [
            "len":dataLength,
            "type":rawData ? 2 : 1,
            "id":identifier
        ]
        let headerJsonString = JSON(headerDic).description
        guard var sendData = headerJsonString.data(using: .utf8) else {
            debugLog("[Tcp Connector] tcp write with error : header data is not sendable.")
            return false
        }
        sendData.append(GCDAsyncSocket.crlfData())
        sendData.append(data!)
        socket.write(sendData, withTimeout: tcpSendTimeout, tag: tcpTag)
        return true
    }
    
    
    @objc
    private func onAliveCheckTimerUpdate(){
        for ipAddress in self.delayPacketsReceivedDate.keys{
            if delayPacketsReceivedDate[ipAddress]!.distance(to: Date()) > unavailableThreshold {
                // connection is lost
                
                if self.sockets.keys.contains(ipAddress){
                    debugLog("[Tcp Connector] disconnect due to alive check")
                    self.sockets[ipAddress]!.disconnect()
                    NotificationCenter.customPost(name: .GamerDisconnected, object: nil, userInfo: [
                        .Gamer:gamers[ipAddress]!,
                    ])
                    self.nextDataLengthMap.removeValue(forKey: ipAddress)
                    self.gamers.removeValue(forKey: ipAddress)
                    self.sockets.removeValue(forKey: ipAddress)
                    self.delayPacketsReceivedDate.removeValue(forKey: ipAddress)
                }
                
            }
        }
    }
    
}

extension TcpGameRoomConnector:GCDAsyncSocketDelegate{
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        
        guard let host = newSocket.connectedHost else { return }
        guard self.allowNewConnection else {
            debugLog("[Tcp Connector] refuse connect[\(newSocket.connectedHost ?? "Null Host"))](\(newSocket.connectedPort)) due to not allow new connection")
            return
        }
        if !sockets.keys.contains(host) && sockets.count < LANGameMaxConnection{
            self.strangerSockets[newSocket.connectedHost!] = newSocket
            newSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: tcpConnectTimeout, tag: tcpTag)
            nextDataLengthMap[host] = -1
            debugLog("[Tcp Connector] stranger connected[\(newSocket.connectedHost ?? "Null Host")](\(newSocket.connectedPort))")
        }
        else{
            debugLog("[Tcp Connector] refuse connect[\(newSocket.connectedHost ?? "Null Host"))](\(newSocket.connectedPort))")
        }
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
        
        //不是主动连接 不会调用
    }
    
    

    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        let Json = JSON(data)
        
        guard sock.connectedHost != nil else {
            //current host is offline
            var ipAddress = ""
            for socketIp in self.sockets.keys{
                if sockets[socketIp] == sock{
                    ipAddress = socketIp
                }
            }
            nextDataLengthMap.removeValue(forKey: ipAddress)
            sockets.removeValue(forKey: ipAddress)
            strangerSockets.removeValue(forKey: ipAddress)
            return
        }
        
        //header receive
        guard let nextDataLength = nextDataLengthMap[sock.connectedHost!] else {
            debugLog("[Tcp Connector] next data length for host(\(sock.connectedHost!)) is not defined")
            return
        }
        
        if nextDataLength < 0 {
            guard let length = Json["len"].int else {
                debugLog("[Tcp Connector] sock read dirty header packet")
                return
            }
            nextDataLengthMap[sock.connectedHost!] = length
            sock.readData(toLength: UInt(length), withTimeout: tcpConnectTimeout, tag: tcpTag)
            return
        }
        
        //body data receive
        
        guard UInt(data.count) == nextDataLength else{
            debugLog("[Tcp Connector] sock read dirty body packet")
            //drop this dirty body , read next header
            nextDataLengthMap[sock.connectedHost!] = -1
            sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: tcpConnectTimeout, tag: tcpTag)
            return
        }
        
        let msgType = Json["type"].stringValue
        
        if msgType == GameSync.Symbol.verify.rawValue{
            debugLog("[Tcp Connector] receive stranger verify data")
            for ipAddress in strangerSockets.keys{
                let stranger = strangerSockets[ipAddress]!
                if sock == stranger{
                    guard let gamer = GameUser.analyse(Json["msg"]["gamer"]) else { break }
                    //check stick version
                    debugLog("[Tcp Connector] stranger(\(ipAddress)) verify proved")
                    NotificationCenter.customPost(name: .GamerConnected, object: nil, userInfo: [
                        .Gamer:gamer,
                        .Value:ipAddress,
                        .Description:Server.ConnectMode.Lan
                    ])
                    
                    strangerSockets.removeValue(forKey: ipAddress)
                    guard sockets.count < LANGameMaxConnection && !sockets.keys.contains(ipAddress) else { break }
                    sockets[ipAddress] = stranger
                    gamers[ipAddress] = gamer
                    
                    var players:[GameRoomPlayer] = []
                    for g in gamers.values{
                        if let player = dataSource!.gameConnector(self, playerFor: g){
                            players.append(player)
                        }
                    }
                    //sync room player info to new player
                    var room = dataSource!.gameConnectorTargetRoom()
                    room.players = players
                    room.playerCount = players.count
                    
                    let wrappedDic:[String:Any] = [
                        "type":GameSync.Symbol.verifyProved.rawValue,
                        "msg":[
                            "room":room.propertyDictionary(true)
                        ]
                    ]
                    
                    let responseJsonStr = JSON(wrappedDic).description
                    guard tcpWrite(data: responseJsonStr.data(using: .utf8), socket: sockets[ipAddress]!) else {
                        debugLog("[Tcp Connector] send room info to \(ipAddress) failed")
                        return
                    }
                    
                    break
                }
            }
            
        }
        else if msgType == GameSync.Symbol.delayCheck.rawValue{
            guard let ipAddress = sock.connectedHost else { return }
            guard self.sockets.keys.contains(ipAddress) else { return }
            guard let stampString = Json["msg"]["stamp"].string else { return }
            // update delay packet date for this connection
            delayPacketsReceivedDate[ipAddress] = Date()
            let responseDic:[String:Any] = [
                "type":GameSync.Symbol.delayCheckEcho.rawValue,
                "msg":[
                    "stamp":stampString
                ]
            ]
            guard tcpWrite(data: JSON(responseDic).description.data(using: .utf8), socket: sock) else {
                debugLog("[Tcp Connector] send delay check to \(ipAddress) failed")
                return
            }
        }
        else{
            
            for ipAddress in sockets.keys{
                if ipAddress == sock.connectedHost!{
                    NotificationCenter.customPost(name: .GamerEcho, object: nil, userInfo: [
                        .Gamer:gamers[ipAddress]!,
                        .Data:data
                    ])
                    break
                }
            }
            
        }
        
        //prepare to read next header
        nextDataLengthMap[sock.connectedHost!] = -1
        sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: tcpConnectTimeout, tag: tcpTag)
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        //sock.readData(withTimeout: tcpConnectTimeout, tag: tcpTag)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        var isPlayer:Bool = false
        
        for socket in sockets{
            if socket.value == sock{
                let ipAddress = socket.key
                debugLog("[Tcp Connector] disconnect to gamer : \(ipAddress)")
                if let error = err as NSError?{
                    NotificationCenter.customPost(name: .GamerDisconnected, object: nil, userInfo: [
                        .Gamer:gamers[ipAddress]!,
                        .Error:error
                    ])
                }
                else{
                    NotificationCenter.customPost(name: .GamerDisconnected, object: nil, userInfo: [
                        .Gamer:gamers[ipAddress]!,
                    ])
                }
                self.nextDataLengthMap.removeValue(forKey: ipAddress)
                self.sockets.removeValue(forKey: ipAddress)
                self.gamers.removeValue(forKey: ipAddress)
                isPlayer = true
                
                break
            }
        }
        
        if !isPlayer{
            for stranger in strangerSockets{
                if stranger.value == sock{
                    self.nextDataLengthMap.removeValue(forKey: stranger.key)
                    strangerSockets.removeValue(forKey: stranger.key)
                    debugLog("[Tcp Connector] stranger disconnect[\(stranger.key))](\(sock.connectedPort))")
                    break
                }
            }
        }
        
    }
}
