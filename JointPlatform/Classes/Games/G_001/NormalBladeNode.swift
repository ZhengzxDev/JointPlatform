//
//  NormalBladeNode.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/25.
//

import SpriteKit

class BaseBladeNode:SKNode{
    
    var creator:HeroCharacterNode?
    
    var info:WeaponInfo!
    
    func onHitTarget(_ node:SKNode?){
        
    }
}


class NormalBladeNode:BaseBladeNode{
    
    private var effectNode:SKSpriteNode!
    
    var hitPlayers:[InGamePlayer] = []
    
    convenience init(info:WeaponInfo){
        self.init()
        self.info = info
        let sideLength:CGFloat = info.damageRadius*2 + 4
        
        effectNode = SKSpriteNode(texture: SKTexture(imageNamed: "effect_axe"), color: .clear, size: CGSize(width: sideLength, height: sideLength))
        effectNode.position = .zero
        effectNode.alpha = 0
        self.zPosition = zPositionConfig.Effect.rawValue
        effectNode.color = UIColor.clear
        self.addChild(effectNode)
        self.setupPhysicsBody()
        effectNode.run(.sequence([
            .wait(forDuration: max(0,info.attackDuration-0.2)),
            .customAction(withDuration: 0, actionBlock: { [weak self] _, _ in
                self?.effectNode.alpha = 1
            }),
            .fadeOut(withDuration: 0.2),
            .customAction(withDuration: 0, actionBlock: {[weak self] _, _ in
                self?.removeFromParent()
            })
        ]))

        self.run(.init(named: info.attackSoundActionName)!)
        

    }
    
    private func setupPhysicsBody(){
        self.physicsBody = SKPhysicsBody(circleOfRadius: info.damageRadius)
        //自己的分类
        self.physicsBody?.categoryBitMask = ColliderType.ColdSteel
        //可以发生物理碰撞的对象
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.fieldBitMask = 0
        self.physicsBody?.contactTestBitMask =  ColliderType.Enemy | ColliderType.Player
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
    }
    
    override func onHitTarget(_ node: SKNode?) {
        
        if let heroNode = node as? HeroCharacterNode{
            
            guard heroNode != creator else { return }
            
            var isHitBefore:Bool = false
            
            for p in self.hitPlayers{
                if p.index == heroNode.inGamePlayer?.index{
                    isHitBefore = true
                }
            }
            
            guard !isHitBefore else { return }
            
            if heroNode.inGamePlayer?.team != creator?.inGamePlayer?.team{
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
