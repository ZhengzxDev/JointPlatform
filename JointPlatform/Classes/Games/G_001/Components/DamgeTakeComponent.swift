//
//  DamgeTakeComponent.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/21.
//

import GameplayKit

class DamageTakeComponent:GKComponent{
    
    private var target:HitableTarget?
    
    override func didAddToEntity() {
        super.didAddToEntity()
        if let nodeComponent = self.entity?.component(ofType: GKSKNodeComponent.self){
            target = nodeComponent.node as? HitableTarget
        }
    }
    
    func takeDamage(_ coldSteel:BaseBladeNode){
        target?.onHitBy(coldSteel)
    }
    
    func takeDamage(_ bullet:BaseBulletNode){
        target?.onHitBy(bullet)
    }
    
    func takeDamage(_ massInjury:MassInjuryNode){
        target?.onHitBy(massInjury)
    }
    
    override class var supportsSecureCoding: Bool{
        return true
    }
    
}
