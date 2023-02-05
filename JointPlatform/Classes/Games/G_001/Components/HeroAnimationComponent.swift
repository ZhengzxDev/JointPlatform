//
//  HeroAnimationComponent.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/19.
//

import SpriteKit
import GameplayKit

class HeroAnimationComponent:GKComponent{
    
    
    var heroNode:HeroCharacterNode?
    
    var idleAction:SKAction?
    var walkAction:SKAction?
    var jumpAction:SKAction?
    var walkBackAction:SKAction?
    var deadAction:SKAction?
    
    
    func loadActions(with heroNode:HeroCharacterNode){
        let heroKey = heroNode.heroType.rawValue
        self.heroNode = heroNode
        idleAction = SKAction.init(named: heroKey+"_idle")
        walkAction = SKAction.init(named: heroKey+"_walk")
        jumpAction = SKAction.init(named: heroKey+"_jump")
        walkBackAction = SKAction.init(named: heroKey+"_walk_back")
        deadAction = SKAction.init(named: heroKey+"_dead")
    }
    
    
    override func update(deltaTime seconds: TimeInterval) {
        guard heroNode != nil else { return }
        
        if heroNode!.stateMachine?.currentState is HeroNormalState{
            if heroNode!.grounded{
                if heroNode!.left || heroNode!.right{
                    if heroNode?.action(forKey: "walk") == nil{
                        heroNode?.removeAllActions()
                        heroNode?.run(walkAction!,withKey: "walk")
                    }
                }
                else{
                    if heroNode!.action(forKey: "idle") == nil{
                        heroNode?.removeAllActions()
                        heroNode?.run(idleAction!,withKey: "idle")
                    }
                }
            }
            else{
                if heroNode!.action(forKey: "jump") == nil{
                    heroNode?.removeAllActions()
                    heroNode?.run(jumpAction!,withKey: "jump")
                }
            }
        }
        else if heroNode!.stateMachine?.currentState is HeroAimState{
            if heroNode!.grounded{
                if heroNode!.left || heroNode!.right{
                    
                    if heroNode!.left && heroNode!.aimDirection.dx < 0{
                        //walk and aim in same direction
                        if heroNode?.action(forKey: "walk") == nil{
                            heroNode?.removeAllActions()
                            heroNode?.run(walkAction!,withKey: "walk")
                        }
                    }
                    else if heroNode!.left && heroNode!.aimDirection.dx > 0{
                        //walk and aim in differ direction
                        if heroNode?.action(forKey: "walkBack") == nil{
                            heroNode?.removeAllActions()
                            heroNode?.run(walkBackAction!,withKey: "walkBack")
                        }
                    }
                    else if heroNode!.right && heroNode!.aimDirection.dx < 0{
                        //walk and aim in differ direction
                        if heroNode?.action(forKey: "walkBack") == nil{
                            heroNode?.removeAllActions()
                            heroNode?.run(walkBackAction!,withKey: "walkBack")
                        }
                    }
                    else if heroNode!.right && heroNode!.aimDirection.dx > 0{
                        //walk and aim in same direction
                        if heroNode?.action(forKey: "walk") == nil{
                            heroNode?.removeAllActions()
                            heroNode?.run(walkAction!,withKey: "walk")
                        }
                    }
                    
                }
                else{
                    if heroNode!.action(forKey: "idle") == nil{
                        heroNode?.removeAllActions()
                        heroNode?.run(idleAction!,withKey: "idle")
                    }
                }
            }
            else{
                if heroNode!.action(forKey: "jump") == nil{
                    heroNode?.removeAllActions()
                    heroNode?.run(jumpAction!,withKey: "jump")
                }
            }
        }
        else if heroNode?.stateMachine?.currentState is HeroDeadState{
            if heroNode!.action(forKey: "dead") == nil{
                heroNode?.removeAllActions()
                heroNode?.run(deadAction!,withKey: "dead")
            }
        }
    }
    
}
