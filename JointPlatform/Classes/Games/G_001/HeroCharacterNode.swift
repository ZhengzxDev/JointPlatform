//
//  HeroCharacterNode.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/14.
//

import SpriteKit
import GameplayKit

class HeroCharacterNode:SKSpriteNode{
    
    var inGamePlayer:InGamePlayer?
    
    var stateView:PlayerStateView?
    
    var heroType:Hero = .WoftMan
    
    var weaponNode:HeroWeaponNode?
    
    var groundDetectNode:SKSpriteNode?
    
    var weapons:[WeaponInfo] = []
    
    var currentWeaponIndex:Int = -1
    
    //follow are variables indicate that hero current action state
    var right = false
    var left = false
    var down = false
    ///keep true during receive jump command and rise period, return false while falling
    var jump = false
    ///land animation flag
    var landed = false
    ///collision detector flag
    var grounded = false
    ///whether hero is aiming
    var aiming:Bool = false
    
    var dead:Bool = false
    
    var aimingForce:Double = 0
    
    var aimDirection:CGVector = CGVector.zero
    
    var facing:CGFloat = 1{
        didSet{
            self.heroIndicateLabel?.xScale = facing
            self.reloadIndicateNode.xScale = facing
        }
    }
    
    var health:Double = 100
    
    var airAcceleration:CGFloat = 0.1
    var airDeaccelaration:CGFloat = 0.0
    var groundAcceleration:CGFloat = 0.2
    var groundDeacceleration:CGFloat = 0.5
    //horizontal speed
    var hSpeed:CGFloat = 0.0
    var walkSpeed:CGFloat = 1.5
    var maxJump:CGFloat = 8.0
    
    var physicRadius:CGFloat = 14
    var stateMachine:GKStateMachine?
    var contactWeaponNode:PickableWeaponNode?
    
    var heroIndicateLabel:SKLabelNode?
    
    var reloadIndicateNode:SKSpriteNode = SKSpriteNode()
    
    var teamIndicateNode:SKSpriteNode!
    
    var offlineIndicateNode:SKSpriteNode!
    
    convenience init(gamePlayer:InGamePlayer){
        let heroTexture = SKTexture(imageNamed: gamePlayer.hero.rawValue+"_idle_0")
        self.init(texture: heroTexture, color: .white, size: heroTexture.size())
        self.inGamePlayer = gamePlayer
        self.heroType = gamePlayer.hero
        self.zPosition = zPositionConfig.Hero.rawValue
        
        
        
        setupTeamTag()
    }
    
    func addComponents(moveComponent:HeroControlComponent){
        if self.entity == nil{
            guard let baseScene = self.scene as? BaseScene else {
                debugLog("HeroCharacterNode add Components failed")
                return
            }
            self.entity = baseScene.registerEntity(for: self)
        }
        
        self.entity?.addComponent(GKSKNodeComponent(node: self))
        self.entity?.addComponent(moveComponent)
        self.entity?.addComponent(DamageTakeComponent())
        
        let animationComponent = HeroAnimationComponent()
        animationComponent.loadActions(with: self)
        self.entity?.addComponent(animationComponent)
    }
    
    func setupWeapon(info:WeaponInfo){
        self.weapons.removeAll()
        self.currentWeaponIndex = -1
        self.contactWeaponNode = nil
        
        self.weaponNode?.dispose()
        self.weaponNode?.removeFromParent()
        
        weaponNode = HeroWeaponNode(weaponInfo: info)
        self.addChild(weaponNode!)
        weaponNode!.addComponents()
        self.pickWeapon(info)
    }
    
