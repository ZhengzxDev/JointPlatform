//
//  ZxHUDTransitionAnimator.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/19.
//

import UIKit


class ZxHUDTransitionAnimator:NSObject,ZxPopTransitionAnimator{
    
    private let containerColor:UIColor = UIColor(r: 0, g: 0, b: 0, a: 0.3)
    
    func beginTransition(_ context: ZxPopTransitionContext) {
        
        let fromFrame = context.fromFrame
        let toFrame = context.toFrame
        
        if fromFrame == nil && toFrame != nil{
            //fade in
            let baseSize = toFrame!.baseSize()
            let startSize = baseSize.modify(scale: 1.3)
            toFrame?.frame = CGRect(origin: CGPoint(x: (SCREEN_WIDTH-startSize.width)/2, y: (SCREEN_HEIGHT-startSize.height)/2), size: startSize)
            toFrame?.alpha = 0
            toFrame?.contentView?.alpha = 0
            context.container.alpha = 0
            UIView.animate(withDuration: 0.2) {
                [weak self] in
                guard let strongSelf = self else {
                    context.transitionCompleted()
                    return
                }
                context.container.backgroundColor = strongSelf.containerColor
                context.container.alpha = 1
                toFrame?.frame = CGRect(origin: CGPoint(x: (SCREEN_WIDTH-baseSize.width)/2, y: (SCREEN_HEIGHT-baseSize.height)/2), size: baseSize)
                toFrame?.alpha = 1
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    toFrame?.contentView?.alpha = 1
                } completion: { _ in
                    context.transitionCompleted()
                }
            }

        }
        else if fromFrame != nil && toFrame == nil{
            //fade out
            let baseSize = fromFrame!.baseSize()
            let endSize = baseSize.modify(scale: 1.3)
            fromFrame?.frame = CGRect(origin: CGPoint(x: (SCREEN_WIDTH-baseSize.width)/2, y: (SCREEN_HEIGHT-baseSize.height)/2), size: baseSize)
            fromFrame?.alpha = 1
            fromFrame?.contentView?.alpha = 1
            context.container.alpha = 1
            UIView.animate(withDuration: 0.2) {
                fromFrame?.contentView?.alpha = 0
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    context.container.alpha = 0
                    fromFrame?.frame = CGRect(origin: CGPoint(x: (SCREEN_WIDTH-endSize.width)/2, y: (SCREEN_HEIGHT-endSize.height)/2), size: endSize)
                    fromFrame?.alpha = 0
                } completion: { _ in
                    context.transitionCompleted()
                }
            }

        }
        else if fromFrame != nil && toFrame != nil{
            //rect transition
            let toSize = toFrame!.baseSize()
            let fromSize = fromFrame!.baseSize()
            toFrame?.alpha = 0
            fromFrame?.alpha = 1
            toFrame?.frame = CGRect(origin: CGPoint(x: (SCREEN_WIDTH-toSize.width)/2, y: (SCREEN_HEIGHT-toSize.height)/2), size: toSize)
            fromFrame?.frame = CGRect(origin: CGPoint(x: (SCREEN_WIDTH-fromSize.width)/2, y: (SCREEN_HEIGHT-fromSize.height)/2), size: fromSize)
            UIView.animate(withDuration: 0.2) {
                fromFrame!.contentView!.alpha = 0
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    fromFrame?.frame = CGRect(origin: CGPoint(x: (SCREEN_WIDTH-toSize.width)/2, y: (SCREEN_HEIGHT-toSize.height)/2), size: toSize)
                } completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        fromFrame?.alpha = 0
                        toFrame?.alpha = 1
                    } completion: { _ in
                        context.transitionCompleted()
                    }
                }

            }
            
        }
        else{
            context.transitionCompleted()
        }
        
    }
    
    func interrupted() {
        //
    }
    
    
}
