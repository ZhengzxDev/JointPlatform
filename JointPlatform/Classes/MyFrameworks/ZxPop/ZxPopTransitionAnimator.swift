//
//  ZxPopTransitionAnimator.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/14.
//

import UIKit


protocol ZxPopTransitionProvider:NSObjectProtocol{
    func getAnimator(for context:ZxPopTransitionContext) -> ZxPopTransitionAnimator
}

struct ZxPopTransitionContext{
    var fromFrame:ZxPopWindowFrameView?
    var toFrame:ZxPopWindowFrameView?
    var container:ZxPopContainerView
    
    var refLayer:ZxPopLayer
    
    var tag:String = ""
    
    func transitionCompleted(){
        refLayer.contextDealloc(self)
    }
}

protocol ZxPopTransitionAnimator:NSObjectProtocol{
    
    func beginTransition(_ context:ZxPopTransitionContext)
    
    func interrupted()
}
