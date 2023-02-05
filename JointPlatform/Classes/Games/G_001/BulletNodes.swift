//
//  NormalBulletNode.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/20.
//

import SpriteKit
import GameplayKit


class BaseBulletNode:SKSpriteNode{
    
    var damage:Double = 0
    
    var info:BulletInfo?
    
    var shooter:HeroCharacterNode?
    
    
    func make(direction:CGVector,info:WeaponInfo,startPos:CGPoint,radian:Double,force:Double){
        
    }
    
    func onHitGround(){
        
    }
    
    func onHitEmeny(_ node:SKNode?){
        
    }
    
    func onHitPlayer(_ heroNode:HeroCharacterNode?){
        
    }
    
    func didAddToScene(_ scene:SKScene){
        
    }
    
}


// MARK: - RegularBulletNode
class RegularBulletNode:BaseBulletNode{
    
    override func make(direction: CGVector, info: WeaponInfo, startPos: CGPoint, radian: Double,force:Double) {
        self.texture = SKTexture(imageNamed: "bullet_0")
        self.color = UIColor.clear
        self.size = info.bulletInfo.size
        self.position = startPos
        self.zPosition = zPositionConfig.Bullet.rawValue
        
        self.info = info.bulletInfo
        self.damage = info.damage
        setupPhysicsBody()
        var jitterRadian:Double = 0
        if info.jitterAngle != 0{
            let jitterVal:Double = Double(arc4random() % 200) - 100
            jitterRadian = jitterVal*info.jitterAngle/100
        }
        self.physicsBody?.velocity = CGVector(dx: direction.dx * info.bulletSpeed, dy: direction.dy * info.bulletSpeed).rotate(jitterRadian)
        self.zRotation = radian + jitterRadian
        
        self.run(SKAction.init(named: info.attackSoundActionName)!)
    }

    func setupPhysicsBody(){
        let radius = min(info!.size.height,info!.size.width)
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius/2-2)
        //自己的分类
        self.physicsBody?.categoryBitMask = ColliderType.Bullet
        //可以发生物理碰撞的对象
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.fieldBitMask = 0
        self.physicsBody?.contactTestBitMask = ColliderType.Ground | ColliderType.MapBounds | ColliderType.Enemy | ColliderType.Player
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
    }
    
    override func onHitGround(){
        
        if let spark = SKEmitterNode(fileNamed: "BulletSpark"){
            spark.zPosition = zPositionConfig.Effect.rawValue
            spark.position = self.position
            self.scene?.addChild(spark)
            spark.run(SKAction.sequence([
                .wait(forDuration: 0.1),
                .fadeOut(withDuration: 0.3),
                .removeFromParent()
            ]))
        }
        self.removeFromParent()
    }
    
    override func onHitEmeny(_ node: SKNode?) {
        if let damageTakeComponent = node?.entity?.component(ofType: DamageTakeComponent.self){
            damageTakeComponent.takeDamage(self)
        }
        self.removeFromParent()
    }
    
    override func onHitPlayer(_ heroNode: HeroCharacterNode?) {
        if let damageTakeComponent = heroNode?.entity?.component(ofType: DamageTakeComponent.self){
            if heroNode?.inGamePlayer?.team != self.shooter?.inGamePlayer?.team{
                damageTakeComponent.takeDamage(self)
                self.removeFromParent()
            }
            
        }
        
    }
    

}

// MARK: - AlienBulletNode
class AlienBulletNode:BaseBulletNode{
    
    override func make(direction: CGVector, info: WeaponInfo, startPos: CGPoint, radian: Double,force:Double) {
        self.texture = SKTexture(imageNamed: "bullet_3")
        self.color = UIColor.clear
        self.size = info.bulletInfo.size
        self.position = startPos
        self.zPosition = zPositionConfig.Bullet.rawValue
        self.info = info.bulletInfo
        self.damage = info.damage
        setupPhysicsBody()
        var jitterRadian:Double = 0
        if info.jitterAngle != 0{
            let jitterVal:Double = Double(arc4random() % 200) - 100
            jitterRadian = jitterVal*info.jitterAngle/100
        }
        self.physicsBody?.velocity = CGVector(dx: direction.dx * info.bulletSpeed, dy: direction.dy * info.bulletSpeed).rotate(jitterRadian)
        self.zRotation = radian + jitterRadian
        self.run(SKAction.init(named: info.attackSoundActionName)!)
    }

