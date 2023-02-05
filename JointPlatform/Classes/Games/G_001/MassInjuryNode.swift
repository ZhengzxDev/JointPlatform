//
//  MassInjuryNode.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/28.
//

import SpriteKit

class MassInjuryNode:SKSpriteNode{
    
    var shooter:HeroCharacterNode?
    
    var damage:Double = 0
    
    var hitPlayers:[InGamePlayer] = []
    
    convenience init(damageRectSize:CGSize,damage:Double){
        self.init()
        self.damage = damage
        self.physicsBody = SKPhysicsBody(rectangleOf: damageRectSize)
        setupPhysicsBody()
    }
    
    convenience init(damageRadius:CGFloat,damage:Double){
        self.init()
        self.damage = damage
        self.physicsBody = SKPhysicsBody(circleOfRadius: damageRadius)
        setupPhysicsBody()
    }
    
    private func setupPhysicsBody(){
        self.physicsBody?.categoryBitMask = ColliderType.MassInjury
        //可以发生物理碰撞的对象
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.fieldBitMask = 0
        self.physicsBody?.contactTestBitMask =  ColliderType.Enemy | ColliderType.Player
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
    }
    
    func onHitWith(_ node:SKNode?){
        
        if let heroNode = node as? HeroCharacterNode{
            
            var isHitBefore:Bool = false
            
            for p in self.hitPlayers{
                if p.index == heroNode.inGamePlayer?.index{
                    isHitBefore = true
                }
            }
            
            guard !isHitBefore else { return }
            
            if heroNode.inGamePlayer?.team != shooter?.inGamePlayer?.team{
                if let damageTakeComponent = node?.entity?.component(ofType: DamageTakeComponent.self){
                    damageTakeComponent.takeDamage(self)
                }
            }
            self.hitPlayers.append(heroNode.inGamePlayer!)
        }
        else{
            if let damageTakeComponent = node?.entity?.component(ofType: DamageTakeComponent.self){
                damageTakeComponent.takeDamage(self)
            }
        }
        
        
    }

    
}
