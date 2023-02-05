//
//  DamageLabelNode.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/21.
//

import SpriteKit
import GameplayKit

class DamageLabelNode:SKSpriteNode{
    
    private let moveDeltaY:Double = 15
    private let moveDuration:TimeInterval = 1
    
    private var text:String?
    
    private var innerSpace:CGFloat = -2
    
    private var alphabetSize:CGSize = CGSize(width: 10, height: 20)
    
    private var textColor:UIColor = .white
    
    private var alphabetSetPrefix:String = "damage_alphabet_"
    
    
    func setAlphabetSetPrefix(_ str:String){
        self.alphabetSetPrefix = str
    }
    
    func setText(_ str:String){
        self.text = str
    }
    
    func setAlphabetSize(_ size:CGSize){
        
        self.alphabetSize = size
    }
    
    func setAlphabetSpace(_ value:CGFloat){
        self.innerSpace = value
    }
    
    func setTextColor(_ color:UIColor){
        self.textColor = color
    }
    
    func display(){
        
        
        guard self.text != nil else { return }
        
        for (idx,c) in text!.uppercased().enumerated(){
            var imageName = ""
            if c == "/"{
                imageName = alphabetSetPrefix+"sep"
            }
            else{
                imageName = alphabetSetPrefix + "\(c)"
            }
            
            let charNode = SKSpriteNode(imageNamed: imageName)
            charNode.size = self.alphabetSize
            
            var imageOrigin = CGPoint.zero
            
            if idx != 0{
                imageOrigin = CGPoint(x: CGFloat(idx)*alphabetSize.width + CGFloat(idx)*innerSpace, y: 0.0)
            }
            
            charNode.position = imageOrigin
            self.addChild(charNode)
        }
        
        self.zPosition = zPositionConfig.GUI.rawValue

        self.alpha = 0
        self.setScale(0)
        self.run(.sequence([
            .group([
                .scale(to: 1.2, duration: 0.2),
                .fadeAlpha(to: 1, duration: 0.2),]),
            .scale(to: 1, duration: 0.2),
            .moveBy(x: 0, y: moveDeltaY, duration: 1),
            .fadeOut(withDuration: 0.5),
            .removeFromParent()
        ])
        )
        

        
    }
    
    
}
