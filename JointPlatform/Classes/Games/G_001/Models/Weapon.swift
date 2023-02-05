//
//  Weapon.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/19.
//

import Foundation
import UIKit
import SwiftyJSON

struct WeaponInfo{
    
    enum AttackType:Int{
        case none = 0
        case spawnBullet = 1
        case spawnBlade = 2
        case specialEffect = 3
    }
    

    var attackType:AttackType = .none
    
    var spareClipRemian:Int = -1
    
    var clipCapcacity:Int = 0
    
    var clipRemain:Int = 0
    
    var shootInterval:TimeInterval = 0
    
    var reloadInterval:TimeInterval = 0
    
    var size:CGSize = CGSize(width: 0, height: 0)
    
    var rotateWhileAiming:Bool = false
    
    var hideWhenNoBullet:Bool = false
    
    var bulletSpeed:CGFloat = 600.0
    
    var damage:CGFloat = 0
    
    var damageRadius:CGFloat = 0
    
    var name:String = ""
    
    var imageName:String = ""
    
    var attackSoundActionName:String = ""
    
    var jitterAngle:Double = 0
    
    var bulletOneShoot:Int = 0
    
    var attackDuration:Double = 0
    
    var anchorPoint:CGPoint = CGPoint(x: 0, y: 0.5)
    
    var bulletInfo:BulletInfo = BulletInfo()
    
    
    static func load(with id:String) -> WeaponInfo?{
        let weaponsJson = LocalJsonManager.shared.getJson(with: .Weapon)
        if let weaponInfoJson = weaponsJson?[id]{
            var weaponModel = WeaponInfo()
            weaponModel.spareClipRemian = weaponInfoJson["spareClipRemain"].intValue
            weaponModel.clipCapcacity = weaponInfoJson["clipCapacity"].intValue
            weaponModel.clipRemain = weaponModel.clipCapcacity
            weaponModel.shootInterval = weaponInfoJson["shootInterval"].doubleValue
            weaponModel.reloadInterval = weaponInfoJson["reloadInterval"].doubleValue
            weaponModel.rotateWhileAiming = weaponInfoJson["rotateWhileAiming"].boolValue
            weaponModel.hideWhenNoBullet = weaponInfoJson["hideWhenNoBullet"].boolValue
            weaponModel.bulletSpeed = weaponInfoJson["bulletSpeed"].doubleValue
            weaponModel.damage = weaponInfoJson["damage"].doubleValue
            weaponModel.damageRadius = weaponInfoJson["damageRadius"].doubleValue
            weaponModel.name = weaponInfoJson["name"].stringValue
            weaponModel.jitterAngle = weaponInfoJson["jitterAngle"].doubleValue
            weaponModel.bulletOneShoot = weaponInfoJson["bulletOneShoot"].intValue
            weaponModel.imageName = weaponInfoJson["image"].stringValue
            weaponModel.bulletInfo = BulletInfo.load(with: weaponInfoJson["bulletId"].stringValue)
            weaponModel.attackDuration = weaponInfoJson["attackDuration"].doubleValue
            weaponModel.attackType = AttackType.init(rawValue:weaponInfoJson["attackType"].intValue)!
            weaponModel.attackSoundActionName = weaponInfoJson["attackSound"].stringValue
            if weaponInfoJson["size"] != JSON.null{
                weaponModel.size.width = weaponInfoJson["size"]["width"].doubleValue
                weaponModel.size.height = weaponInfoJson["size"]["height"].doubleValue
            }
            else{
                if let image = UIImage(named: weaponModel.imageName){
                    weaponModel.size = image.size
                }
                else{
                    debugLog("Weapon load failed, no such image named \(weaponModel.imageName)")
                    return nil
                }
            }
            
            weaponModel.anchorPoint = CGPoint(x: weaponInfoJson["anchor"]["x"].doubleValue, y: weaponInfoJson["anchor"]["y"].doubleValue)
            return weaponModel
        }
        return nil
    }
}

struct BulletInfo{
    
    enum BulletType:String{
        
        case none = ""
        case RegularBullet = "1"
        case AlienBullet = "2"
        case PoopBullet = "3"
        case MissileBullet = "4"
        case Grenade = "5"
    }
    
    var type:BulletType = .none
    
    var fxSize:CGSize = .zero
    
    var size:CGSize = CGSize(width: 18, height: 11)
    
    static func load(with id:String)->BulletInfo{
        guard let bullets = LocalJsonManager.shared.getJson(with: .Bullet) else { return BulletInfo() }
        let bulletInfo = bullets[id]
        var bulletModel = BulletInfo()
        bulletModel.type = BulletType.init(rawValue: id) ?? .none
        bulletModel.fxSize = CGSize(width: bulletInfo["fxSize"]["width"].doubleValue, height: bulletInfo["fxSize"]["height"].doubleValue)
        bulletModel.size = CGSize(width: bulletInfo["size"]["width"].doubleValue, height: bulletInfo["size"]["height"].doubleValue)

        return bulletModel
    }
    
}
