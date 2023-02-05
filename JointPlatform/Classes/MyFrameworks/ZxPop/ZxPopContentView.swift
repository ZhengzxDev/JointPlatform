//
//  ZxPopContentView.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/14.
//

import UIKit

class ZxPopContentView:UIView{
    
    private var frameView:ZxPopWindowFrameView?
    
    func prepare(){}
    
    func willDisplay(){}
    
    func didDisplay(){}
    
    func willHide(){}
    
    func didHide(){}
    
    func allocFrameView() -> ZxPopWindowFrameView {
        return ZxPopWindowFrameView(contentView: self)
    }
    
    func getFrameView() -> ZxPopWindowFrameView{
        if self.frameView == nil{
            self.frameView = allocFrameView()
        }
        return self.frameView!
    }
    
    func getSize() -> CGSize {
        return .zero
    }
    
}

class ZxPopWindowFrameView:UIView{
    
    public var contentView:ZxPopContentView?
    
    convenience init(contentView:ZxPopContentView){
        self.init(frame: .zero)
        self.contentView = contentView
    }
    
    func setupAppearance(){
        
    }
    
    func layoutContentView(_ contentView:ZxPopContentView){
        self.addSubview(contentView)
    }
    
    
    
    func baseSize() -> CGSize{
        return self.contentView?.getSize() ?? .zero
    }
    
}

class ZxPopContainerView:UIView{
    
}
