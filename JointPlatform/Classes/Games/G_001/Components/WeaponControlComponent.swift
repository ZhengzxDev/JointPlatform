//
//  WeaponControlComponent.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/20.
//

import SpriteKit
import GameplayKit

class WeaponControlComponent:GKComponent{
    
    var weaponNode:HeroWeaponNode?
    var heroNode:HeroCharacterNode?
    

    
    override func didAddToEntity() {
        super.didAddToEntity()
        if let nodeComponent = self.entity?.component(ofType: GKSKNodeComponent.self){
            weaponNode = nodeComponent.node as? HeroWeaponNode
            if let heroNode = weaponNode?.parent as? HeroCharacterNode{
                self.heroNode = heroNode
            }
        }
        
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
        guard heroNode != nil && weaponNode != nil else { return }
        
        guard !heroNode!.dead else { return }
        
        if heroNode!.aiming{
            let ratio = Double(heroNode!.aimDirection.dy/heroNode!.aimDirection.dx)
            let radian:Double = atan(ratio)
            if ratio == Double.infinity || ratio == -Double.infinity{
                weaponNode?.aimedBy(heroNode!, radian: radian)
            }
            else{
                weaponNode?.aimedBy(heroNode!, radian: heroNode!.facing*radian)
            }
            
            if !weaponNode!.reloading{
                if !weaponNode!.cooling{
                    if weaponNode!.info.clipRemain > 0 || weaponNode!.info.clipCapcacity == -1 {
                        //fire
                        
                        weaponNode?.shouldFiredBy(heroNode!, radian: radian)
                        
                        if weaponNode!.info.clipCapcacity != -1{
                            weaponNode?.info.clipRemain -= 1
                        }
                        
                        if weaponNode!.info.clipRemain == 0 {
                            
                            if weaponNode!.info.hideWhenNoBullet{
                                weaponNode?.alpha = 0
                            }
                            
                            if weaponNode!.info.spareClipRemian != 0{
                                //reload
                                weaponNode?.reloading = true
                                weaponNode?.reloadingRemain = weaponNode!.info.reloadInterval
                                weaponNode?.reloadWith(heroNode!, progress: 1-weaponNode!.reloadingRemain/weaponNode!.info.reloadInterval)
                            }
                            
                            
                        }
                        else{
                            weaponNode?.cooling = true
                            weaponNode?.coolingRemain = weaponNode!.info.shootInterval
                            
                        }
                        
                        weaponNode?.didFiredBy(heroNode!)
                    }
                    else{
                        if weaponNode?.info.spareClipRemian == 0{
                            //words display cooling
                            weaponNode?.cooling = true
                            weaponNode?.coolingRemain = weaponNode!.info.shootInterval
                            heroNode?.indicate("无弹药")
                        }
                        else{
                            //reload
                            weaponNode?.reloading = true
                            weaponNode?.reloadingRemain = weaponNode!.info.reloadInterval
                            weaponNode?.reloadWith(heroNode!, progress: 1-weaponNode!.reloadingRemain/weaponNode!.info.reloadInterval)
                        }
                        
                    }

                }
                else{
                    weaponNode?.coolingRemain -= seconds
                    if weaponNode!.coolingRemain <= 0{
                        weaponNode?.cooling = false
                        weaponNode?.coolingRemain = 0
                    }
                }
            }

        }
        
        if weaponNode!.reloading{
            weaponNode?.reloadingRemain -= seconds
            weaponNode?.reloadWith(heroNode!, progress: 1-weaponNode!.reloadingRemain/weaponNode!.info.reloadInterval)
            if weaponNode!.reloadingRemain <= 0{
                //reload complete
                if weaponNode!.info.hideWhenNoBullet{
                    weaponNode?.alpha = 1
                }
                weaponNode?.reloading = false
                
                if weaponNode!.info.spareClipRemian > weaponNode!.info.clipCapcacity{
                    weaponNode?.info.spareClipRemian -= weaponNode!.info.clipCapcacity
                }
                else{
                    if weaponNode!.info.spareClipRemian != -1{
                        weaponNode!.info.spareClipRemian = 0
                    }
                }
                
                weaponNode?.reloadingRemain = 0
                weaponNode?.info.clipRemain = weaponNode!.info.clipCapcacity
                weaponNode?.reloadDidComplete(heroNode!)
            }
        }
        
        
        weaponNode!.position = approach(from: weaponNode!.position, to: weaponNode!.weaponInitPosition, shift: 0.2)
        
    }
    
    func approach(from:CGPoint,to:CGPoint,shift:CGFloat)->CGPoint{
        return CGPoint(x: approach(start: from.x, end: to.x, shift: shift), y: approach(start: from.y, end: to.y, shift: shift))
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
}