    func setOffline(_ value:Bool){
        if value{
            if self.offlineIndicateNode == nil{
                self.offlineIndicateNode = SKSpriteNode(imageNamed: "icon_unlink")
                self.offlineIndicateNode.size = CGSize(width: 15, height: 15)
                self.offlineIndicateNode.position = CGPoint(x: 0, y: self.size.height/2+30)
            }
            self.offlineIndicateNode.run(.repeatForever(.sequence([
                .fadeOut(withDuration: 0.4),
                .fadeIn(withDuration: 0.4)
            ])))
            self.addChild(offlineIndicateNode)
        }
        else{
            offlineIndicateNode?.removeAllActions()
            offlineIndicateNode?.removeFromParent()
        }
    }
    
    private func setupTeamTag(){
        assert(self.inGamePlayer != nil)
        self.teamIndicateNode = SKSpriteNode(texture: SKTexture(imageNamed: "team_tag_\(self.inGamePlayer!.team)"), color: .clear, size: CGSize(width:15, height: 15))
        self.teamIndicateNode.position = CGPoint(x: 0, y: self.size.height/2+10)
        self.teamIndicateNode.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 2, duration: 0.5),
            .moveBy(x: 0, y: -2, duration: 0.5),
        ])))
        self.addChild(teamIndicateNode)
    }
    
    func setupStateMechine(){
        let normalState = HeroNormalState(with: self)
        let aimState = HeroAimState(with: self)
        let deadState = HeroDeadState()
        self.stateMachine = GKStateMachine(states: [normalState,aimState,deadState])
        stateMachine?.enter(HeroNormalState.self)
    }
    
    func setupPhysicsBody(){
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 15, height: self.physicRadius*2))
        //自己的分类
        self.physicsBody?.categoryBitMask = ColliderType.Player
        //可以发生物理碰撞的对象
        self.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.MapBounds
        self.physicsBody?.fieldBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.allowsRotation = false
        //self.physicsBody?.restitution = 0
        self.weaponNode!.alpha = 1
        
        
        groundDetectNode = SKSpriteNode()
        
        groundDetectNode?.size = CGSize(width: 1, height: 1)
        groundDetectNode?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: 1))
        groundDetectNode?.color = UIColor.clear
        groundDetectNode?.physicsBody?.categoryBitMask = ColliderType.GroundDetector
        groundDetectNode?.physicsBody?.collisionBitMask = 0
        groundDetectNode?.physicsBody?.contactTestBitMask = ColliderType.Ground
        groundDetectNode?.physicsBody?.allowsRotation = false
        groundDetectNode?.physicsBody?.affectedByGravity = false
        groundDetectNode?.physicsBody?.isDynamic = false
        groundDetectNode?.physicsBody?.pinned = true
        groundDetectNode?.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(groundDetectNode!)
    }
    
    func switchWeaponToIndex(_ index:Int){
        guard index >= 0 && index < weapons.count else { return }
        if self.currentWeaponIndex >= 0{
            self.weapons[self.currentWeaponIndex] = self.weaponNode!.info
        }
        self.currentWeaponIndex = index
        let weapon = self.weapons[index]
        self.weaponNode!.resetWith(weapon)
        self.reloadIndicateNode.removeFromParent()
        indicate(weapon.name)
        self.updateStateView()
        self.run(.playSoundFileNamed("fx_switch", waitForCompletion: false))
    }
    
    func switchToNextWeapon(){
        guard !self.dead else { return }
        var newIdx = self.currentWeaponIndex + 1
        if newIdx >= self.weapons.count{
            newIdx = 0
        }
        guard newIdx != self.currentWeaponIndex else { return }
        self.switchWeaponToIndex(newIdx)
    }
    
    func pickWeapon(_ info:WeaponInfo){
        guard !self.dead else { return }
        self.weapons.append(info)
        if self.weapons.count > 2{
            //drop current weapon
            let dropWeapon = self.weaponNode!.info
            self.weapons.remove(at: self.currentWeaponIndex)
            self.currentWeaponIndex = -1
            let pickWeaponNode = PickableWeaponNode(info: dropWeapon)
            pickWeaponNode.position = self.position
            pickWeaponNode.physicsBody?.velocity.dy = 200
            
            (self.scene! as! BaseScene).addTempNode(pickWeaponNode)
            self.scene?.addChild(pickWeaponNode)
        }
        self.switchWeaponToIndex(self.weapons.count-1)
    }
    
    func bind(to stateView:PlayerStateView?){
        self.stateView = stateView
        self.stateView?.updatePlayerInfo(self.inGamePlayer!)
    }
    
    func updateStateView(){
        self.stateView?.updateWeaponInfo(self.weaponNode!.info)
        self.stateView?.updateHealth(self.health)
    }
    
    func indicate(_ str:String){
        heroIndicateLabel?.removeFromParent()
        let label = SKLabelNode(text: str)
        label.fontSize = 10
        label.fontColor = UIColor.white
        label.fontName = "TimesNewRomanPSMT"
        label.position = CGPoint(x: 0, y: self.size.height/2)
        label.xScale = self.xScale
        label.zPosition = zPositionConfig.GUI.rawValue
        self.addChild(label)
        label.run(.sequence([
            .wait(forDuration: 0.8),
            .fadeOut(withDuration: 0.5),
            .removeFromParent()
        ]))
        heroIndicateLabel = label
    }
    
    func reload(with progress:Double){
        if reloadIndicateNode.parent == nil{
            reloadIndicateNode.position = CGPoint(x: 0, y:  -self.size.height/2 - 3)
            reloadIndicateNode.size = CGSize(width: 12.6, height: 3)
            reloadIndicateNode.alpha = 1
            reloadIndicateNode.zPosition = zPositionConfig.GUI.rawValue
            self.addChild(reloadIndicateNode)
        }
        if progress < 0.33{
            reloadIndicateNode.texture = SKTexture(imageNamed: "reload_0")
        }
        else if progress < 0.67{
            reloadIndicateNode.texture = SKTexture(imageNamed: "reload_1")
        }
        else if progress < 0.99{
            reloadIndicateNode.texture = SKTexture(imageNamed: "reload_2")
        }
        else{
            reloadIndicateNode.texture = SKTexture(imageNamed: "reload_3")
            reloadIndicateNode.run(.sequence([
                .fadeOut(withDuration: 0.3),
                .removeFromParent()
            ]))
        }
    }
    
    func fixDetectorPosition(){
        groundDetectNode?.position = CGPoint(x: 0, y: -physicRadius)
    }
}


