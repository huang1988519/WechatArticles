//
//  PresentTransiton.swift
//  WechatArticle
//
//  Created by hwh on 15/11/12.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
//import Spring

public class PresentTransition : NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    var isPresenting = true
    var duration = 0.7
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()!
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let toController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        var frame = transitionContext.finalFrameForViewController(toController!)
        
        if isPresenting {
            container.addSubview(fromView)
            container.addSubview(toView)
            fromView.backgroundColor = UIColor.clearColor()
            
            frame.origin.x = CGRectGetWidth(frame)
            toView.frame = frame
            
            UIView.animateWithDuration(
                duration,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 2,
                options: .CurveEaseInOut,
                animations: { () -> Void in
                    frame.origin.x = 0
                    toView.frame = frame
                },
                completion: nil)
        }
        else {
            container.addSubview(toView)
            container.addSubview(fromView)
            

            UIView.animateWithDuration(
                duration,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 2,
                options: .CurveEaseIn,
                animations: { () -> Void in
                    frame.origin.y = CGRectGetHeight(frame)
                    fromView.frame = frame
                }, completion: nil)
        }
        
        delay(duration, closure: {
            transitionContext.completeTransition(true)
        })
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
}