//
//  G_001.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/11.
//

import UIKit
import SpriteKit

enum Hero:String{
    
    case WoftMan = "woft_man"
    
    case Engineer = "engineer"
    
    var index:Int{
        if self.rawValue == "woft_man"{
            return 0
        }
        else if self.rawValue == "engineer"{
            return 1
        }
        return -1
    }
    
    var totalValues:Int{
        return 2
    }
    
    static func valueWith(index:Int) -> Hero{
        switch index{
        case 0:
            return .WoftMan
        case 1:
            return .Engineer
        default:
            return .WoftMan
        }
    }
}

enum GameMap:Int{
    case Forest
    case Lab
}

struct InGamePlayer{
    
    var index:Int
    
    var hero:Hero
    
    var team:Int
    
    var lanPlayer:GameRoomPlayer
    
    
}

