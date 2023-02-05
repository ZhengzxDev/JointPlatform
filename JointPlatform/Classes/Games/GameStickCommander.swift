//
//  PlayerStickManager.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/21.
//

import UIKit
import SwiftyJSON

protocol GameStickCommanderDelegate:NSObjectProtocol{
    
    func stickCommander(_ commander:GameStickCommander,MovedWith vector:CGVector,degree:CGFloat,comTag:Int,player:GameRoomPlayer)
    
    func stickCommander(_ commander:GameStickCommander,PressdWith comTag:Int,player:GameRoomPlayer)
    
}


protocol GameStickCommanderDataSource:NSObjectProtocol{
    
    func stickCommanderRequestForRoom() -> GameRoom
    
}

///玩家手柄输入输出管理
class GameStickCommander:NSObject{
    
    enum StickFunction:String{
        case Shake
        case Terminate
    }
    
    public weak var delegate:GameStickCommanderDelegate?
    
    public weak var dataSource:GameStickCommanderDataSource?
    
    public var enable:Bool = false{
        didSet{
            if enable{
                NotificationCenter.customAddObserver(self, selector: #selector(onGamerEchoArrive(_:)), name: .GamerEcho, object: nil)
            }
            else{
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    private var connector:GameRoomConnector?
    
    func initialize(connector:GameRoomConnector?){
        self.connector = connector
    }
    
    func syncTo(_ function:StickFunction, player: GameRoomPlayer,config:[String:Any]?) -> Bool {
        syncToPlayer(function, player: player, config: config)
    }
    
    func syncExpect(_ function:StickFunction, player: GameRoomPlayer,config:[String:Any]?) -> Bool {
        guard let roomModel = self.dataSource?.stickCommanderRequestForRoom() else { return false }
        for roomPlayer in roomModel.players{
            if roomPlayer.playerId != player.playerId{
                guard syncToPlayer(function, player: player, config: config) else {
                    debugLog("[GameStickManager] sync to player(\(player.user.nickName)) failed")
                    continue
                }
            }
        }
        return true
    }
    
    func syncAll(_ function:StickFunction, config:[String:Any]?) -> Bool {
        guard let roomModel = self.dataSource?.stickCommanderRequestForRoom() else { return false }
        for roomPlayer in roomModel.players{
            guard syncToPlayer(function, player: roomPlayer, config: config) else {
                debugLog("[GameStickManager] sync to player(\(roomPlayer.user.nickName)) failed")
                continue
            }
        }
        return true
    }
    
    private func syncToPlayer(_ function:StickFunction, player: GameRoomPlayer,config:[String:Any]?) -> Bool{
        switch function {
        case .Shake:
            return false
        case .Terminate:
            return connector?.syncTo(.gameTerminate, player: player, message: nil) ?? false
        }
    }
    
    private func playerForGamer(_ gamer:GameUser) -> GameRoomPlayer?{
        guard let roomModel = dataSource?.stickCommanderRequestForRoom() else { return nil }
        for player in roomModel.players{
            if player.user.uid == gamer.uid{
                return player
            }
        }
        return nil
    }
    
}


extension GameStickCommander{
    @objc private func onGamerEchoArrive(_ notification:Notification){
        guard let gamer = notification.userInfo?[JtUserInfo.Key.Gamer] as? GameUser else { return }
        guard let data = notification.userInfo?[JtUserInfo.Key.Data] as? Data else { return }
        
        guard let player = playerForGamer(gamer) else { return }
        let Json = JSON(data)
        switch Json["type"].stringValue{
        case GameSync.Symbol.playerStateUpdate.rawValue:
            let actionJson = Json["msg"]["action"]
            let tag = actionJson["tag"].intValue
            switch actionJson["type"].stringValue{
            case "move":
                let vx = actionJson["vector"]["x"].doubleValue
                let vy = actionJson["vector"]["y"].doubleValue
                let offset = actionJson["offset"].doubleValue
                delegate?.stickCommander(self, MovedWith: CGVector(dx: vx, dy: vy), degree: offset, comTag: tag, player: player)
            case "press":
                delegate?.stickCommander(self, PressdWith: tag, player: player)
            default:
                break
            }
        default:
            break
        }
    }
}
