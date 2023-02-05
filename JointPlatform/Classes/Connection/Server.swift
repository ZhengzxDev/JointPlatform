//
//  Server.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/21.
//

import Foundation


class Server:NSObject{
    
    enum ConnectMode{
        case None
        case Lan
        case Bluetooth
    }
    
    static let instance:Server = {
        let server = Server()
        return server
    }()
    
    public var isInitialized:Bool{
        get{
            return _inited
        }
    }
    
    

    private override init(){
        super.init()
    }
    
    private var _roomManager:GameRoomManager = GameRoomManager.instance
    
    private var _connector:GameRoomConnector?
    
    private var _connectMode:ConnectMode = .None
    
    private var _inited:Bool = false
    
    public var connectMode:ConnectMode{
        get{
            return _connectMode
        }
    }
    
    func connectMode(_ mode:ConnectMode){
        self._connectMode = mode
    }
    
    func shutdown(){
        _roomManager.announcer?.terminateServer()
        _roomManager.launcher?.terminateProcedure()
        _roomManager.terminateServer()
        _connector?.terminalServer()
    }
    
    func initComponent(){
        
        shutdown()
        
        switch _connectMode {
        case .Lan:
            _roomManager.announcer = UdpGameRoomAnnouncer()
            _connector = TcpGameRoomConnector()
        case .Bluetooth:
            _roomManager.announcer = BTGameRoomAnnouncer()
            _connector = BTGameRoomConnector()
        case .None:
            _connector = nil
        }
        
        if _roomManager.stickCommander == nil{
            _roomManager.stickCommander = GameStickCommander()
        }
        
        _connector?.initialize()
        _roomManager.initialize(connector: _connector)
        
        
        _roomManager.stickCommander?.initialize(connector: _connector)
        _inited = true
    }
    
    func roomManager() -> GameRoomManager?{
        return self._roomManager
    }
}
