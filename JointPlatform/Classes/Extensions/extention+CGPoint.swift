//
//  extention+CGPoint.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/13.
//

import UIKit


extension CGPoint{
    static func + (left:CGPoint,right:CGPoint) -> CGPoint{
        return CGPoint(x: left.x+right.x, y: left.y+right.y)
    }
    static func - (left:CGPoint,right:CGPoint) -> CGPoint{
        return CGPoint(x: left.x-right.x, y: left.y-right.y)
    }
    static func * (left:CGPoint,right:Double) -> CGPoint{
        return CGPoint(x: left.x*right, y: left.y*right)
    }
    static func * (left:Double,right:CGPoint) -> CGPoint{
        return CGPoint(x: left*right.x, y: left*right.y)
    }
    static func * (left:CGPoint,right:CGFloat) -> CGPoint{
        return CGPoint(x: left.x*right, y: left.y*right)
    }
    static func * (left:CGFloat,right:CGPoint) -> CGPoint{
        return CGPoint(x: left*right.x, y: left*right.y)
    }
    static func == (left:CGPoint,right:CGPoint) -> Bool{
        return left.x == right.x && left.y == right.y
    }
    
    
    func translate(direct:CGVector,length:CGFloat) -> CGPoint{
        if direct.dy == 0 && direct.dx != 0{
            return CGPoint(x: direct.dx > 0 ? self.x + length : self.x - length, y: self.y)
        }
        else if direct.dy != 0 && direct.dx == 0{
            return CGPoint(x: self.x, y: direct.dy > 0 ? self.y + length : self.y - length)
        }
        else if direct == CGVector.zero{
            return self
        }
        else{
            var radian = atan(abs(direct.dy / direct.dx))
            if direct.dy > 0 && direct.dx < 0{
                radian = Double.pi - radian
            }
            else if direct.dx < 0 && direct.dy < 0{
                radian = Double.pi + radian
            }
            else if direct.dx > 0 && direct.dy < 0{
                radian = 2 * Double.pi - radian
            }
            let offsetX = length * cos(radian)
            let offsetY = length * sin(radian)
            return CGPoint(x: self.x+offsetX, y: self.y+offsetY)
        }

    }
    
    func offsetBy(dx:CGFloat,dy:CGFloat) -> CGPoint{
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}
