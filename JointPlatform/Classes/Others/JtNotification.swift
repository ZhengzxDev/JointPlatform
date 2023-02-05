//
//  JtNotification.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/9.
//

import UIKit

import UIKit

/**
 扩展系统的Notification.Name的枚举类型
 */
enum JtNotification:String{
    
    ///新客户端连接
    case GamerConnected = "JtGamerConnected"
    
    ///有客户端断开连接
    case GamerDisconnected = "JtGamerDisconnected"
    
    ///收到来自客户端的新信息
    case GamerEcho = "JtGamerEcho"
    
    
    
    
    ///新玩家进入房间
    case PlayerEnter = "JtPlayerEnterRoom"
    
    ///玩家退出房间
    case PlayerExit = "JtPlayerExitRoom"
    
    ///玩家准备
    case PlayerReady = "JtPlayerReady"
    
    ///玩家取消准备
    case PlayerNotReady = "JtPlayerNotReady"
    
    ///网络连接变化
    case NetworkStateChanged = "JtNetworkStateChanged"
    
    var stringValue: String {
        return "JtNotification" + rawValue
    }
    
    ///获取notification.name
    var notificationName: NSNotification.Name {
        return NSNotification.Name(stringValue)
    }
    
}

/**
 扩展的UserInfo,支持使用自己的Key拿参数
 */
struct JtUserInfo{
    
    ///自定义UserInfo的预设Key
    enum Key:String{
        
        ///玩家模型
        case Gamer = "JtUserInfoKeyGammer"
        
        ///错误信息
        case Error = "JtUserInfoKeyError"
        
        ///数据
        case Data = "JtUserInfoKeyData"
        
        ///通用字段,含义通常不定
        case Value = "JtUserInfoKeyValue"
        
        ///对Value字段的描述
        case Description = "JtUserInfoKeyDescription"
    }
    
}
