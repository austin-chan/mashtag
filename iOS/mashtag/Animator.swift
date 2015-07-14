//
//  Animator.swift
//  mashtag
//
//  Created by Austin Chan on 7/12/15.
//  Copyright (c) 2015 Awoes, Inc. All rights reserved.
//
//  Lovingly from 🇺🇸
//  ❤️🍻☺️, 💣🔫😭
//

import UIKit

/// Transitioning animation controller to apply custom animations on calls to push and pop view controllers.
class Animator: NSObject, UIViewControllerAnimatedTransitioning {

    /**
        The type of transition to animate when an transition animation is triggered.
    
        - true: A view controller is being pushed onto a navigation controller.
        - false: A view controller is being popped from a navigation controller.
    */
    var presenting: Bool?

    /// The duration specified for the transition animation.
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }

    /// Performs transition animation – slides new view controllers up from the bottom of the screen and shrinks old view controllers.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let finalFrame = transitionContext.finalFrameForViewController(toViewController)
        let initialFrame = transitionContext.initialFrameForViewController(toViewController)

        let duration = self.transitionDuration(transitionContext)

        var container = transitionContext.containerView()

        if presenting! {
            // push transitions
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
            // pop transitions
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

    /// Applies a set of starting property values for the presenting view (in push transitions).
    func frontStart(view: UIView) {
        view.frame = CGRectMake(0, 0, Util.screenSize.width, Util.screenSize.height)
        view.transform = CGAffineTransformIdentity
        view.alpha = 1
    }

    /// Applies a set of final property values for the presenting view (in push transitions).
    func frontEnd(view: UIView) {
        view.frame = CGRectMake(0, 0, Util.screenSize.width, Util.screenSize.height)
        view.transform = CGAffineTransformMakeScale(0.89, 0.89)
        view.alpha = 0.73
    }

    /// Applies a set of starting property values for the presented view (in push transitions).
    func backStart(view: UIView) {
        view.frame = CGRectMake(0, Util.screenSize.height, Util.screenSize.width, Util.screenSize.height)
    }

    /// Applies a set of final property values for the presented view (in push transitions).
    func backEnd(view: UIView) {
        view.frame = CGRectMake(0, 0, Util.screenSize.width, Util.screenSize.height)
    }

}
