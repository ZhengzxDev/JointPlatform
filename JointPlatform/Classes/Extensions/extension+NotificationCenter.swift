//
//  extension+NotificationCenter.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/9.
//

import UIKit

/**
 添加customPost简化使用自定义的CUNotification
 */
extension NotificationCenter {
    static func customPost(name: JtNotification, object: Any? = nil,userInfo:[AnyHashable:Any]? = nil){
        NotificationCenter.default.post(name: name.notificationName, object: object,userInfo: userInfo)
    }
    
    static func customPost(name: JtNotification, object: Any? = nil,userInfo:[JtUserInfo.Key:Any]? = nil){
        NotificationCenter.default.post(name: name.notificationName, object: object,userInfo: userInfo)
    }
    
    
    static func customAddObserver(_ observer:Any,selector:Selector,name:JtNotification,object:Any?){
        NotificationCenter.default.addObserver(observer, selector: selector, name: name.notificationName, object: object)
    }
}

