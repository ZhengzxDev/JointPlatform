//
//  BackLayerMoveComponent.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/29.
//
import GameplayKit
import SpriteKit

class BackLayerMoveComponent:GKComponent{
    
    var layers:[Int:SKNode] = [:]
    
    var layerDelta:[Int:Double] = [:]
    
    var offsets:[Int:CGVector] = [:]
    
    var cameraNode:SKCameraNode?
    
    var lastOffset:CGPoint = .zero
    
    func setCamera(_ camera:SKCameraNode){
        self.cameraNode = camera
    }
    
    func addLayer(node:SKNode,idx:Int,offset:CGVector,moveDelta:Double){
        self.layers[idx] = node
        self.offsets[idx] = offset
        self.layerDelta[idx] = moveDelta
    }

    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard self.cameraNode != nil && layers.count > 0 else { return }
        
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
        
        for i in 0 ..< self.layers.count{
            
            let layerX = cameraNode!.position.x - layerDelta[i]! * cameraOffset.x
            
            layers[i]!.position = CGPoint(x: layerX, y: layers[i]!.position.y)
            
            //layers[i]!.position = cameraNode!.position.offsetBy(dx: -layerDelta[i]! * cameraOffset.x + offsets[i]!.dx, dy:0)
        }
        
        lastOffset = cameraOffset
        
    }
    
    override class var supportsSecureCoding: Bool{
        return true
    }
}

