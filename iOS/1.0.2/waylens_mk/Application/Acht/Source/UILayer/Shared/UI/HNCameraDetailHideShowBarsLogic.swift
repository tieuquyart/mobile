//
//  HNCameraDetailHideShowBarsLogic.swift
//  Acht
//
//  Created by forkon on 2020/1/20.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class HNCameraDetailHideShowBarsLogic: NSObject {
    private(set) var prefersStatusBarHidden = false
    private(set) var preferredStatusBarUpdateAnimation = UIStatusBarAnimation.slide
    
    private weak var scrollView: UIScrollView?
    private weak var tabBarController: UITabBarController?
    private weak var playerContainer: UIView?
    private weak var navigationController: UINavigationController?
    private weak var playerContainerTopConstraint: NSLayoutConstraint?
    
    private var isNavigationBarStateFrozen: Bool = false
    private var isInPortraitOrientation: Bool = true
    
    init(
        scrollView: UIScrollView?,
        tabBarController: UITabBarController?,
        navigationController: UINavigationController?,
        playerContainer: UIView?,
        playerContainerTopConstraint: NSLayoutConstraint?
    ) {
        super.init()
        
        self.scrollView = scrollView
        self.tabBarController = tabBarController
        self.navigationController = navigationController
        self.playerContainer = playerContainer
        self.playerContainerTopConstraint = playerContainerTopConstraint
        
        scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        scrollView?.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let scrollView = object as? UIScrollView {
            if scrollView == self.scrollView && keyPath == #keyPath(UIScrollView.contentSize) {
                // only works in portrait
                if UIDevice.current.orientation.isPortrait, scrollView.contentSize.height <= scrollView.frame.height {
                    setBarsVisible(visible: true, animated: true)
                }
                updateNavigationBarState()
            }
        }
    }
    
    func scrollViewDidScroll() {
        guard let scrollView = scrollView else {
            return
        }
        
        let scrollVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
        
        if scrollVelocity.y != 0 {
            if scrollVelocity.y > 0 {
                setBarsVisible(visible: true, animated: true)
            } else {
                setBarsVisible(visible: false, animated: true)
            }
        }
    }
    
    func viewWillAppear() {
        isNavigationBarStateFrozen = false
        updateNavigationBarState()
    }
    
    func viewWillDisappear() {
        setBarsVisible(visible: true, animated: false)
        restoreNavigationBarState()
        isNavigationBarStateFrozen = true
    }
    
    func layout(asLandscape: Bool) {
        setBarsVisible(visible: !asLandscape, animated: true)
    }
    
    func timelineDidSelectItem() {
        setBarsVisible(visible: false, animated: false)
    }
    
    func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.height > size.width { // rotate to portrait
            isInPortraitOrientation = true
            tabBarController?.originFrameOfView = nil
            tabBarController?.movedFrameOfView = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.shorterEdge, height: UIScreen.main.bounds.longerEdge)
        } else { // rotate to landscape
            isInPortraitOrientation = false
            tabBarController?.originFrameOfView = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.longerEdge, height: UIScreen.main.bounds.shorterEdge)
            tabBarController?.movedFrameOfView = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.longerEdge, height: UIScreen.main.bounds.shorterEdge + tabBarController!.tabBar.frame.height)
        }
        
        if #available(iOS 11.0, *) {
            tabBarController?.additionalSafeAreaInsets = UIEdgeInsets.zero
        }
    }
    
    func viewDidLayoutSubviews() {
        updateNavigationBarState()
    }
    
    func applyTheme() {
        if isNavigationBarStateFrozen {
            updateNavigationBarAppearance(isTranslucent: false)
        }
        else {
            updateNavigationBarAppearance(isTranslucent: navigationController?.navigationBar.isTranslucent ?? false)
        }
    }
}

private extension HNCameraDetailHideShowBarsLogic {
    
    func setBarsVisible(visible: Bool, animated: Bool) {
        tabBarController?.setTabBarVisible(visible: visible, animated: animated)
        
        if isInPortraitOrientation {
            navigationController?.setNavigationBarHidden(!visible, animated: true)
        }
        else {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        if !UIDevice.current.hasSensorNotch {
            prefersStatusBarHidden = !visible
            playerContainer?.parentViewController?.setNeedsStatusBarAppearanceUpdate()
        }
        
        adjustPlayerContainerPosition()
    }
    
    func updateNavigationBarState() {
        guard !isNavigationBarStateFrozen else {
            return
        }
        
        guard let scrollView = scrollView else {
            return
        }
        
        if let newFrame = playerContainer?.frame {
            let newAspectRatio = newFrame.width / newFrame.height
            
            if newAspectRatio < 16.0 / 9.0, scrollView.contentSize.height > scrollView.frame.height {
                if navigationController?.navigationBar.isTranslucent == true {
                    return
                }
                
                updateNavigationBarAppearance(isTranslucent: true)
                adjustPlayerContainerPosition()
            }
            else {
                if navigationController?.navigationBar.isTranslucent == false {
                    return
                }
                
                updateNavigationBarAppearance(isTranslucent: false)
                adjustPlayerContainerPosition()
                
                if isInPortraitOrientation, navigationController?.isNavigationBarHidden == true {
                    navigationController?.setNavigationBarHidden(false, animated: false)
                }
            }
        }
    }
    
    func updateNavigationBarAppearance(isTranslucent: Bool) {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            
            if isTranslucent {
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = UIColor.white
                appearance.shadowImage = UIColor.clear.toImage()
            }
            else {
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.semanticColor(.background(.primary))
                appearance.shadowImage = UIColor.semanticColor(.separator(.opaque)).toImage()
            }
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }
        else {
            if isTranslucent {
                navigationController?.navigationBar.setBackgroundImage(UIColor.semanticColor(.background(.primary)).withAlphaComponent(0.5).toImage(), for: .default)
                navigationController?.navigationBar.shadowImage = UIColor.clear.toImage()
            }
            else {
                navigationController?.navigationBar.setBackgroundImage(UIColor.semanticColor(.background(.primary)).toImage(), for: .default)
                navigationController?.navigationBar.shadowImage = UIColor.semanticColor(.separator(.opaque)).toImage()
            }
        }
        navigationController?.navigationBar.isTranslucent = isTranslucent
    }
    
    func restoreNavigationBarState() {
        updateNavigationBarAppearance(isTranslucent: false)
        
        if isInPortraitOrientation {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        else {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    func adjustPlayerContainerPosition() {
        if navigationController?.navigationBar.isTranslucent == true {
            if UIDevice.current.hasSensorNotch {
                playerContainerTopConstraint?.constant = -sensorNotchHeight()
            } else {
                playerContainerTopConstraint?.constant = 0.0
            }
        }
        else {
            if navigationController?.isNavigationBarHidden == true && UIDevice.current.hasSensorNotch {
                playerContainerTopConstraint?.constant = -sensorNotchHeight()
            }
            else {
                playerContainerTopConstraint?.constant = 0.0
            }
        }
    }
    
    func sensorNotchHeight() -> CGFloat {
        if #available(iOS 11.0, *) {
            return (navigationController?.view.window?.safeAreaInsets.top ?? 0.0)
        } else {
            return 0.0
        }
    }
    
}
