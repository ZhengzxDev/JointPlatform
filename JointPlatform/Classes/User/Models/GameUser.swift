//
//  GameUser.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/3.
//

import UIKit
import SwiftyJSON

///游戏用户
struct GameUser{
    
    ///16位随机编号
    var uid:String!
    
    ///昵称
    var nickName:String!
    
    ///头像
    var avatarId:Int!
    
    
    var propertyDictionary:[String:Any]{
        get{
            return [
                "uid":uid!,
                "nickname":nickName!,
                "avatarId":avatarId
            ]
        }
    }
    
    ///分析JSON，返回模型
    static func analyse(_ Json:JSON) -> GameUser?{
        var gamer = GameUser()
        gamer.nickName = Json["nickname"].stringValue
        gamer.avatarId = Json["avatarId"].intValue
        gamer.uid = Json["uid"].stringValue
        return gamer
    }
}
