//
//  TcpRoomManager.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/21.
//

import UIKit
import SwiftyJSON

protocol GameRoomAnnouncerDataSource:NSObjectProtocol{
    
    func roomAnnouncerRequestForRoom() -> GameRoom
    
}

///房间广播源
protocol GameRoomAnnouncer:NSObjectProtocol{
    
    var announcing:Bool { get }
    
    ///广播RoomModel数据源
    func setDataSource(_ dataSource:GameRoomAnnouncerDataSource)
    
    ///开始广播
    func startServer() -> Bool
    
    ///结束广播
    func terminateServer()
    
}

///房间管理对象
class GameRoomManager:NSObject{
    
    static let instance:GameRoomManager = {
        let manager = GameRoomManager()
        return manager
    }()
    
    public var room:GameRoom?{
        get{
            return roomModel
        }
    }
    
    public var isWorking:Bool{
        get{
            return _isWorking
        }
    }
    
    private var roomModel:GameRoom?
    
    private var connector:GameRoomConnector?
    
    private var ignoreGamerData:Bool = false
    
    private var gameProfile:GameProfile?
    
    private var _isWorking:Bool = false
    
    ///广播源
    var announcer:GameRoomAnnouncer?
    
    ///资源同步器
    var launcher:GameLauncher?
    
    ///用户手柄控制器
    var stickCommander:GameStickCommander?
    
    
    
