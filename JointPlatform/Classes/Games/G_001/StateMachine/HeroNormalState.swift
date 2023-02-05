//
//  HeroNormalState.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/14.
//

import GameplayKit


//a state will handle each frame action of the sprite in this state

//one state of hero in the state machine, normal state means walk over ground
class HeroNormalState:GKState{
    
    var heroNode:HeroCharacterNode!
    
    init(with node:HeroCharacterNode){
        self.heroNode = node
    }
    
    //this method is called each frame when state machine is in this state.
    override func update(deltaTime seconds: TimeInterval) {
        //enter this state,modify hero speed properties and move hero with this speed.
        var acceleration:CGFloat = 0
        var deaccleration:CGFloat = 0
        //modify acceleration
        if heroNode.grounded{
            acceleration = heroNode.groundAcceleration
            deaccleration = heroNode.groundDeacceleration
        }
        else{
            acceleration = heroNode.airAcceleration
            deaccleration = heroNode.airDeaccelaration
        }
        //modify hspeed
        if heroNode.left{
            heroNode.facing = -1
            heroNode.xScale = -1
            heroNode.hSpeed = approach(start: heroNode.hSpeed, end: -heroNode.walkSpeed, shift: acceleration)//-heroNode.walkSpeed
        }
        else if heroNode.right{
            heroNode.facing = 1
            heroNode.xScale = 1
            heroNode.hSpeed = approach(start: heroNode.hSpeed, end: heroNode.walkSpeed, shift: acceleration)//heroNode.walkSpeed
        }
        else{
            heroNode.hSpeed = approach(start: heroNode.hSpeed, end: 0, shift: deaccleration)
        }
        
        if heroNode.grounded{
            //do landed animation
            if !heroNode.landed{
                //squashAndStretch(xScale: 1.3, yScale: 0.7)
                heroNode.physicsBody?.velocity = CGVector(dx: heroNode.physicsBody!.velocity.dx, dy: 0)
                heroNode.landed = true
            }
            //jump action
            if heroNode.jump{
                heroNode.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: heroNode.maxJump))
                heroNode.grounded = false
                //squashAndStretch(xScale: 0.7, yScale: 1.3)
            }
        }
        
        if !heroNode.grounded{
            //falling
            if heroNode.physicsBody?.velocity.dy ?? 0 < 0{
                heroNode.jump = false
            }
            //jump speed up?
            if heroNode.physicsBody?.velocity.dy ?? 0 > 0 && !heroNode.jump{
                heroNode.physicsBody?.velocity.dy *= 0.5
            }
            heroNode.landed = false
        }
        
        if !heroNode.dead{
            if heroNode.aiming{
                heroNode.stateMachine?.enter(HeroAimState.self)
            }
        }
        else{
            heroNode.stateMachine?.enter(HeroDeadState.self)
        }
        
        heroNode.weaponNode?.cancelAiming()
        heroNode.xScale = approach(start: heroNode.xScale, end: heroNode.facing, shift: 0.05)
        heroNode.yScale = approach(start: heroNode.yScale, end: 1, shift: 0.05)
        heroNode.position.x = heroNode.position.x + heroNode.hSpeed
    }
    
    ///shift is apporach step long
    func approach(start:CGFloat,end:CGFloat,shift:CGFloat) -> CGFloat{
        if start < end{
            return min(start+shift,end)
        }
        else{
            return max(start-shift,end)
        }
    }
    
    ///放缩精灵 调用这个方法 而不是直接设置Scale 这样会自动处理转向问题
    func squashAndStretch(xScale:CGFloat,yScale:CGFloat){
        heroNode.xScale = xScale * heroNode.facing
        heroNode.yScale = yScale
    }
    
}
