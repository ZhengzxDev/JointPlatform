//
//  LANRoom.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/3.
//

import UIKit
import SwiftyJSON

///局域网房间
struct GameRoom{
    
    ///房间唯一ID 16位
    var roomId:String!
    
    ///房主
    var hoster:GameRoomHoster!
    
    ///游戏信息
    var game:GameProfile!
    
    ///房间容量
    var capacity:Int{
        get{
            return game.maxPlayerCount
        }
    }
    
    ///玩家信息
    var players:[GameRoomPlayer] = []
    
    ///当前玩家数量
    var playerCount:Int = 0
    
}


extension GameRoom{
    
    ///属性字典
    func propertyDictionary(_ needPlayerInfo:Bool = true) -> [String:Any]{
        var res:[String:Any] =  [
            "hoster":hoster.propertyDictionary,
            "game":game.propertyDictionary,
            "capacity":game.maxPlayerCount,
            "playerCount":playerCount,
            "rid":roomId!,
        ]
        
        guard needPlayerInfo else { return res }
        
        var playerDicArray:[[String:Any]] = []
        for player in players{
            playerDicArray.append(player.propertyDictionary)
        }
        
        res["players"] = playerDicArray
        
        return res
    }
    
    func playerInfoDictionary() -> [[String:Any]]{
        var playerDicArray:[[String:Any]] = []
        for player in players{
            playerDicArray.append(player.propertyDictionary)
        }
        return playerDicArray
    }
    
    
    ///分析JSON，返回模型
    static func analyse(_ Json:JSON) -> GameRoom?{
        var room = GameRoom()
        room.hoster = GameRoomHoster.analyse(Json["hoster"])
        room.game = GameProfile.analyse(Json["game"])
        room.playerCount = Json["playerCount"].intValue
        room.roomId = Json["roomId"].stringValue
        var playersArray:[GameRoomPlayer] = []
        let playersJsonArray = Json["players"].arrayValue
        for playerJson in playersJsonArray{
            guard let player = GameRoomPlayer.analyse(playerJson) else { continue }
            playersArray.append(player)
        }
        return room
    }
    
}
