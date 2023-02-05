//
//  StuffDeliverBoxNode.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/2/11.
//

import SpriteKit
import GameplayKit

class StuffDeliverBoxNode:SKSpriteNode,HitableTarget{
    
    private let mySize:CGSize = CGSize(width: 20, height: 20)
    
    var weaponInfo:WeaponInfo?
    
    var health:Double = 40
    
    convenience init(weapon:WeaponInfo,position:CGPoint,scene:SKScene){
        self.init(texture: SKTexture(imageNamed: "aircraft_box_0"), color: .white, size: CGSize(width: 20, height: 20))
        self.position = position
        self.weaponInfo = weapon
        
        let baseScene = scene as! BaseScene
        self.entity = baseScene.registerEntity(for: self)
        self.entity?.addComponent(GKSKNodeComponent(node: self))
        self.entity!.addComponent(DamageTakeComponent())
        baseScene.addTempNode(self)
        
        addPhysicsBody()
        
        
    }
    
    
    private func addPhysicsBody(){
        
        self.physicsBody = SKPhysicsBody(rectangleOf: mySize)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.contactTestBitMask = ColliderType.Bullet | ColliderType.ColdSteel | ColliderType.MassInjury
        self.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.MapBounds | ColliderType.DeliverBox
        self.physicsBody?.categoryBitMask = ColliderType.DeliverBox
        
    }
    
    private func getDamage(_ value:Double){
        
        self.health = max(self.health-value,0)
        
        if self.health == 0{
            guard let baseScene = self.scene as? BaseScene else { return }
            self.texture = SKTexture(imageNamed: "explosion-g1")
            self.size = CGSize(width: 30, height: 30)
            let weaponNode = PickableWeaponNode(info: self.weaponInfo!)
            weaponNode.position = self.position
            weaponNode.physicsBody?.velocity = CGVector(dx: 0, dy: 300)
            weaponNode.setScale(0)
            weaponNode.run(.scale(to: 1, duration: 0.2))
            baseScene.addTempNode(weaponNode)
            baseScene.removeTempNode(self)
            baseScene.addChild(weaponNode)
            self.run(.sequence([
                SKAction.init(named: "fx_explosion_2")!,
                .removeFromParent(),
            ]))
        }
        else{
            self.blendMode = .alpha
            let hitEffectNode = HitFxNode(position: self.position, randomRect: self.frame)
            self.scene?.addChild(hitEffectNode)
            if self.action(forKey: "hurt") != nil{
                self.removeAction(forKey: "hurt")
            }
            self.run(.group([
                .sequence([
                    .customAction(withDuration: 0.01, actionBlock: { node, val in
                        guard let sNode = node as? StuffDeliverBoxNode else { return }
                        sNode.blendMode = .add
                    }),
                    .wait(forDuration: 0.1),
                    .customAction(withDuration: 0.01, actionBlock: { node, val in
                        guard let sNode = node as? StuffDeliverBoxNode else { return }
                        sNode.blendMode = .alpha
                    }),
                ]),
            ]),withKey: "hurt")
        }
        
    }
    
    func onHitBy(_ bullet: BaseBulletNode) {
        guard self.health > 0 else { return }
        getDamage(bullet.damage)
    }
    
    func onHitBy(_ blade: BaseBladeNode) {
        guard self.health > 0 else { return }
        getDamage(blade.info.damage)
    }
    
    func onHitBy(_ massInjury: MassInjuryNode) {
        guard self.health > 0 else { return }
        getDamage(massInjury.damage)
    }
    
    
    
}
