//
//  GameProfile.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/3.
//

import UIKit
import SwiftyJSON

struct GameProfile{
    
    ///游戏ID
    var id:String!
    
    ///游戏名
    var name:String!
    
    ///最大玩家数
    var maxPlayerCount:Int = 4
    
    ///开始游戏最小玩家数
    var minPlayerCount:Int = 0
    
    
    var propertyDictionary:[String:Any]{
        get{
            return [
                "id":id!,
                "name":name!,
                "minPlayerCount":minPlayerCount,
                "maxPlayerCount":maxPlayerCount
            ]
        }
    }
    
    ///分析JSON，返回模型
    static func analyse(_ Json:JSON) -> GameProfile?{
        var profile = GameProfile()
        profile.id = Json["id"].stringValue
        profile.name = Json["name"].stringValue
        profile.minPlayerCount = Json["minPlayerCount"].intValue
        profile.maxPlayerCount = Json["maxPlayerCount"].intValue
        return profile
    }
    
}
