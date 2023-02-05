//
//  extension+Date.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/9.
//

import UIKit

extension Date{
    
    ///毫秒级时间戳
    var milliStamp:String{
        get{
            let timeInterval:TimeInterval = self.timeIntervalSince1970
            let millisecond = CLongLong(round(timeInterval*1000))
            return "\(millisecond)"
        }
    }
    
}
