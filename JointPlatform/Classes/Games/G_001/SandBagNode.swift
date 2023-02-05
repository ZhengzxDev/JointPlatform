//
//  SandBagNode.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/21.
//

import SpriteKit
import GameplayKit

protocol HitableTarget:NSObjectProtocol{
    func onHitBy(_ bullet:BaseBulletNode)
    func onHitBy(_ blade:BaseBladeNode)
    func onHitBy(_ massInjury:MassInjuryNode)
}


class SandBagNode:SKSpriteNode,HitableTarget{
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setupPhysicsBody()
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPhysicsBody()
        setupAppearance()
    }
    
    func setupPhysicsBody(){
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 29, height: 29))
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.collisionBitMask = ColliderType.Ground
        self.physicsBody?.contactTestBitMask = ColliderType.Bullet
        self.physicsBody?.categoryBitMask = ColliderType.Enemy
    }
    
    func setupAppearance(){
        self.texture = SKTexture(imageNamed: "dunm_idle1")
        self.blendMode = .alpha
        self.zPosition = zPositionConfig.Enemy.rawValue
        self.colorBlendFactor = 0
        self.run(.init(named: "enemy_0_idle")!)
    }
    
    
    func getDamage(_ value:Double){
        
        let damageLable = DamageLabelNode()
        self.scene!.addChild(damageLable)
        let randXOffset = 5 * Double.random()
        let randYOffset = 5 * Double.random()
        damageLable.position = self.position.offsetBy(dx: randXOffset, dy: randYOffset)
        damageLable.setText("-\(Int(value))")
        damageLable.display()
        
        if self.action(forKey: "hurt") != nil{
            self.removeAction(forKey: "hurt")
        }
        self.run(.group([
            .sequence([
                .customAction(withDuration: 0.01, actionBlock: { node, val in
                    guard let sNode = node as? SandBagNode else { return }
                    sNode.blendMode = .add
                }),
                .wait(forDuration: 0.1),
                .customAction(withDuration: 0.01, actionBlock: { node, val in
                    guard let sNode = node as? SandBagNode else { return }
                    sNode.blendMode = .alpha
                }),
            ]),
            .init(named: "enemy_0_hit")!
        ]),withKey: "hurt")
        
    }
    
    func onHitBy(_ bullet: BaseBulletNode) {
        let hitEffectNode = HitFxNode(position: self.position, randomRect: self.frame)
        self.scene?.addChild(hitEffectNode)
        getDamage(bullet.damage)
    }
    
    func onHitBy(_ blade: BaseBladeNode) {
        let hitEffectNode = HitFxNode(position: self.position, randomRect: self.frame)
        self.scene?.addChild(hitEffectNode)
        getDamage(blade.info.damage)
    }
    
    func onHitBy(_ massInjury: MassInjuryNode) {
        let hitEffectNode = HitFxNode(position: self.position, randomRect: self.frame)
        self.scene?.addChild(hitEffectNode)
        getDamage(massInjury.damage)
    }
}