extension HeroCharacterNode:HitableTarget{
    
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
        self.color = SKColor.white
        self.run(.sequence([
            .customAction(withDuration: 0.01, actionBlock: { node, val in
                guard let sNode = node as? SandBagNode else { return }
                sNode.blendMode = .add
            }),
            .wait(forDuration: 0.1),
            .customAction(withDuration: 0.01, actionBlock: { node, val in
                guard let sNode = node as? SandBagNode else { return }
                sNode.blendMode = .alpha
            }),
        ]),withKey: "hurt")
        self.health -= value
        self.health = max(self.health,0)
        if self.health <= 0{
            //dead
            self.health = 0
            self.dead = true
            
            self.size = CGSize(width: 34, height: 25)
            self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 34, height: 21))
            self.physicsBody?.categoryBitMask = 0
            self.physicsBody?.collisionBitMask = ColliderType.Ground
            self.physicsBody?.contactTestBitMask = 0
            self.physicsBody?.allowsRotation = false
            self.weaponNode!.alpha = 0
            self.reloadIndicateNode.alpha = 0
            (self.scene! as! BaseScene).onPlayerDie(self.inGamePlayer!,heroNode: self)
            
        }
        self.stateView?.updateHealth(self.health)
        self.groundDetectNode?.removeAllActions()
        self.groundDetectNode!.run(.playSoundFileNamed("fx_hit_p\(Int.random(from: 1, to: 5))", waitForCompletion: false),withKey: "hitSound")
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
