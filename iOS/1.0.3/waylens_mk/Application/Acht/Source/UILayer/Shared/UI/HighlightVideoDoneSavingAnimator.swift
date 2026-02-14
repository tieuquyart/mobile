//
//  DoneHighlightVideoSavingAnimator.swift
//  Acht
//
//  Created by forkon on 2019/6/6.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

class HighlightVideoDoneSavingAnimator: NSObject {
    private enum AnimationKeys: String {
        case drop
        case slideIn
        case slideOut
        case pulse
    }

    private lazy var viewForAnimationPerforming: UIView = {
        let view = UIView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.clear
        return view
    }()
    private var viewWillBeDropped: UIView?
    private var completionHandler: ((Bool) -> Void)?

    private let indexOfTargetTabBarItem: Int
    private let fakeTabBar: UITabBar

    private weak var containerView: UIView?

    var isAnimating: Bool = false

    init(tabBar: UITabBar, indexOfTargetTabBarItem: Int) {
        self.fakeTabBar = tabBar.clone() as! UITabBar
        self.fakeTabBar.isHidden = false
        self.indexOfTargetTabBarItem = indexOfTargetTabBarItem
    }

    func perform(in containerView: UIView, viewWillBeDropped: UIView, completion: ((Bool) -> Void)?) {
        guard !isAnimating else {
            return
        }
        
        isAnimating = true

        self.containerView = containerView
        self.viewWillBeDropped = viewWillBeDropped.clone()
        self.viewWillBeDropped?.frame = viewWillBeDropped.convert(viewWillBeDropped.bounds, to: containerView)
        self.completionHandler = completion

        setupViews()
        beginAnimation()
    }

}

private extension HighlightVideoDoneSavingAnimator {

    var pathControlPoint: CGPoint? {
        guard let containerView = containerView,
            let viewWillBeDropped = viewWillBeDropped,
            let targetTabBarItemView = targetTabBarItemView else {
                return nil
        }

        let targetTabBarItemViewFrame = containerView.convert(targetTabBarItemView.frame, to: fakeTabBar)

        return CGPoint(x: targetTabBarItemViewFrame.minX, y: viewWillBeDropped.layer.position.y)
    }

    var positionOfTargetTabBarItem: CGPoint? {
        guard let tabBarItemView = targetTabBarItemView else {
            return nil
        }

        let tabBarItemViewFrame = viewForAnimationPerforming.convert(tabBarItemView.frame, from: fakeTabBar)
        return CGPoint(x: tabBarItemViewFrame.midX, y: tabBarItemViewFrame.midY)
    }

    var destinationPositionOfFakeTabBar: CGPoint? {
        return CGPoint(x: viewForAnimationPerforming.frame.width / 2, y: viewForAnimationPerforming.frame.height - fakeTabBar.frame.height / 2)
    }

    var targetTabBarItemView: UIView? {
        return fakeTabBar.viewOfItem(at: indexOfTargetTabBarItem)
    }

    func setupViews() {
        viewWillBeDropped!.isHidden = false
        viewForAnimationPerforming.addSubview(viewWillBeDropped!)

        if viewForAnimationPerforming.subviews.firstIndex(of: fakeTabBar) == nil {
            viewForAnimationPerforming.addSubview(fakeTabBar)
        }

        viewForAnimationPerforming.frame = containerView!.bounds
        containerView!.addSubview(viewForAnimationPerforming)

        fakeTabBar.frame.size.width = viewForAnimationPerforming.frame.width
        fakeTabBar.frame.origin = CGPoint(x: 0.0, y: viewForAnimationPerforming.frame.height)
        fakeTabBar.setNeedsLayout()
        fakeTabBar.layoutIfNeeded()
    }

    func teardownViews() {
        viewWillBeDropped?.removeFromSuperview()
        viewForAnimationPerforming.removeFromSuperview()
        viewWillBeDropped = nil
    }

    func beginAnimation() {
        performDroppingAnimation()
        performSlidingInFakeTabBarAnimation()
    }

    func animationEnded(_ finished: Bool) {
        isAnimating = false
        completionHandler?(finished)
        teardownViews()
    }

