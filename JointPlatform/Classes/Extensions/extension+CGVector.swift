//
//  extension+CGVector.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/20.
//

import UIKit

extension CGVector{
    
    static func * (left:CGVector,right:Double) -> CGVector{
        return CGVector(dx: left.dx*right, dy: left.dy*right)
    }
    
    static func * (left:Double,right:CGVector) -> CGVector{
        return CGVector(dx: left*right.dx, dy: left*right.dy)
    }
    
    func rotate(_ radian:Double) -> CGVector{
        guard radian != 0 else { return self }
        let cos = cos(radian)
        let sin = sin(radian)
        return CGVector(dx: self.dx * cos - self.dy * sin, dy: self.dx * sin + self.dy * cos)
    }
    
}
