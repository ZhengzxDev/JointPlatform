//
//  PhysicDetection.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/14.
//

import SpriteKit
import GameplayKit

struct ColliderType{
    static let Player:UInt32 = 0x1
    static let Ground:UInt32 = 0x1 << 1
    static let Bullet:UInt32 = 0x1 << 2
    static let MapBounds:UInt32 = 0x1 << 3
    static let Enemy:UInt32 = 0x1 << 4
    static let GroundDetector:UInt32 = 0x1 << 5
    static let Weapon:UInt32 = 0x1 << 6
    static let ColdSteel:UInt32 = 0x1 << 7
    static let MassInjury:UInt32 = 0x1 << 8
    static let DeliverBox:UInt32 = 0x1 << 9
}

class PhysicDetection:NSObject,SKPhysicsContactDelegate{
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == ColliderType.GroundDetector | ColliderType.Ground{
            if let hero = contact.bodyA.node?.parent as? HeroCharacterNode{
                hero.grounded = true
            }
            else if let hero = contact.bodyB.node?.parent as? HeroCharacterNode{
                hero.grounded = true
            }
        }
        else if collision == ColliderType.Bullet | ColliderType.MapBounds {
            if let bullet = contact.bodyA.node as? BaseBulletNode{
                bullet.onHitGround()
            }
            else if let bullet = contact.bodyB.node as? BaseBulletNode{
                bullet.onHitGround()
            }
        }
        else if collision == ColliderType.Bullet | ColliderType.Ground{
            if let bullet = contact.bodyA.node as? BaseBulletNode{
                bullet.onHitGround()
            }
            else if let bullet = contact.bodyB.node as? BaseBulletNode{
                bullet.onHitGround()
            }
        }
        else if collision == ColliderType.Bullet | ColliderType.Enemy{
            
            if let bulletNode = contact.bodyA.node as? BaseBulletNode{
                bulletNode.onHitEmeny(contact.bodyB.node)
            }
            else if let bulletNode = contact.bodyB.node as? BaseBulletNode{
                bulletNode.onHitEmeny(contact.bodyA.node)
            }
            
        }
        else if collision == ColliderType.Bullet | ColliderType.Player{
            
            if let bulletNode = contact.bodyA.node as? BaseBulletNode{
                if let heroNode = contact.bodyB.node as? HeroCharacterNode{
                    if heroNode != bulletNode.shooter{
                        bulletNode.onHitPlayer(heroNode)
                    }
                }
            }
            else if let bulletNode = contact.bodyB.node as? BaseBulletNode{
                if let heroNode = contact.bodyA.node as? HeroCharacterNode{
                    if heroNode != bulletNode.shooter{
                        bulletNode.onHitPlayer(heroNode)
                    }
                }
                
            }
            
        }
        else if collision == ColliderType.ColdSteel | ColliderType.Enemy{
            if let coldSteelNode = contact.bodyA.node as? BaseBladeNode{
                coldSteelNode.onHitTarget(contact.bodyB.node)
            }
            else if let coldSteelNode = contact.bodyB.node as? BaseBladeNode{
                coldSteelNode.onHitTarget(contact.bodyA.node)
            }
        }
        else if collision == ColliderType.ColdSteel | ColliderType.Player{
            
            if let coldSteelNode = contact.bodyA.node as? BaseBladeNode{
                coldSteelNode.onHitTarget(contact.bodyB.node)
            }
            else if let coldSteelNode = contact.bodyB.node as? BaseBladeNode{
                coldSteelNode.onHitTarget(contact.bodyA.node)
            }

        }
        else if collision == ColliderType.Player | ColliderType.Weapon{
            if let weapon = contact.bodyA.node as? PickableWeaponNode{
                if let hero = contact.bodyB.node as? HeroCharacterNode{
                    hero.contactWeaponNode = weapon
                    weapon.onContactWith(hero)
                }
            }
            else if let weapon = contact.bodyB.node as? PickableWeaponNode{
                if let hero = contact.bodyA.node as? HeroCharacterNode{
                    hero.contactWeaponNode = weapon
                    weapon.onContactWith(hero)
                }
            }
        }
        else if collision == ColliderType.MassInjury | ColliderType.Enemy{
            
            if let massInjuryNode = contact.bodyA.node as? MassInjuryNode{
                massInjuryNode.onHitWith(contact.bodyB.node)
            }
            else if let massInjuryNode = contact.bodyB.node as? MassInjuryNode{
                massInjuryNode.onHitWith(contact.bodyA.node)
            }
        }
        else if collision == ColliderType.MassInjury | ColliderType.Player{
            
            if let massInjuryNode = contact.bodyA.node as? MassInjuryNode{
                if let node = contact.bodyB.node{
                    massInjuryNode.onHitWith(node)
                }
                
            }
            else if let massInjuryNode = contact.bodyB.node as? MassInjuryNode{
                if let node = contact.bodyA.node{
                    massInjuryNode.onHitWith(node)
                }
            }
        }
        else if collision == ColliderType.Bullet | ColliderType.DeliverBox{
            
            if let bulletNode = contact.bodyA.node as? BaseBulletNode{
                if let boxNode = contact.bodyB.node as? StuffDeliverBoxNode{
                    bulletNode.onHitEmeny(boxNode)
                }
            }
            else if let bulletNode = contact.bodyB.node as? BaseBulletNode{
                if let boxNode = contact.bodyA.node as? StuffDeliverBoxNode{
                    bulletNode.onHitEmeny(boxNode)
                }
                
            }
        }
        else if collision == ColliderType.ColdSteel | ColliderType.DeliverBox{
            
            if let bladeNode = contact.bodyA.node as? BaseBladeNode{
                if let boxNode = contact.bodyB.node as? StuffDeliverBoxNode{
                    bladeNode.onHitTarget(boxNode)
                }
            }
            else if let bladeNode = contact.bodyB.node as? BaseBladeNode{
                if let boxNode = contact.bodyA.node as? StuffDeliverBoxNode{
                    bladeNode.onHitTarget(boxNode)
                }
            }
        }
        else if collision == ColliderType.MassInjury | ColliderType.DeliverBox{
            
            if let massInjuryNode = contact.bodyA.node as? MassInjuryNode{
                if let boxNode = contact.bodyB.node as? StuffDeliverBoxNode{
                    massInjuryNode.onHitWith(boxNode)
                }
            }
            else if let massInjuryNode = contact.bodyB.node as? MassInjuryNode{
                if let boxNode = contact.bodyA.node as? StuffDeliverBoxNode{
                    massInjuryNode.onHitWith(boxNode)
                }
            }
        }
    }
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == ColliderType.Player | ColliderType.Weapon{
            if let weapon = contact.bodyA.node as? PickableWeaponNode{
                if let hero = contact.bodyB.node as? HeroCharacterNode{
                    hero.contactWeaponNode = nil
                    weapon.onContactEndWith(hero)
                }
            }
            else if let weapon = contact.bodyB.node as? PickableWeaponNode{
                if let hero = contact.bodyA.node as? HeroCharacterNode{
                    hero.contactWeaponNode = nil
                    weapon.onContactEndWith(hero)
                }
            }
        }
    }
}
