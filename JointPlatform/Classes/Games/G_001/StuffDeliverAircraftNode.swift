//
//  StuffDeliverAircraftNode.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/2/2.
//

import SpriteKit

class StuffDeliverAircraftNode:SKSpriteNode{
    
    private let moveSpeedWithLoad:CGFloat = 50
    
    private let moveSpeedWithoutLoad:CGFloat = 100
    
    private let moveYValue:CGFloat = 130
    
    private var boxNode:SKSpriteNode?
    
    private var weaponInfo:WeaponInfo!
    
    convenience init(weapon:WeaponInfo,targetXPosition:CGFloat,scene:SKScene){
        self.init(texture: SKTexture(imageNamed: "aircraft_0"), color: UIColor.white, size: CGSize(width: 23, height: 23))
        self.weaponInfo = weapon
        let direction = Int.random(from: 0, to: 1)
        var moveInAction:SKAction!
        var moveOutAction:SKAction!
        if direction == 1{
            //move from right to left
            self.position = CGPoint(x: scene.size.width/2, y: moveYValue)
            let carryDistance =  scene.size.width/2 - targetXPosition
            let distanceRamain = scene.size.width - carryDistance
            moveInAction = SKAction.move(to: CGPoint(x: targetXPosition, y: moveYValue), duration: carryDistance/moveSpeedWithLoad)
            moveOutAction = SKAction.move(to: CGPoint(x: -scene.size.width/2, y: moveYValue), duration: distanceRamain/moveSpeedWithoutLoad)
            self.xScale = -1
        }
        else{
            //move from left to right
            self.position = CGPoint(x: -scene.size.width/2, y: moveYValue)
            let carryDistance =  targetXPosition + scene.size.width/2
            let distanceRamain = scene.size.width - carryDistance
            moveInAction = SKAction.move(to: CGPoint(x: targetXPosition, y: moveYValue), duration: carryDistance/moveSpeedWithLoad)
            moveOutAction = SKAction.move(to: CGPoint(x: scene.size.width/2, y: moveYValue), duration: distanceRamain/moveSpeedWithoutLoad)
            self.xScale = 1
        }

        self.run(.group([
            .init(named: "aircraft_0_fly")!,
            .sequence([
                moveInAction,
                .customAction(withDuration: 0, actionBlock: { [weak self]  _, _ in
                    self?.dropBox()
                }),
                .wait(forDuration: 1),
                moveOutAction,
                .removeFromParent(),
                .customAction(withDuration: 0, actionBlock: { [weak self] _, _ in
                    guard let strongSelf = self else { return }
                    guard let baseScene = self?.scene as? BaseScene else { return }
                    baseScene.removeTempNode(strongSelf)
                })
            ]),
            .repeatForever(.sequence([
                .moveTo(y: moveYValue+5, duration: 0.3),
                .moveTo(y: moveYValue-5, duration: 0.3)
            ])),
        ]))
        
        
        
        boxNode = SKSpriteNode(texture: SKTexture(imageNamed: "aircraft_box_0"), color: .white, size: CGSize(width: 20, height: 20))
        boxNode?.position = CGPoint(x: 0, y: -18)
        self.addChild(boxNode!)
        
        /*let floatAction = SKAction.repeatForever(.sequence([
            .moveTo(y: moveYValue+5, duration: 0.3),
            .moveTo(y: moveYValue-5, duration: 0.3)
        ]))*/
        
        /*self.run(.sequence([
            moveInAction,
            .customAction(withDuration: 0, actionBlock: { [weak self]  _, _ in
                self?.dropBox()
            }),
            moveOutAction,
            .removeFromParent()
        ]))*/
        
    }
    
    private func dropBox(){
        //print("drop")
        
        let dropBoxNode = StuffDeliverBoxNode(weapon: weaponInfo, position: self.convert(boxNode!.position, to: self.scene!),scene: self.scene!)
        dropBoxNode.xScale = self.xScale
        guard let baseScene = self.scene as? BaseScene else { return }
        baseScene.addChild(dropBoxNode)
        baseScene.addTempNode(self)
        boxNode?.removeFromParent()
    }
    
    
}
