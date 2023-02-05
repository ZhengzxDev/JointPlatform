//
//  LANRoomHoster.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/8.
//

import UIKit
import SwiftyJSON

struct GameRoomHoster{
    
    ///ip地址
    var ip_v4_address:String?
    
    
    
    var propertyDictionary:[String:Any]{
        get{
            return [
                "ip_v4_address":ip_v4_address ?? "",
            ]
        }
    }
    
    ///分析JSON，返回模型
    static func analyse(_ Json:JSON) -> GameRoomHoster?{
        var hoster = GameRoomHoster()
        hoster.ip_v4_address = Json["ip_v4_address"].stringValue
        return hoster
    }
    
}
