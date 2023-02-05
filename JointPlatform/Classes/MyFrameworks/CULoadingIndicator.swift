//
//  CULoadingIndicator.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/10/9.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

class CULoadingIndicator: UIView {
    
    public var isAnimPlaying:Bool{
        get{
            return self.isPlaying
        }
    }
    
    private var strokeLength:CGFloat = 0.8
    private var strokeWidth:CGFloat = 4
    private var strokeColor:UIColor = UIColor(white: 0.8, alpha: 1)
    private var containerSize:CGSize = CGSize(width: 40, height: 40)
    private var fadeColorEnabled:Bool = true
    
    private var isPlaying:Bool = false
    
    private let circlePath:UIBezierPath = UIBezierPath()
    //进度条
    private let progressLayer = CAShapeLayer()
    private let shapeLayer = CAShapeLayer()

    private let leftColorLayer:CAGradientLayer = CAGradientLayer()
    private let rightColorLayer:CAGradientLayer = CAGradientLayer()
    
    override var tintColor: UIColor!{
        didSet{
            setStroke(color: tintColor)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        //获取整个进度条圆圈路径
        super.draw(rect)
        update(rect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
}


extension CULoadingIndicator{
    
    public func play(){
        guard isPlaying == false else { return }
        
        
        isPlaying = true
        let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnim.fromValue = 0
        rotationAnim.toValue = Double.pi * 2
        rotationAnim.duration = 0.8
        rotationAnim.repeatCount = Float.greatestFiniteMagnitude
        rotationAnim.autoreverses = false
        rotationAnim.fillMode = .forwards
        rotationAnim.isRemovedOnCompletion = false
        if self.layer.animation(forKey: "rotationAnim") == nil {
            self.layer.add(rotationAnim, forKey: "rotationAnim")
        }
    }
    
    public func pause(){
        guard isPlaying == true else { return }
        self.layer.removeAllAnimations()
        isPlaying = false
    }
    
    
    public func update(_ rect:CGRect){
        
        if layer.sublayers != nil{
            for layer in self.layer.sublayers!{
                layer.removeFromSuperlayer()
            }
        }
        shapeLayer.frame = rect
        self.layer.addSublayer(shapeLayer)
        
        if fadeColorEnabled{
            let layerWidth = containerSize.width/2
            let originPoint = CGPoint(x: (rect.width-containerSize.width)/2, y: (rect.height-containerSize.height)/2)
            
            leftColorLayer.frame = CGRect(origin: originPoint, size: CGSize(width: layerWidth, height: containerSize.height))
            leftColorLayer.colors = [strokeColor.withAlphaComponent(1).cgColor,strokeColor.withAlphaComponent(0.35).cgColor]
            leftColorLayer.startPoint = CGPoint(x: 0.5, y: 0)
            leftColorLayer.endPoint = CGPoint(x: 0.5, y: 1)
            shapeLayer.addSublayer(leftColorLayer)
            
            rightColorLayer.frame = CGRect(origin: CGPoint(x: originPoint.x+layerWidth, y: originPoint.y), size: CGSize(width: layerWidth, height: containerSize.height))
            rightColorLayer.colors = [strokeColor.withAlphaComponent(0.52).cgColor,strokeColor.withAlphaComponent(0).cgColor]
            //rightColorLayer.locations = [0,0.75,0]
            rightColorLayer.startPoint = CGPoint(x: 0.5, y: 1)
            rightColorLayer.endPoint = CGPoint(x: 0.5, y: 0)
            shapeLayer.addSublayer(rightColorLayer)
            self.layer.backgroundColor = UIColor.clear.cgColor
        }
        else{
            self.layer.backgroundColor = strokeColor.cgColor
        }
        
        
        if circlePath.isEmpty{
            
            circlePath.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                              radius: max(containerSize.width/2 - strokeWidth,1),
            startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
        }
         
        //绘制进度条
        progressLayer.frame = rect
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.lineWidth = strokeWidth
        progressLayer.path = circlePath.cgPath
        progressLayer.strokeStart = 0.1
        progressLayer.strokeEnd = self.strokeLength - 0.1
        progressLayer.lineCap = .round
        progressLayer.lineJoin = .round
        
        layer.mask = progressLayer
    }
    
    
    public func setSizeRect(_ value:CGFloat){
        self.containerSize = CGSize(width: value, height: value)
    }
    
    public func setSize(_ size:CGSize){
        self.containerSize = size
    }
    
    public func setStroke(width:CGFloat){
        self.strokeWidth = width
    }
    
    public func setStroke(color:UIColor){
        self.strokeColor = color
    }
    
    public func setFadeColor(_ value:Bool){
        self.fadeColorEnabled = value
    }
    
    public func setStroke(length:CGFloat){
        var value = min(length,1)
        value = max(0,length)
        self.strokeLength = value
    }
    
    
    //将角度转为弧度
    fileprivate func angleToRadian(_ angle: Double)->CGFloat {
        return CGFloat(angle/Double(180.0) * Double.pi)
    }

}
