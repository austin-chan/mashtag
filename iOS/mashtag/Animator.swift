//
//  Animator.swift
//  mashtag
//
//  Created by Austin Chan on 7/12/15.
//  Copyright (c) 2015 Fiftyawoe. All rights reserved.
//

import UIKit

class Animator: NSObject, UIViewControllerAnimatedTransitioning {

    var presenting: Bool?

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let finalFrame = transitionContext.finalFrameForViewController(toViewController)
        let initialFrame = transitionContext.initialFrameForViewController(toViewController)

//        println(initialFrame)
//        println(finalFrame)

        let duration = self.transitionDuration(transitionContext)

        var container = transitionContext.containerView()

        if presenting! {
            container.addSubview(toViewController.view)

            frontStart(fromViewController.view)
            backStart(toViewController.view)

            UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 8, options: nil, animations: {
                self.frontEnd(fromViewController.view)
                self.backEnd(toViewController.view)
            }) { (finished) -> Void in
                self.frontStart(fromViewController.view)
                transitionContext.completeTransition(true)
            }
        } else {
            container.insertSubview(toViewController.view, belowSubview: fromViewController.view)

            backEnd(fromViewController.view)
            frontEnd(toViewController.view)

            UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 8, options: nil, animations: {
                self.backStart(fromViewController.view)

                // weird iOS bug, have to repeat instructions here
                toViewController.view.transform = CGAffineTransformIdentity
                toViewController.view.frame = CGRectMake(0, 0, Util.screenSize.width, Util.screenSize.height)
                toViewController.view.alpha = 1
            }) { (finished) -> Void in
                transitionContext.completeTransition(true)
            }
        }
    }

    func frontStart(view: UIView) {
        view.frame = CGRectMake(0, 0, Util.screenSize.width, Util.screenSize.height)
        view.transform = CGAffineTransformIdentity
        view.alpha = 1
    }

    func frontEnd(view: UIView) {
        view.frame = CGRectMake(0, 0, Util.screenSize.width, Util.screenSize.height)
        view.transform = CGAffineTransformMakeScale(0.89, 0.89)
        view.alpha = 0.73
    }

    func backStart(view: UIView) {
        view.frame = CGRectMake(0, Util.screenSize.height, Util.screenSize.width, Util.screenSize.height)
    }

    func backEnd(view: UIView) {
        view.frame = CGRectMake(0, 0, Util.screenSize.width, Util.screenSize.height)
    }

}
