//
//  BackgroundControlComponent.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/29.
//

import GameplayKit
import SpriteKit

class BackgroundControlComponent:GKComponent{
    
    
    var layers:[Int:SKNode] = [:]
    
    var layerDelta:[Int:Double] = [:]
    
    var offsets:[Int:CGVector] = [:]
    
    var cameraNode:SKCameraNode?
    
    var lastOffset:CGPoint = .zero
    
    override func didAddToEntity() {
        super.didAddToEntity()
        
        
        
        /*if let node = self.entity?.component(ofType: GKSKNodeComponent.self)?.node{
            
            let delta:Double = 1.0/(Double(node.children.count) - 1.0)
            
            
            
            for idx in 0 ..< node.children.count{
                layers.append(node.childNode(withName: "layer_\(idx)")!)
                layerDelta[idx] = delta * Double(idx)
            }
        }*/
        
        
    }
    
    func setCamera(_ camera:SKCameraNode){
        self.cameraNode = camera
    }
    
    func addLayer(node:SKNode,idx:Int,offset:CGVector){
        self.layers[idx] = node
        self.offsets[idx] = offset
        
    }
    
    func calcParameters(){
        let delta:Double = 1.0/(Double(layers.values.count) - 1.0)
        for idx in 0 ..< layers.values.count{
            layerDelta[idx] = delta * Double(idx)
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        /*guard self.cameraNode != nil && layers.count > 0 else { return }
        
        let cameraOffset = cameraNode!.position
        
        /*var fixdOffset:CGPoint = .zero
        
        if cameraOffset.x < -maxOffset.x{
            fixdOffset.x = -maxOffset.x
        }
        else if cameraOffset.x > maxOffset.x{
            fixdOffset.x = maxOffset.x
        }
        
        if cameraOffset.y < -maxOffset.y{
            fixdOffset.y = -maxOffset.y
        }
        else if cameraOffset.y > maxOffset.y{
            fixdOffset.y = maxOffset.y
        }*/
        
        guard cameraOffset != lastOffset else { return }
        
        for i in (0 ... self.layers.count-1).reversed(){
            layers[i]!.position = cameraNode!.position.offsetBy(dx: -layerDelta[self.layers.count-1-i]! * cameraOffset.x + offsets[i]!.dx, dy: -layerDelta[self.layers.count-1-i]! * cameraOffset.y + offsets[i]!.dy)
        }
        
        lastOffset = cameraOffset*/
        
    }
    
    override class var supportsSecureCoding: Bool{
        return true
    }
}
