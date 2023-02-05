//
//  BackWordsAnimateTransition.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/19.
//

import UIKit


class BackWordsAnimateTransition:NSObject,UIViewControllerAnimatedTransitioning{
    
    private var operation:UINavigationController.Operation!
    
    init(operation:UINavigationController.Operation){
        self.operation = operation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromViewController = transitionContext.viewController(forKey: .from) as? WordsTransController else {
            transitionContext.completeTransition(true)
            return
        }

        guard let toViewController = transitionContext.viewController(forKey: .to) as? WordsTransController else {
            transitionContext.completeTransition(true)
            return
        }
        
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        let fromContentView = fromViewController.contentView
        let toContentView = toViewController.contentView
        fromView.alpha = 1
        toView.alpha = 0
        let containerView = transitionContext.containerView
        containerView.backgroundColor = fromViewController.backgroundFadeColor
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        

        
        switch self.operation{
        case .push:
            UIView.animate(withDuration: 0.3) {
                fromContentView.transform = .init(translationX: -100, y: 0)
                fromContentView.alpha = 0
                containerView.backgroundColor = toViewController.backgroundFadeColor
            } completion: { _ in
                toContentView.transform = .init(translationX: 100, y: 0)
                toContentView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    toView.alpha = 1
                    toContentView.transform = .identity
                    toContentView.alpha = 1
                    fromViewController.backgroundImageView.alpha = 0
                    //toViewController.backgroundImageView.alpha = toViewController.imageAlpha
                } completion: { _ in
                    //fade backcolor
                    transitionContext.completeTransition(true)
                    fromContentView.transform = .identity
                    toContentView.transform = .identity
                    fromContentView.alpha = 1
                    toContentView.alpha = 1
                    fromViewController.backgroundImageView.alpha = fromViewController.imageAlpha
                    //toViewController.backgroundImageView.alpha = toViewController.imageAlpha
                }

            }
        case .pop:
            UIView.animate(withDuration: 0.3) {
                fromContentView.transform = .init(translationX: 100, y: 0)
                fromContentView.alpha = 0
                containerView.backgroundColor = toViewController.backgroundFadeColor
            } completion: { _ in
                
                toContentView.transform = .init(translationX: -100, y: 0)
                toContentView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    toContentView.transform = .identity
                    toContentView.alpha = 1
                    toView.alpha = 1
                    fromViewController.backgroundImageView.alpha = 0
                    //toViewController.backgroundImageView.alpha = toViewController.imageAlpha
                } completion: { _ in
                    //fade backcolor
                    transitionContext.completeTransition(true)
                    fromContentView.transform = .identity
                    toContentView.transform = .identity
                    fromContentView.alpha = 1
                    toContentView.alpha = 1
                    fromViewController.backgroundImageView.alpha = fromViewController.imageAlpha
                    //toViewController.backgroundImageView.alpha = toViewController.imageAlpha
                }

            }
        default:
            transitionContext.completeTransition(true)
        }
        

    }
    
    
    
    
}


