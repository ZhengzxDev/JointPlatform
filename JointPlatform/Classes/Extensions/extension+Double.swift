//
//  extension+Double.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/28.
//

import Foundation

extension Double{
    
    ///return a fraction between 0 and 1
    static func posRandom() -> Double{
        
        return Double(arc4random() % 100) / 100
        
    }
    
    ///return a fraction between -1 and 1
    static func random() -> Double{
        
        return (Double(arc4random() % 200) - 100) / 100
        
    }
    
}