    func setupPhysicsBody(){
        let radius = min(info!.size.height,info!.size.width)
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius/2-2)
        //自己的分类
        self.physicsBody?.categoryBitMask = ColliderType.Bullet
        //可以发生物理碰撞的对象
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.fieldBitMask = 0
        self.physicsBody?.contactTestBitMask = ColliderType.Ground | ColliderType.MapBounds | ColliderType.Enemy | ColliderType.Player
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
    }
    
    override func onHitGround(){
        
        
        let explodeNode = SKSpriteNode(texture: SKTexture(imageNamed: "explosion-f1"))

        explodeNode.size = info!.fxSize
        explodeNode.position = self.position
        explodeNode.zPosition = zPositionConfig.Effect.rawValue
        explodeNode.color = .clear
        self.scene?.addChild(explodeNode)
        explodeNode.run(.sequence([
            SKAction(named: "fx_explosion_1")!,
            .removeFromParent()
        ]))
        self.removeFromParent()
    }
    
    override func onHitEmeny(_ node: SKNode?) {
        if let damageTakeComponent = node?.entity?.component(ofType: DamageTakeComponent.self){
            damageTakeComponent.takeDamage(self)
        }
        self.removeFromParent()
    }
    
    override func onHitPlayer(_ heroNode: HeroCharacterNode?) {
        if let damageTakeComponent = heroNode?.entity?.component(ofType: DamageTakeComponent.self){
            if heroNode?.inGamePlayer?.team != self.shooter?.inGamePlayer?.team{
                damageTakeComponent.takeDamage(self)
                self.removeFromParent()
            }
            
        }
        
    }
}


// MARK: - PoopBulletNode
class PoopBulletNode:BaseBulletNode{

    
    override func make(direction: CGVector, info: WeaponInfo, startPos: CGPoint, radian: Double,force:Double) {
        self.texture = SKTexture(imageNamed: "bullet_4")
        self.color = UIColor.clear
        self.size = info.bulletInfo.size
        self.position = startPos
        self.zPosition = zPositionConfig.Bullet.rawValue
        self.info = info.bulletInfo
        self.damage = info.damage
        setupPhysicsBody()
        var jitterRadian:Double = 0
        if info.jitterAngle != 0{
            let jitterVal:Double = Double(arc4random() % 200) - 100
            jitterRadian = jitterVal*info.jitterAngle/100
        }
        self.physicsBody?.velocity = CGVector(dx: direction.dx * info.bulletSpeed, dy: direction.dy * info.bulletSpeed).rotate(jitterRadian)
        
        self.zRotation = Double(arc4random() % 100)/100 * 2 * Double.pi
        self.run(.group([
            .repeatForever(.rotate(byAngle: 2*Double.pi, duration: 1)),
            .init(named: info.attackSoundActionName)!
        ]))
    }

    func setupPhysicsBody(){
        let radius = min(info!.size.height,info!.size.width)
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius/2-2)
        //自己的分类
        self.physicsBody?.categoryBitMask = ColliderType.Bullet
        //可以发生物理碰撞的对象
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.fieldBitMask = 0
        self.physicsBody?.contactTestBitMask = ColliderType.Ground | ColliderType.MapBounds | ColliderType.Enemy | ColliderType.Player
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
    }
    
    override func onHitGround(){
        
        
        let explodeNode = SKSpriteNode(texture: SKTexture(imageNamed: "explosion-g1"))

        explodeNode.size = info!.fxSize
        explodeNode.position = self.position
        explodeNode.zPosition = zPositionConfig.Effect.rawValue
        explodeNode.color = .clear
        self.scene?.addChild(explodeNode)
        explodeNode.run(.sequence([
            SKAction(named: "fx_explosion_2")!,
            .removeFromParent()
        ]))
        self.removeFromParent()
    }
    
    override func onHitEmeny(_ node: SKNode?) {
        if let damageTakeComponent = node?.entity?.component(ofType: DamageTakeComponent.self){
            damageTakeComponent.takeDamage(self)
        }
        self.removeFromParent()
    }
    
    override func onHitPlayer(_ heroNode: HeroCharacterNode?) {
        if let damageTakeComponent = heroNode?.entity?.component(ofType: DamageTakeComponent.self){
            if heroNode?.inGamePlayer?.team != self.shooter?.inGamePlayer?.team{
                damageTakeComponent.takeDamage(self)
                self.removeFromParent()
            }
            
        }
        
    }
    
}

