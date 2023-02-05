//
//  PixelTextLabel.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/29.
//

import UIKit

class PixelTextLabel:UIView{
    
    enum TextVerticalAligment:Int{
        case Top
        case Middle
        case Bottom
    }
    
    private var horizontalAligment:NSTextAlignment = .left
    
    private var verticalAligment:TextVerticalAligment = .Top
    
    private var textImageViews:[UIImageView] = []
    
    private var text:String?
    
    private var innerSpace:CGFloat = 2
    
    private var alphabetSize:CGSize = CGSize(width: 20, height: 40)
    
    private var textColor:UIColor = .white
    
    private var alphabetSetPrefix:String = "gui_alphabet_"
    
    private var lastDrawText:String?
    
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
    
    func setAligment( vertical:TextVerticalAligment,horizontal:NSTextAlignment){
        self.verticalAligment = vertical
        self.horizontalAligment = horizontal
    }
    
    func drawText(){
        
        var alphaOrigin:CGPoint = CGPoint.zero
        switch self.verticalAligment{
        case .Top:
            alphaOrigin = CGPoint(x: 0, y: 0)
        case .Middle:
            alphaOrigin = CGPoint(x: 0, y: (self.frame.height-self.alphabetSize.height)/2)
        case .Bottom:
            alphaOrigin = CGPoint(x: 0, y: self.frame.height-self.alphabetSize.height)
        }
        
        switch self.horizontalAligment{
        case .left:
            alphaOrigin.x = 0
        case .right:
            let textWidth = CGFloat(text!.count) * alphabetSize.width + CGFloat(text!.count-1)*innerSpace
            alphaOrigin.x = self.frame.width - textWidth
        case .center:
            let textWidth = CGFloat(text!.count) * alphabetSize.width + CGFloat(text!.count-1)*innerSpace
            alphaOrigin.x = (self.frame.width - textWidth)/2
        default:
            alphaOrigin.x = 0
        }
        
        if text?.count == lastDrawText?.count && text != nil {
            //modify

            for (idx,view) in textImageViews.enumerated() {
                let cIndex = text!.index(text!.startIndex, offsetBy: idx)
                let c = text![cIndex]
                var imageName = ""
                if c == "/"{
                    imageName = alphabetSetPrefix+"sep"
                }
                else{
                    imageName = alphabetSetPrefix + "\(c)"
                }
                var imageOrigin = alphaOrigin
                if idx != 0{
                    imageOrigin.x = CGFloat(idx)*alphabetSize.width + CGFloat(idx)*innerSpace + imageOrigin.x
                }
                view.tintColor = textColor
                view.contentMode = .scaleAspectFill
                view.frame.origin = imageOrigin
                view.frame.size = alphabetSize
                view.image = UIImage(named: imageName)
            }
        }
        else{
            //add
            let _ = self.textImageViews.map{
                $0.removeFromSuperview()
            }
            
            self.textImageViews = []
            
            guard text != nil else { return }
            
            for (idx,c) in text!.uppercased().enumerated(){
                
                var imageName = ""
                if c == "/"{
                    imageName = alphabetSetPrefix+"sep"
                }
                else{
                    imageName = alphabetSetPrefix + "\(c)"
                }
                
                let imageView = UIImageView(image: UIImage(named: imageName))
                
                var imageOrigin = alphaOrigin
                
                if idx != 0{
                    imageOrigin.x = CGFloat(idx)*alphabetSize.width + CGFloat(idx)*innerSpace + imageOrigin.x
                }
                imageView.tintColor = textColor
                imageView.contentMode = .scaleAspectFill
                imageView.frame.origin = imageOrigin
                imageView.frame.size = alphabetSize
                self.textImageViews.append(imageView)
                self.addSubview(imageView)
            }
        }
        
        lastDrawText = self.text
        
    }
    
    func estimateSize() -> CGSize{
        return .zero
    }
    
}
