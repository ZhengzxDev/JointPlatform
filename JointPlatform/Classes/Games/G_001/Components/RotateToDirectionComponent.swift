//
//  RotateToDirectionComponent.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/27.
//

import GameplayKit

class RotateToDirectionComponent:GKComponent{
    
    var targetNode:SKNode?
    
    override func didAddToEntity() {
        super.didAddToEntity()
        if let node = self.entity?.component(ofType: GKSKNodeComponent.self)?.node{
            targetNode = node
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let targetNodeVelocity = targetNode?.physicsBody?.velocity else { return }
        let ratio = Double(targetNodeVelocity.dy/targetNodeVelocity.dx)
        let radian:Double = atan(ratio)
        targetNode?.zRotation = radian
    }
    
    
}