// MARK: - MissileBulletNode
class MissileBulletNode:BaseBulletNode{
    
    private var initRadian:Double = 0
    
    private var initDirection:CGVector = .zero
    
    private var weaponInfo:WeaponInfo?
    
    private var smokeParticle:SKEmitterNode?
    
    override func make(direction: CGVector, info: WeaponInfo, startPos: CGPoint, radian: Double,force:Double) {
        
        self.texture = SKTexture(imageNamed: "bullet_bomb_1_0")
        
        self.color = UIColor.clear
        self.size = info.bulletInfo.size
        self.position = startPos
        self.zPosition = zPositionConfig.Bullet.rawValue
        self.info = info.bulletInfo
        self.weaponInfo = info
        self.damage = info.damage
        self.initRadian = radian
        self.initDirection = direction
        setupPhysicsBody()
        
        var jitterRadian:Double = 0
        if info.jitterAngle != 0{
            let jitterVal:Double = Double(arc4random() % 200) - 100
            jitterRadian = jitterVal*info.jitterAngle/100
        }
        self.physicsBody?.velocity = CGVector(dx: direction.dx * info.bulletSpeed * force, dy: direction.dy * info.bulletSpeed * force).rotate(jitterRadian)
        
        
        self.run(.group([
            SKAction(named: "missile_rotate")!,
            SKAction.init(named: info.attackSoundActionName)!
        ]))
    }
    
    func setupPhysicsBody(){
        let radius = min(info!.size.height,info!.size.width)
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius/2-2)
        //自己的分类
        self.physicsBody?.categoryBitMask = ColliderType.Bullet
        //可以发生物理碰撞的对象
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.fieldBitMask = 0
        self.physicsBody?.contactTestBitMask = ColliderType.Ground | ColliderType.MapBounds
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
    }
    
    override func onHitGround() {
        guard let baseScene = self.scene as? BaseScene else { return }
        let explodeNode = MassInjuryNode(damageRectSize: CGSize(width: 50, height: 50), damage: self.weaponInfo!.damage)
        explodeNode.texture = SKTexture(imageNamed: "explosion-a1")
        explodeNode.size = info!.fxSize
        explodeNode.position = self.position
        explodeNode.zPosition = zPositionConfig.Effect.rawValue
        explodeNode.color = .clear
        explodeNode.shooter = self.shooter
        self.scene?.addChild(explodeNode)
        explodeNode.run(.group([
            .sequence([
                SKAction(named: "fx_explosion_0")!,
                .removeFromParent()
            ]),
            .init(named: "explosion_0_sound")!
        ]))
        
        smokeParticle?.particleBirthRate = 0
        smokeParticle?.run(.sequence([
            .fadeAlpha(to: 0, duration: 1),
            .removeFromParent(),
            .customAction(withDuration: 0, actionBlock: { [weak self] node, _ in
                baseScene.removeEntity(for: node)
                guard let strongSelf = self else { return }
                strongSelf.removeFromParent()
            })
        ]))
        smokeParticle = nil
        self.alpha = 0
        self.physicsBody = nil
        baseScene.removeEntity(for: self)
    }
    
    override func didAddToScene(_ scene: SKScene) {
        self.zRotation = initRadian
        guard let baseScene = self.scene as? BaseScene else { return }
        self.entity = baseScene.registerEntity(for: self)
        self.entity?.addComponent(GKSKNodeComponent(node: self))
        self.entity?.addComponent(RotateToDirectionComponent())
        if let smoke = SKEmitterNode(fileNamed: "MissileSmoke"){
            
            smoke.position = self.position.translate(direct: -1*self.initDirection, length: self.size.width/2)
            smoke.entity = baseScene.registerEntity(for: smoke)
            self.smokeParticle = smoke
            smoke.targetNode = baseScene
            smoke.zPosition = zPositionConfig.Effect.rawValue
            
            let anchorNode = SKNode()
            anchorNode.position = CGPoint(x: -self.size.width/2, y: 0)
            self.addChild(anchorNode)
            
            let trailComponnet = TrailControlComponent()
            trailComponnet.setTarget(self)
            trailComponnet.setEmitter(smokeParticle!)
            trailComponnet.setEmitterAnchor(anchorNode)
            smoke.entity!.addComponent(trailComponnet)
            if self.xScale > 0{
                smoke.emissionAngle = self.zRotation + Double.pi
            }
            else{
                smoke.emissionAngle = self.zRotation
            }
            
            self.scene?.addChild(smoke)
        }
    }
    
}

