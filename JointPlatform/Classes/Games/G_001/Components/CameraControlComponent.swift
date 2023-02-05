//
//  CameraControlComponent.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/26.
//

import SpriteKit
import GameplayKit

class CameraControlComponent:GKComponent{
    
    private var targets:[SKNode] = []
    
    private var cameraNode:SKCameraNode?
    
    private var maxZoomInScale:CGFloat = 0.5
    
    private var maxZoomOutScale:CGFloat = 1.5
    
    private var viewportSize:CGSize = .zero
    
    private var zoomInInsets:UIEdgeInsets = UIEdgeInsets(top: 100, left: 250, bottom: 100, right: 250)
    
    private var zoomOutInsets:UIEdgeInsets = UIEdgeInsets(top: 50, left: 200, bottom: 50, right: 200)
    
    ///if smaller than this rect, the zoom in
    private var zoomInThresholdSize:CGSize = CGSize.zero
    
    ///if bigger than this rect, the zoom out
    private var zoomOutThresholdSize:CGSize = CGSize.zero
    
    private var currentScale:CGFloat = 1
    
    private var targetScale:CGFloat = 0
    
    private var scaling:Bool = false
    
    private var baseScene:BaseScene?
    
    private var focusCenter:CGPoint{
        get{
            var calcPoint:CGPoint = .zero
            guard self.targets.count > 0 else { return calcPoint }
            for target in self.targets{
                calcPoint = calcPoint + target.position
            }
            
            return CGPoint(x: calcPoint.x/CGFloat(targets.count), y: calcPoint.y/CGFloat(targets.count))
        }
    }
    
    override func didAddToEntity() {
        self.cameraNode = self.entity?.component(ofType: GKSKNodeComponent.self)?.node as? SKCameraNode
        self.baseScene = self.cameraNode?.scene as? BaseScene
    }
    
    func addTarget(_ node:SKNode){
        self.targets.append(node)
    }
    
    func removeTarget(_ node:SKNode){
        for (idx,n) in self.targets.enumerated(){
            if n.isEqual(to: node){
                self.targets.remove(at: idx)
            }
        }
    }
    
    func removeAllTargets(){
        self.targets.removeAll()
    }
    
    
    func setViewportSize(_ size:CGSize){
        self.viewportSize = size
        self.zoomInThresholdSize = CGSize(width: size.width - self.zoomInInsets.right - self.zoomInInsets.left, height: size.height - self.zoomInInsets.top - self.zoomInInsets.bottom)
        self.zoomOutThresholdSize = CGSize(width: size.width - self.zoomOutInsets.right - self.zoomOutInsets.left, height: size.height - self.zoomOutInsets.top - self.zoomOutInsets.bottom)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard self.cameraNode != nil else { return }
        updateViewPort()
        
    }
    
    private func updateViewPort(){
        var calcFocusPoint:CGPoint = .zero
        var minX:CGFloat = self.viewportSize.width
        var minY:CGFloat = self.viewportSize.height
        var maxX:CGFloat = 0
        var maxY:CGFloat = 0
        //var anyPlayerOutOfBounds:Bool = false
        if self.targets.count > 0{
            for target in self.targets{
                calcFocusPoint = calcFocusPoint + target.position
                
                if let targetScreenPos = baseScene?.positionInCamera(target){
                    if targetScreenPos.x > maxX{
                        maxX = targetScreenPos.x
                    }
                    if targetScreenPos.x < minX{
                        minX = targetScreenPos.x
                    }
                    if targetScreenPos.y > maxY{
                        maxY = targetScreenPos.y
                    }
                    if targetScreenPos.y < minY{
                        minY = targetScreenPos.y
                    }
                    /*if targetScreenPos.x < 0 || targetScreenPos.x > self.viewportSize.width || targetScreenPos.y < 0 || targetScreenPos.y > self.viewportSize.height{
                        anyPlayerOutOfBounds = true
                    }*/
                    
                }
                
            }
            calcFocusPoint = CGPoint(x: calcFocusPoint.x/CGFloat(targets.count), y: calcFocusPoint.y/CGFloat(targets.count))
        }
        if targets.count == 1{
            targetScale = maxZoomInScale
            if !scaling && currentScale != targetScale{
                scaling = true
            }
            
        }
        else if targets.count == 0{
            targetScale = maxZoomOutScale
            if !scaling && currentScale != targetScale{
                scaling = true
            }
        }
        else{
            let targetBoundingRectSize = CGSize(width: abs(maxX - minX), height: abs(maxY - minY))
            if targetBoundingRectSize.width < zoomInThresholdSize.width && targetBoundingRectSize.height < zoomInThresholdSize.height{
                //zoom in
                if !scaling {
                    targetScale = max(targetScale - 0.003,maxZoomInScale)
                    scaling = true
                }
            }
            /*else if anyPlayerOutOfBounds{
                //player out of bounds
                //zoom out
                if !scaling{
                    targetScale = min(targetScale + 0.003 ,maxZoomOutScale)
                    scaling = true
                }
                
            }*/
            else if targetBoundingRectSize.width > zoomOutThresholdSize.width || targetBoundingRectSize.height > zoomOutThresholdSize.height{
                //zoom out
                if !scaling{
                    targetScale = min(targetScale + 0.003 ,maxZoomOutScale)
                    scaling = true
                }
            }
        }
        if currentScale != targetScale{
            currentScale = lerp(start: currentScale, end: targetScale, t: 1)
            self.cameraNode?.setScale(currentScale)
        }
        else{
            scaling = false
        }
        self.cameraNode?.position = lerp(start: self.cameraNode!.position, end: calcFocusPoint, t: 0.1)

    }
    
    private func lerp(start:CGPoint,end:CGPoint,t:CGFloat) -> CGPoint {
        let xOffset = end.x - start.x
        let yOffset = end.y - start.y
        
        if abs(xOffset) < 0.5 && abs(yOffset) < 0.5{
            return end
        }
        
        return CGPoint(x: start.x + xOffset * t, y: start.y + yOffset * t)
    }
    
    private func lerp(start:CGFloat,end:CGFloat,t:CGFloat) -> CGFloat{
        let offset = end - start
        if abs(offset) < 0.0001{
            return end
        }
        return start + t * offset
    }
    
    
    override class var supportsSecureCoding: Bool{
        return true
    }
}
