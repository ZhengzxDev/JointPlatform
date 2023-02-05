//
//  TrailControlComponent.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/29.
//

import SpriteKit
import GameplayKit

class TrailControlComponent:GKComponent{
    
    private var target:SKNode?
    private var emitter:SKEmitterNode?
    private var anchor:SKNode?
    
    func setTarget(_ node:SKNode){
        self.target = node
    }
    
    func setEmitter(_ node:SKEmitterNode){
        self.emitter = node
    }
    
    func setEmitterAnchor(_ node:SKNode){
        self.anchor = node
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard self.target != nil && self.emitter != nil && anchor != nil else { return }
        //self.emitter?.emissionAngle = target!.zRotation
        
        self.emitter?.position = target!.convert(anchor!.position, to: target!.scene!)
        
        if target!.xScale > 0{
            self.emitter?.emissionAngle = target!.zRotation + Double.pi
        }
        else{
            self.emitter?.emissionAngle = target!.zRotation
        }
        
    }
    
    
}