    private override init(){
        super.init()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func initialize(connector:GameRoomConnector?){
        NotificationCenter.customAddObserver(self, selector: #selector(onGamerConnected(_:)), name: .GamerConnected, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onGamerDisconnected(_:)), name: .GamerDisconnected, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onGamerEchoArrive(_:)), name: .GamerEcho, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onNetworkStateChanged(_:)), name: .NetworkStateChanged, object: nil)
        self.connector = connector
        self.connector?.setDataSource(self)
        self.launcher = GameLauncher()
        self.launcher?.setConnector(connector)
        self.launcher?.dataSource = self
        self.stickCommander?.dataSource = self
    }
    
    func startServer(gameProfile:GameProfile) -> Bool{
        
        switch Server.instance.connectMode{
        case .Lan:
            //检查网络
            guard NetworkStateListener.default.connection == .wifi else { return false }
            
            self.roomModel = GameRoom(roomId: String.rand(length: 16), hoster: .init(ip_v4_address: wifiIP), game: gameProfile, players: [], playerCount: 0)
            guard self.connector?.startServer() ?? false else { return false }
            self.connector?.allowNewConnection(true)
        default:
            return false
        }
        self.announcer?.setDataSource(self)
        self.gameProfile = gameProfile
        return true
    }
    
    func allowNewPlayerJoin(_ value:Bool){
        self.connector?.allowNewConnection(value)
    }
    
    ///初始化所有变量
    func terminateServer(){
        self.roomModel = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    ///检查是否满足launch条件
    ///0 - 可以启动
    ///1 - 有玩家未准备
    ///2 - 低于最低游戏人数
    ///3 - 服务未启动
    func checkConditionForLaunch() -> Int{
        guard roomModel != nil else { return 3 }
        guard roomModel!.playerCount >= gameProfile!.minPlayerCount else { return 2 }
        var flag = 0
        for player in roomModel!.players{
            if player.isReady == false{
                flag = 1
                break
            }
        }
        guard flag == 0 else { return 1 }
        return 0
    }
}


extension GameRoomManager{
    
    
    @objc private func onGamerConnected(_ notification:Notification){
        guard let gamer = notification.userInfo?[JtUserInfo.Key.Gamer] as? GameUser else { return }
        guard let addressString = notification.userInfo?[JtUserInfo.Key.Value] as? String else { return }
        guard let connectMode = notification.userInfo?[JtUserInfo.Key.Description] as? Server.ConnectMode else { return }
        var player:GameRoomPlayer!
        switch connectMode{
        case .Lan:
            player = GameRoomPlayer(playerId: gamer.uid, user: gamer, ip_v4_address: addressString, isReady: false)
        default:
            fatalError("mode not define")
        }
        
        self.roomModel!.players.append(player)
        self.roomModel!.playerCount += 1

        debugLog("[GameRoomManager] player(\(gamer.nickName ?? "NULL"))加入")
        
        //同步给其他用户
        let dataDictionaray:[String:Any] = [
            "player":player.propertyDictionary
        ]
        
        guard connector?.syncExpect(.userEnter, player: player, message: dataDictionaray) ?? false else {
            debugLog("[GameRoomManager] send user enter failed")
            return
        }
        NotificationCenter.customPost(name: .PlayerEnter, object: nil, userInfo: [
            .Value:player!
        ])

    }
    
    @objc private func onGamerDisconnected(_ notification:Notification){
        guard let gamer = notification.userInfo?[JtUserInfo.Key.Gamer] as? GameUser else { return }
        if let error = notification.userInfo?[JtUserInfo.Key.Error] as? Error{
            debugLog("[GameRoomManager] 与player(\(gamer.nickName ?? "NULL"))由于异常(\(error.localizedDescription))断开连接")
        }
        else{
            debugLog("[GameRoomManager] 与player(\(gamer.nickName ?? "NULL"))主动断开连接")
        }
        
        for (idx,player) in roomModel!.players.enumerated(){
            if player.user.uid == gamer.uid{
                
                //同步给其他用户
                let dataDictionaray:[String:Any] = [
                    "player":player.propertyDictionary
                ]
                guard connector?.syncExpect(.userLeave, player: player, message: dataDictionaray) ?? false else {
                    debugLog("[GamrRoomManager] send user info to other failed")
                    return
                }
                
                self.roomModel!.players.remove(at: idx)
                self.roomModel?.playerCount -= 1
                
                NotificationCenter.customPost(name: .PlayerExit, object: nil, userInfo: [
                    .Value:player
                ])
                
            }
        }
    }
    
    @objc private func onGamerEchoArrive(_ notification:Notification){
        guard !ignoreGamerData else { return }
        guard let gamer = notification.userInfo?[JtUserInfo.Key.Gamer] as? GameUser else { return }
        guard let data = notification.userInfo?[JtUserInfo.Key.Data] as? Data else { return }
        //debugLog("收到来自player(\(gamer.nickName ?? "NULL"))的数据")
        
        let Json = JSON(data)
        
        switch Json["type"].stringValue{
        case GameSync.Symbol.userReady.rawValue:
            for (idx,player) in roomModel!.players.enumerated(){
                if player.user.uid == gamer.uid{
                    let response:[String:Any] = [
                        "playerId":player.playerId ?? ""
                    ]
                    roomModel!.players[idx].isReady = true
                    guard connector?.syncExpect(.userReady, player: player, message: response) ?? false else {
                        debugLog("[GamrRoomManager] send user ready to other failed")
                        return
                    }
                    
                    NotificationCenter.customPost(name: .PlayerReady, object: nil, userInfo: [
                        .Value:player
                    ])

                }
            }
        case GameSync.Symbol.userNotReady.rawValue:
            for (idx,player) in roomModel!.players.enumerated(){
                if player.user.uid == gamer.uid{
                    let response:[String:Any] = [
                        "playerId":player.playerId ?? ""
                    ]
                    roomModel!.players[idx].isReady = false
                    guard connector?.syncExpect(.userNotReady, player: player, message: response) ?? false else {
                        debugLog("[GameRoomManager] send user not ready to others failed")
                        return
                    }
                    NotificationCenter.customPost(name: .PlayerNotReady, object: nil, userInfo: [
                        .Value:player
                    ])
                }
            }
        default:
            break
        }
    }
    
    @objc private func onNetworkStateChanged(_ notification:Notification){
        if NetworkStateListener.default.connection != .wifi{
            //is launching
            if self.launcher?.isLaunching ?? false{
                self.launcher?.terminateProcedure()
            }
            //is playing
            if self.stickCommander?.enable ?? false{
                self.stickCommander?.enable = false
            }
            //is announcing
            if self.announcer?.announcing ?? false{
                self.announcer?.terminateServer()
            }
        }
    }
    
}


extension GameRoomManager:GameRoomConnectorDataSource{
    
    func gameConnector(_ connector: GameRoomConnector, playerFor gamer: GameUser) -> GameRoomPlayer? {
        for inRoomPlayer in self.roomModel!.players{
            if inRoomPlayer.user.uid == gamer.uid{
                return inRoomPlayer
            }
        }
        return nil
    }
    
    func gameConnectorTargetRoom() -> GameRoom {
        return self.roomModel!
    }
    
    
}


extension GameRoomManager:GameRoomAnnouncerDataSource{
    
    func roomAnnouncerRequestForRoom() -> GameRoom {
        return self.roomModel!
    }
    
}

extension GameRoomManager:GameLauncherDataSource{
    
    func gameLauncherRequestForRoom() -> GameRoom {
        return self.roomModel!
    }
    
}


extension GameRoomManager:GameStickCommanderDataSource{
    
    func stickCommanderRequestForRoom() -> GameRoom {
        return self.roomModel!
    }
    
}

