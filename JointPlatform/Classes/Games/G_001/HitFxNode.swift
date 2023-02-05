//
//  HitFxNode.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/28.
//

import SpriteKit

class HitFxNode:SKSpriteNode{
    
    
    convenience init(position:CGPoint, randomRect:CGRect){
        var fxName = "fx_hit_"
        var hitImageName = "fxhit_"
        let rand = Double.random()
        var effectSize = CGSize.zero
        if rand > 0{
            fxName += "0"
            hitImageName += "big1"
            effectSize = CGSize(width: 30, height: 30)
        }
        else{
            fxName += "1"
            hitImageName += "small1"
            effectSize = CGSize(width: 20, height: 20)
        }
        
        let randXOffset = Double.random() * randomRect.size.width / 2
        let randYOffset = Double.random() * randomRect.size.height / 2
        
        self.init(texture: SKTexture(imageNamed: hitImageName), color: .clear, size: effectSize)
        self.position = position.offsetBy(dx: randXOffset, dy: randYOffset)
        self.zPosition = zPositionConfig.Effect.rawValue
        self.run(.sequence([
            SKAction.init(named: fxName)!,
            .removeFromParent()
        ]))
    }
    
    
    
}
