//
//  LANRoomPlayer.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/3.
//

import UIKit
import SwiftyJSON

///局域网玩家
struct GameRoomPlayer{
    
    ///用户编号
    var playerId:String!
    
    ///用户信息
    var user:GameUser!
    
    ///iPv4地址(LAN)
    var ip_v4_address:String!
    
    ///是否准备
    var isReady:Bool = false
    
    var propertyDictionary:[String:Any]{
        get{
            return [
                "playerId":playerId!,
                "user":user.propertyDictionary,
                "ip_v4_address":ip_v4_address!,
                "isReady":isReady
            ]
        }
    }
    
    ///分析JSON，返回模型
    static func analyse(_ Json:JSON) -> GameRoomPlayer?{
        var player = GameRoomPlayer()
        player.playerId = Json["id"].stringValue
        player.user = GameUser.analyse(Json["user"])
        player.isReady = Json["isReady"].boolValue
        player.ip_v4_address = Json["ip_v4_address"].stringValue
        return player
    }
    
}
