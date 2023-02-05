//
//  PickableWeaponNode.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/21.
//

import SpriteKit
import GameplayKit


class PickableWeaponNode:SKSpriteNode{
    
    var weaponInfo:WeaponInfo?
    
    var deltaY:Double = 5
    
    var weaponNode:SKSpriteNode?
    
    var mySize:CGSize = .zero
    
    var isSelfFadeAway:Bool = false
    
    convenience init(info:WeaponInfo){
        self.init(texture: SKTexture(imageNamed: "pick_weapon_background"), color: UIColor.white, size: .zero)
        let sideLength:CGFloat = max(info.size.height,info.size.width)
        mySize = CGSize(width: sideLength+15, height: sideLength+15)
        self.size = mySize
        self.weaponInfo = info
        self.zPosition = zPositionConfig.PickableWeapon.rawValue
        setupPhysicsBody()
        setupActions()
        
        weaponNode = SKSpriteNode(texture: SKTexture(imageNamed: info.imageName), color: UIColor.white, size: info.size)
        weaponNode?.zPosition = 1
        self.addChild(weaponNode!)
    }
    
    private func setupActions(){
        self.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: deltaY, duration: 0.5),
            .moveBy(x: 0, y: -deltaY, duration: 0.5)
        ])))
        
        self.run(.sequence([
            .wait(forDuration: 8),
            .fadeAlpha(to: 0.5, duration: 0.3),
            .fadeAlpha(to: 1, duration: 0.3),
            .fadeAlpha(to: 0.5, duration: 0.3),
            .fadeAlpha(to: 1, duration: 0.3),
            .fadeAlpha(to: 0.5, duration: 0.3),
            .fadeAlpha(to: 1, duration: 0.3),
            .fadeAlpha(to: 0, duration: 0.3),
            .customAction(withDuration: 0, actionBlock: { [weak self]  _, _ in
                guard let strongSelf = self else { return }
                guard let baseScene = strongSelf.scene as? BaseScene else { return }
                baseScene.removeTempNode(strongSelf)
                self?.removeFromParent()
                strongSelf.isSelfFadeAway = true
            })
        ]),withKey: "disappearAnimation")
    }
    
    private func setupPhysicsBody(){
        self.physicsBody = SKPhysicsBody(rectangleOf: mySize)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.MapBounds
        self.physicsBody?.categoryBitMask = ColliderType.Weapon
        self.physicsBody?.contactTestBitMask = ColliderType.Player
    }
    
    func onContactWith(_ hero:HeroCharacterNode){
        hero.contactWeaponNode = self
        guard let player = hero.inGamePlayer?.lanPlayer else { return }
        /*LANGameRunner.shared.connector?.syncTo(.joyStickUIUpdate, player: player, message: [
            "tag":3,
            "hidden":false
        ])*/
    }
    
    func onContactEndWith(_ hero:HeroCharacterNode){
        if hero.contactWeaponNode == self{
            hero.contactWeaponNode = nil
        }
        guard let player = hero.inGamePlayer?.lanPlayer else { return }
        /*LANGameRunner.shared.connector?.syncTo(.joyStickUIUpdate, player: player, message: [
            "tag":3,
            "hidden":true
        ])*/
    }
    
    func onPickedBy(_ hero:HeroCharacterNode){
        guard self.weaponInfo != nil && !hero.dead else { return }
        guard !isSelfFadeAway else {
            hero.contactWeaponNode = nil
            return
        }
        self.removeAction(forKey: "disappearAnimation")
        hero.contactWeaponNode = nil
        hero.pickWeapon(self.weaponInfo!)
        self.removeFromParent()
    }
    
    
    
}
