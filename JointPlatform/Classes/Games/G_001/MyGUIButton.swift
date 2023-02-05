//
//  MyGUIButton.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/25.
//

import SpriteKit


class MyGUINode:SKSpriteNode{
    
    var left:CGFloat{
        get{
            return self.position.x
        }
    }
    
    var right:CGFloat{
        return self.position.x + self.size.width
    }
    
    var top:CGFloat{
        get{
            return self.position.y
        }
    }
    
    var bottom:CGFloat{
        get{
            return self.position.y + self.size.height
        }
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.anchorPoint = CGPoint(x: 0, y: 1)
        self.zPosition = zPositionConfig.GUI.rawValue
    }
    
    convenience init(texture:SKTexture,size:CGSize){
        self.init(texture: texture, color: .clear, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sizeFitScene(heightMultiper:CGFloat) -> CGSize{
        guard let myScene = self.scene else { return .zero }
        
        let myRatio = self.size.width / self.size.height
        let fitHeight = myScene.size.height * heightMultiper
        return CGSize(width: myRatio * fitHeight, height: fitHeight)
    }
    
    func makeLeftEqualTo(_ node:MyGUINode,offset:CGFloat = 0){
        self.position = CGPoint(x: node.position.x + offset, y: self.position.y)
    }
    
    func makeLeftEqualTo(_ value:CGFloat,offset:CGFloat = 0){
        self.position.x = value + offset
    }
    
    func makeLeftEqualToSuperNode(offset:CGFloat = 0){
        guard let parentNode = self.parent as? SKCameraNode else { return }
        guard let parentScene = parentNode.scene else { return }
        self.position = CGPoint(x: -parentScene.size.width/2 + offset, y: self.position.y)
    }
    
    func makeRightEqualTo(_ node:MyGUINode,offset:CGFloat = 0){
        self.position = CGPoint(x: node.right - self.size.width + offset, y: self.position.y)
    }
    
    func makeRightEqualTo(_ value:CGFloat,offset:CGFloat = 0){
        self.position.x = value - self.size.width + offset
    }
    
    func makeRightEqualToSuperNode(offset:CGFloat = 0){
        guard let parentNode = self.parent as? SKCameraNode else { return }
        guard let parentScene = parentNode.scene else { return }
        self.position = CGPoint(x: parentScene.size.width/2 - self.size.width + offset, y: self.position.y)
    }
    
    func makeTopEqualTo(_ node:MyGUINode,offset:CGFloat = 0){
        self.position = CGPoint(x: self.position.x, y: node.position.y + offset)
    }
    
    func makeTopEqualTo(_ value:CGFloat,offset:CGFloat = 0){
        self.position.y = value + offset
    }
    
    func makeTopEqualToSuperNode(offset:CGFloat = 0){
        guard let parentNode = self.parent as? SKCameraNode else { return }
        guard let parentScene = parentNode.scene else { return }
        self.position = CGPoint(x: self.position.x, y: parentScene.size.height/2 + offset)
    }
    
    func makeBottomEqualTo(_ node:MyGUINode,offset:CGFloat = 0){
        
        self.position = CGPoint(x: self.position.x, y: node.bottom - self.size.height + offset)
    }
    
    func makeBottomEqualTo(_ value:CGFloat,offset:CGFloat = 0){
        self.position.x = value - self.size.height + offset
    }
    
    func makeBottomEqualToSuperNode(offset:CGFloat = 0){
        guard let parentNode = self.parent as? SKCameraNode else { return }
        guard let parentScene = parentNode.scene else { return }
        self.position = CGPoint(x: self.position.x, y: -parentScene.size.height/2 + self.size.height + offset)
    }
    
    
}

class MyGUIButton:MyGUINode{
    
    private var actionHandler:(()->Void)?
    
    convenience init(texture:SKTexture,size:CGSize,action: (()->Void)?){
        self.init(texture: texture, color: .clear, size: size)
        self.actionHandler = action
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        actionHandler?()
    }
    
    func dispose(){
        self.actionHandler = nil
    }
    

}
