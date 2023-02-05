//
//  extension+Int.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/2/1.
//

import Foundation

extension Int{
    
    /// value will given in range [from,to].
    static func random(from:Int,to:Int) -> Int{
        guard from <= to else { return from }
        return Int(arc4random()%UInt32(to - from + 1)) + from
    }
    
}
