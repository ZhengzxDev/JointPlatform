//
//  CUButton.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/5/4.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit
@IBDesignable
class CUButton: UIButton {

    @objc public enum TextImgLayout:Int{
        case LeftRight = 0
        case RightLeft = 1
        case UpBottom = 2
        case BottomUp = 3
    }
    @IBInspectable public var imageSize:CGSize = CGSize(width: 35, height: 35)
    public var textImgLayout:TextImgLayout = .RightLeft
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.text = nil

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.titleLabel?.text = nil

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if titleLabel == nil || titleLabel?.text == nil || titleLabel?.text == "" || titleLabel?.text == "Button" {
            if let imageView = imageView {
                imageView.frame.size = self.imageSize
                imageView.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
            }
            
        }
        else if imageView == nil || imageView?.image == nil{
            titleLabel?.sizeToFit()
            titleLabel?.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        }
        else{
            guard let label = titleLabel,let imageView = imageView else { return }
            label.sizeToFit()
            imageView.frame.size = self.imageSize
            let containerWidth = min(self.bounds.width,self.imageSize.width + label.bounds.width)
            let containerHeight = min(self.bounds.height,self.imageSize.height + label.bounds.height)
            var startX:CGFloat = 0
            var startY:CGFloat = 0
            switch textImgLayout {
            case .RightLeft:

                startX = 0
                switch self.contentHorizontalAlignment {
                case .center:
                    startX = (self.bounds.width - containerWidth) / 2
                case .left:
                    startX = 0
                case .right:
                    startX = self.bounds.width - containerWidth
                default:
                    startX = (self.bounds.width - containerWidth) / 2
                }
                
                imageView.center = CGPoint(x: startX + imageSize.width/2, y: self.bounds.height/2)

                label.frame.origin = CGPoint(x: imageView.frame.maxX, y: (self.frame.height - label.frame.height)/2)
                
                label.frame.size = CGSize(width: self.frame.width - imageView.frame.maxX, height: label.frame.height)
            case .BottomUp:
                
                startY = (self.frame.height - containerHeight)/2
                
                startX = 0
                
                switch self.contentHorizontalAlignment {
                case .center:
                    startX = (self.bounds.width - containerWidth) / 2
                    label.textAlignment = .center
                    break
                default:
                    break
                }
                let xImageOffset = (containerWidth - imageSize.width)/2
                let xLabelOffset = (containerWidth - label.bounds.width)/2
                imageView.frame.origin = CGPoint(x: startX+xImageOffset, y: startY)
                label.frame.origin = CGPoint(x: startX+xLabelOffset, y: imageView.frame.maxY)
                break
            case .LeftRight:
                var endX:CGFloat = 0
                switch self.contentHorizontalAlignment {
                case .center:
                    endX = (self.bounds.width + containerWidth)/2
                case .left:
                    endX = self.bounds.width - containerWidth
                case .right:
                    endX = self.bounds.width
                default:
                    endX = (self.bounds.width + containerWidth)/2
                }
                
                imageView.center = CGPoint(x: endX - imageSize.width/2, y: self.bounds.height/2)
                label.frame.size = CGSize(width: containerWidth - imageView.frame.width, height: label.frame.height)
                label.frame.origin = CGPoint(x: imageView.frame.minX - label.frame.width, y: (self.frame.height - label.frame.height)/2)
                
                break
            default:
                return
            }
            addInsets(p: &imageView.center, insets: self.contentEdgeInsets)
            addInsets(p: &label.center, insets: self.contentEdgeInsets)
            addInsets(p: &imageView.center, insets: self.imageEdgeInsets)
            addInsets(p: &label.center, insets: self.titleEdgeInsets)
        }
        
        
        
    }
    
    
    private func addInsets(p:inout CGPoint,insets:UIEdgeInsets){
        p.x += insets.left
        p.x -= insets.right
        p.y += insets.top
        p.y -= insets.bottom
    }
    
    

}
