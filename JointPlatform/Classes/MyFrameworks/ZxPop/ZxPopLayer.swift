//
//  ZxPopLayer.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/14.
//

import UIKit

class ZxPopLayer:NSObject{
    
    public var isAnimating:Bool{
        get{
            return !(currentAnimator == nil)
        }
    }
    
    public weak var animatorProvider:ZxPopTransitionProvider?
    
    private var sharedWindow:UIWindow?{
        get{
            return UIApplication.shared.keyWindow
        }
    }
    
    private var currentContentView:ZxPopContentView?
    private var currentContainer:ZxPopContainerView?
    private var currentAnimator:ZxPopTransitionAnimator?
    
    private var animationStack:[ZxPopTransitionContext] = []
    
    func display(_ contentView:ZxPopContentView){
        createAnimationContext(currentContentView, contentView)
    }
    
    func dismiss(){
        createAnimationContext(currentContentView, nil)
    }
    
    
    func contextDealloc(_ context:ZxPopTransitionContext){
        let _ = animationStack.removeFirst()
        currentAnimator = nil
        context.toFrame?.contentView?.didDisplay()
        context.fromFrame?.contentView?.didHide()
        context.fromFrame?.removeFromSuperview()
        //print("end animtion :\(context.tag), total:\(animationStack.count)")
        if !animationStack.isEmpty{
            let nextAnimationContext = animationStack.first!
            executeContext(nextAnimationContext)
        }
        else{
            //no more animation
            if context.toFrame == nil{
                context.container.removeFromSuperview()
                currentContainer = nil
                //print("remove container")
            }
        }
    }
    
    private func createAnimationContext(_ fromView:ZxPopContentView?,_ toView:ZxPopContentView?){
        if currentContainer == nil{
            currentContainer = ZxPopContainerView()
        }
        
        var context:ZxPopTransitionContext = ZxPopTransitionContext( container: currentContainer!,refLayer: self)
        
        let fromFrame = fromView?.getFrameView()
        context.fromFrame = fromFrame
        
        let toFrame = toView?.getFrameView()
        if toView != nil{
            toFrame?.contentView?.prepare()
            toFrame?.setupAppearance()
            toFrame?.layoutContentView(toView!)
        }
        
        context.toFrame = toFrame
        context.tag = String.rand(length: 16)
        animationStack.append(context)
        currentContentView = context.toFrame?.contentView
        
        //print("push animtion :\(context.tag), total:\(animationStack.count)")
        if self.currentAnimator == nil {
            executeContext(context)
        }
        
    }
    
    
    private func executeContext(_ context:ZxPopTransitionContext){
        
        assert(animatorProvider != nil)
        
        guard currentAnimator == nil else { return }
        
        
        if context.container.superview == nil{
            sharedWindow?.addSubview(context.container)
            context.container.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        if context.toFrame != nil{
            context.container.addSubview(context.toFrame!)
        }
        context.toFrame?.contentView?.willDisplay()
        context.fromFrame?.contentView?.willHide()
        currentAnimator = animatorProvider!.getAnimator(for: context)
        //print("exec animtion :\(context.tag)")
        currentAnimator?.beginTransition(context)
    }
    
}
