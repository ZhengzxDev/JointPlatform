//
//  ZxHUD.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/14.
//

import UIKit


class ZxHUD:NSObject{
    
    
    enum DisplayType{
        case Loading,Error,Complete
    }
    
    static let shared:ZxHUD = {
        let hud = ZxHUD()
        return hud
    }()
    
    private var layer:ZxPopLayer = ZxPopLayer()
    
    private var delayTimer:Timer?
    
    private override init(){
        super.init()
        layer.animatorProvider = self
    }
    
    
    func display(type:DisplayType,title:String,duration:TimeInterval = 0){
        
        var contentView:ZxPopContentView!
        
        switch type {
        case .Loading:
            contentView = ZxHUDLoadingView(title: title)
        case .Error:
            contentView = ZxHUDStateView(title: title, imageName: "system_load_error")
        case .Complete:
            contentView = ZxHUDStateView(title: title, imageName: "system_load_done")
        }
        
        if delayTimer?.isValid ?? false {
            delayTimer?.invalidate()
            //layer.dismiss()
            delayTimer = nil
        }
        
        layer.display(contentView)
        
        if duration > 0{
            delayTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(onDelayTimerUpdate), userInfo: nil, repeats: false)
        }
    }
    
    func dismiss(){
        layer.dismiss()
    }
    
    @objc private func onDelayTimerUpdate(){
        layer.dismiss()
    }
    
}

extension ZxHUD:ZxPopTransitionProvider{
    
    func getAnimator(for context: ZxPopTransitionContext) -> ZxPopTransitionAnimator {
        return ZxHUDTransitionAnimator()
    }
    
    
}