    func performDroppingAnimation() {
        guard let positionOfTargetTabBarItem = positionOfTargetTabBarItem,
            let viewWillBeDropped = viewWillBeDropped,
            let pathControlPoint = pathControlPoint else {
                animationEnded(false)
                return
        }

        let path = UIBezierPath()
        path.move(to: viewWillBeDropped.layer.position)
        path.addQuadCurve(to: positionOfTargetTabBarItem, controlPoint: pathControlPoint)

        let moveAnimation = CAKeyframeAnimation(keyPath: "position")
        moveAnimation.path = path.cgPath
        moveAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.duration = 0.5
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = NSNumber(value: .pi * 2.0)
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)

        let shrinkAnimation = CABasicAnimation(keyPath: "transform.scale")
        shrinkAnimation.duration = 0.5
        shrinkAnimation.toValue = NSNumber(value: 0.7)
        shrinkAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [moveAnimation, rotationAnimation, shrinkAnimation]
        animationGroup.duration = 0.5
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.delegate = self

        viewWillBeDropped.layer.add(animationGroup, forKey: AnimationKeys.drop.rawValue)
    }

    func performSlidingInFakeTabBarAnimation() {
        let fromPositin = fakeTabBar.layer.position
        let toPosition = CGPoint(x: viewForAnimationPerforming.frame.width / 2, y: viewForAnimationPerforming.frame.height - fakeTabBar.frame.height / 2)

        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.duration = 0.3
        moveAnimation.fromValue = NSValue(cgPoint: fromPositin)
        moveAnimation.toValue = NSValue(cgPoint: toPosition)
        moveAnimation.isRemovedOnCompletion = false
        moveAnimation.fillMode = .forwards
        moveAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        fakeTabBar.layer.add(moveAnimation, forKey: AnimationKeys.slideIn.rawValue)
    }

    func performSlidingOutFakeTabBarAnimation() {
        let toPosition = CGPoint(x: viewForAnimationPerforming.frame.width / 2, y: viewForAnimationPerforming.frame.height + fakeTabBar.frame.height / 2)

        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.duration = 0.3
        moveAnimation.toValue = NSValue(cgPoint: toPosition)
        moveAnimation.isRemovedOnCompletion = false
        moveAnimation.fillMode = .forwards
        moveAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        moveAnimation.delegate = self
        fakeTabBar.layer.add(moveAnimation, forKey: AnimationKeys.slideOut.rawValue)
    }

    func performPulsingFakeTabBarItemAnimation() {
        let pulseAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        pulseAnimation.values = [1.0, 1.6, 1.0, 1.4, 1.0, 1.2, 1.0]
        pulseAnimation.fillMode = .forwards
        pulseAnimation.duration = 0.8
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        pulseAnimation.isRemovedOnCompletion = false
        pulseAnimation.delegate = self
        targetTabBarItemView?.layer.add(pulseAnimation, forKey: AnimationKeys.pulse.rawValue)
    }

}

extension HighlightVideoDoneSavingAnimator: CAAnimationDelegate {

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == viewWillBeDropped?.layer.animation(forKey: AnimationKeys.drop.rawValue) {
            performPulsingFakeTabBarItemAnimation()
        } else if anim == targetTabBarItemView?.layer.animation(forKey: AnimationKeys.pulse.rawValue) {
            performSlidingOutFakeTabBarAnimation()
        } else if anim == fakeTabBar.layer.animation(forKey: AnimationKeys.slideOut.rawValue) {
            animationEnded(true)
        }
    }

}

private extension UITabBar {

    func viewOfItem(at index: Int) -> UIView? {
        guard let tabBarButtonClass = NSClassFromString("UITabBarButton") else {
            return nil
        }

        let tabBarButtons = subviews.filter{$0.isKind(of: tabBarButtonClass)}
        if !tabBarButtons.isEmpty, index >= 0 && index < tabBarButtons.count {
            return tabBarButtons[index]
        } else {
            return nil
        }
    }

}

private extension UIView {

    func clone() -> UIView {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! UIView
    }

}