// MARK: - grenadeNode

class GrenadeBulletNode:BaseBulletNode{
    
    private var weaponInfo:WeaponInfo?
    
    override func make(direction: CGVector, info: WeaponInfo, startPos: CGPoint, radian: Double,force:Double) {
        
        self.texture = SKTexture(imageNamed: "bullet_grenade_0_0")
        
        self.color = UIColor.clear
        self.size = info.bulletInfo.size
        self.position = startPos
        self.zPosition = zPositionConfig.Bullet.rawValue
        self.info = info.bulletInfo
        self.weaponInfo = info
        self.damage = info.damage
        setupPhysicsBody()
        
        var jitterRadian:Double = 0
        if info.jitterAngle != 0{
            let jitterVal:Double = Double(arc4random() % 200) - 100
            jitterRadian = jitterVal*info.jitterAngle/100
        }
        self.physicsBody?.velocity = CGVector(dx: direction.dx * info.bulletSpeed * force, dy: direction.dy * info.bulletSpeed * force).rotate(jitterRadian)
        self.physicsBody?.angularVelocity = direction.dx > 0 ? -8 : 8
        self.run(SKAction.init(named: info.attackSoundActionName)!)
    }
    
    func setupPhysicsBody(){
        self.physicsBody = SKPhysicsBody(rectangleOf: info!.size)
        //自己的分类
        self.physicsBody?.categoryBitMask = ColliderType.Bullet
        //可以发生物理碰撞的对象
        self.physicsBody?.collisionBitMask = ColliderType.Ground
        //self.physicsBody?.fieldBitMask = 0
        self.physicsBody?.contactTestBitMask = ColliderType.Ground | ColliderType.MapBounds
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = true
    }
    
    override func onHitGround() {
        
        
        self.run(.sequence([
            .init(named: "grenade_count_down")!,
            .customAction(withDuration: 0.01, actionBlock: { [weak self] node, val in
                guard let strongSelf = self else { return }
                let explodeNode = MassInjuryNode(damageRectSize: strongSelf.info!.fxSize, damage: strongSelf.weaponInfo!.damage)
                explodeNode.texture = SKTexture(imageNamed: "explosion-e1")
                explodeNode.size = strongSelf.info!.fxSize
                explodeNode.position = strongSelf.position
                explodeNode.zPosition = zPositionConfig.Effect.rawValue
                explodeNode.color = .clear
                strongSelf.scene?.addChild(explodeNode)
                explodeNode.run(.group([
                    .sequence([
                        SKAction(named: "fx_explosion_3")!,
                        .removeFromParent()
                    ]),
                    .init(named: "explosion_1_sound")!
                ]))
            }),
            .removeFromParent()
        ]))


    }
    

    
}
