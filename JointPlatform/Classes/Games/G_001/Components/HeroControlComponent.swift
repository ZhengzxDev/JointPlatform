//
//  HeroControlComponent.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/14.
//

import SpriteKit
import GameplayKit


protocol HeroConrollable:NSObjectProtocol{
    func follow(_ userData:[String:Any])
}


///挂载在对应HeroSprite上的用于控制的Component
class HeroControlComponent:GKComponent,HeroConrollable{
    
    var heroNode:HeroCharacterNode?
    
    var tmp:Int = 0
    
    func initComponent(_ scene:SKScene){
        print("control component init")
        if heroNode == nil{
            //self.entity means the object[GKEntity] that this component attached to.
            //in gameplaykit spriteKitNode is viewed as a component attached to entity.
            //and this type of component is called GKSKNodeComponent
            if let nodeComponent = self.entity?.component(ofType: GKSKNodeComponent.self){
                heroNode = nodeComponent.node as? HeroCharacterNode
            }
        }
    }
    
    //use this method to change the stored action properties in hero node
    func follow(_ userData:[String:Any]) {
        guard heroNode != nil else { return }
        
        guard let comTag = userData["comTag"] as? Int else { return }
        guard let actionType = userData["type"] as? String else { return }
        //print("command : tag:\(comTag)   \(vector)")
        switch actionType{
        case "knob":
            guard let vector = userData["vector"] as? CGVector else { return }
            guard let offsetDegree = userData["degree"] as? CGFloat else { return }
            //left knob
            if comTag == 0{
                if vector.dx < 0 {
                    heroNode?.left = true
                    heroNode?.right = false
                    /*if vector.dy > 0.70 && offsetDegree > 0.90{
                        heroNode?.jump = true
                    }
                    else{
                        heroNode?.jump = false
                    }*/
                }
                else if vector.dx > 0{
                    heroNode?.left = false
                    heroNode?.right = true
                    /*if vector.dy > 0.70 && offsetDegree > 0.90{
                        heroNode?.jump = true
                    }
                    else{
                        heroNode?.jump = false
                    }*/
                }
                else if vector.dx == 0{
                    heroNode?.left = false
                    heroNode?.right = false
                    /*if vector.dy > 0.70 && offsetDegree > 0.90{
                        heroNode?.jump = true
                    }
                    else{
                        heroNode?.jump = false
                    }*/
                }
            }
            else if comTag == 1{
                //right            knob
                if vector == CGVector.zero{
                    heroNode?.aiming = false
                    heroNode?.aimingForce = 0
                }
                else{
                    heroNode?.aiming = true
                    heroNode?.aimingForce = offsetDegree
                }
                heroNode?.aimDirection = vector
            }
        case "button":
            
            if comTag == 2{
                //switch
                if heroNode?.weapons.count ?? 0 > 0{
                    heroNode?.switchToNextWeapon()
                }
            }
            else if comTag == 3{
                //pick
                if heroNode?.contactWeaponNode != nil{
                    heroNode?.contactWeaponNode?.onPickedBy(heroNode!)
                }
            }
            else if comTag == 4{
                heroNode?.jump = true
            }
            
            

            break
        default:
            break
        }
        
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        heroNode?.stateMachine?.update(deltaTime: seconds)
        heroNode?.fixDetectorPosition()
    }
    
    override class var supportsSecureCoding: Bool{
        return true
    }
    
}
