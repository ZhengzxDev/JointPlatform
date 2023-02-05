//
//  extention+CGSize.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/19.
//

import UIKit


extension CGSize{
    
    func modify(_ deltaWidth:CGFloat,_ deltaHeight:CGFloat) -> CGSize{
        return CGSize(width: self.width + deltaWidth, height: self.height + deltaHeight)
    }
    
    func modify(scale value:CGFloat) -> CGSize {
        return CGSize(width: self.width*value, height: self.height*value)
    }
    
}
