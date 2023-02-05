//
//  PureColorAnimateTransition.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/19.
//

import UIKit


class PureColorAnimateTransition:NSObject,UIViewControllerAnimatedTransitioning{
    
    private var maskColor:UIColor = .black
    
    init(color:UIColor){
        self.maskColor = color
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        fromView.alpha = 1
        toView.alpha = 0
        let containerView = transitionContext.containerView
        
        let maskView = UIView()
        maskView.backgroundColor = self.maskColor
        maskView.alpha = 0
        maskView.frame = fromView.frame
        
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        containerView.addSubview(maskView)
        
        
        
        UIView.animate(withDuration: 0.3) {
            maskView.alpha = 1
        } completion: { _ in
            fromView.alpha = 0
            toView.alpha = 1
            UIView.animate(withDuration: 0.4) {
                maskView.alpha = 0
            } completion: { _ in
                maskView.removeFromSuperview()
                transitionContext.completeTransition(true)
                fromView.alpha = 1
            }
        }

    }
    
    
    
    
}
