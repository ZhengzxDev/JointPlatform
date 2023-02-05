//
//  HeroWeaponNode.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/20.
//

import SpriteKit
import GameplayKit

class HeroWeaponNode:SKSpriteNode{
    
    
    var info:WeaponInfo = WeaponInfo()
    
    var reloading:Bool = false
    
    var reloadingRemain:TimeInterval = 0
    
    var cooling:Bool = false
    
    var coolingRemain:TimeInterval = 0
    
    var weaponInitPosition:CGPoint = CGPoint.zero
    
    var weaponInitRotation:Double = 0
    
    convenience init(weaponInfo:WeaponInfo){
        self.init(texture: SKTexture(), color: .clear, size: .zero)
        self.info = weaponInfo
    }

    
    func addComponents(){
        
        if self.entity == nil{
            guard let baseScene = self.scene as? BaseScene else {
                debugLog("HeroWeaponNode add Components failed")
                return
            }
            self.entity = baseScene.registerEntity(for: self)
        }
        
        self.entity?.addComponent(GKSKNodeComponent(node: self))
        self.entity?.addComponent(WeaponControlComponent())
    }
    
    func dispose(){
        guard let baseScene = self.scene as? BaseScene else {
            debugLog("HeroWeaponNode dispose self false")
            return
        }
        baseScene.removeEntity(for: self)
    }
    
    func setupAppearance(){
        self.texture = SKTexture(imageNamed: info.imageName)
        self.size = info.size
        self.zPosition = zPositionConfig.Weapon.rawValue
        self.anchorPoint = info.anchorPoint
        self.position = CGPoint(x: 0, y: -info.size.height+3)
        self.weaponInitPosition = self.position
        self.alpha = 1
        if self.info.attackType == .spawnBlade{
            //cool stell
            weaponInitRotation = 2.35
        }
        else if self.info.attackType == .spawnBullet{
            weaponInitRotation = 0
        }
        if info.hideWhenNoBullet{
            if self.info.clipRemain == 0{
                self.alpha = 0
            }
        }
    }
    
    func aimedBy(_ heroNode:HeroCharacterNode,radian:Double){
        if self.info.rotateWhileAiming{
            self.zRotation = radian
        }
    }
    
    func cancelAiming(){
        self.removeAllActions()
        self.zRotation = weaponInitRotation
    }
    
    func reloadDidComplete(_ heroNode:HeroCharacterNode){
        heroNode.stateView?.updateWeaponInfo(self.info)
    }
    
    func didFiredBy(_ heroNode:HeroCharacterNode){
        heroNode.stateView?.updateWeaponInfo(self.info)
    }
    
    func reloadWith(_ heroNode:HeroCharacterNode,progress:Double){
        heroNode.reload(with: progress)
    }
    
    
    func shouldFiredBy(_ heroNode:HeroCharacterNode,radian:Double){
        switch self.info.attackType{
        case .spawnBullet:
            guard let baseScene = heroNode.scene as? BaseScene else { return }
            
            let tempPos:CGPoint = CGPoint(x: self.position.x, y: self.position.y+self.info.size.height/2-3)
            
            var bulletSpawnPos:CGPoint = heroNode.convert(tempPos.translate(direct: heroNode.aimDirection, length: self.info.size.width-self.info.size.width*self.anchorPoint.x), to: heroNode.scene!)
            if heroNode.facing == -1{
                //fix bug, when facing == -1 bulletSpawnPos translate result for y is inversed
                let dist = abs(heroNode.position.x-bulletSpawnPos.x)
                bulletSpawnPos.x -= 2 * dist
            }
            for _ in 0 ..< self.info.bulletOneShoot{
                
                var bulletNode:BaseBulletNode?
                
                switch self.info.bulletInfo.type{
                    
                case .RegularBullet:
                    bulletNode = RegularBulletNode()
                    bulletNode!.make(direction: heroNode.aimDirection, info: self.info, startPos: bulletSpawnPos, radian: radian, force: heroNode.aimingForce)
                case .AlienBullet:
                    bulletNode = AlienBulletNode()
                    bulletNode!.make(direction: heroNode.aimDirection, info: self.info, startPos: bulletSpawnPos, radian: radian, force: heroNode.aimingForce)
                case .PoopBullet:
                    bulletNode = PoopBulletNode()
                    bulletNode!.make(direction: heroNode.aimDirection, info: self.info, startPos: bulletSpawnPos, radian: radian, force: heroNode.aimingForce)
                case .MissileBullet:
                    bulletNode = MissileBulletNode()
                    bulletNode!.make(direction: heroNode.aimDirection, info: self.info, startPos: bulletSpawnPos, radian: radian, force: heroNode.aimingForce)
                case .Grenade:
                    bulletNode = GrenadeBulletNode()
                    bulletNode!.make(direction: heroNode.aimDirection, info: self.info, startPos: bulletSpawnPos, radian: radian, force: heroNode.aimingForce)
                default:
                    break
                }
                bulletNode?.shooter = heroNode
                bulletNode?.xScale = heroNode.facing
                if bulletNode != nil{
                    baseScene.addChild(bulletNode!)
                    bulletNode?.didAddToScene(baseScene)
                }
            }
            let weaponNewPos = self.weaponInitPosition.translate(direct: -1*heroNode.aimDirection, length: 4)
            if heroNode.facing == 1{
                self.position = weaponNewPos
            }
            else{
                self.position = CGPoint(x: -weaponNewPos.x, y: weaponNewPos.y)
            }

            break
        case .spawnBlade:
            //guard let baseScene = heroNode.scene as? BaseScene else { return }
            self.zRotation = 2.35
            self.run(.rotate(byAngle: -Double.pi*2, duration: self.info.attackDuration))
            
            let bladeNode = NormalBladeNode(info: self.info)
            bladeNode.creator = heroNode
            bladeNode.position = self.position
            bladeNode.zPosition = zPositionConfig.Effect.rawValue
            heroNode.addChild(bladeNode)
            
            
            break
        case .specialEffect:
            break
        case .none:
            break
        }
    }
    

    
    func resetWith(_ weaponInfo:WeaponInfo){
        self.info = weaponInfo
        self.reloading = false
        //avoid keep reseting weapon to speed up shooting
        self.cooling = true
        self.coolingRemain = info.shootInterval
        setupAppearance()
    }
    
}
