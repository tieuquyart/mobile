//
//  HNHomeViewController.swift
//  Acht
//
//  Created by Chester Shen on 7/5/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
#if useMixpanel
import Mixpanel
#endif

class CameraPickerViewController: BaseViewController, UnifiedCameraManagerDelegate, CameraPreviewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var dots: UIImageView!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!

    var cameraPreviews: [CameraPreview] = []
    var cameraCount = 0
    var visible: Bool = false
    var viewIsAppeared = false {
        didSet {
            checkVisibility()
        }
    }

    var animating: Bool = false
    var currentCamera: UnifiedCamera? {
        return pageControl.currentPage < cameraPreviews.count ? cameraPreviews[pageControl.currentPage].camera : nil
    }

    var selectHandler: ((UnifiedCamera) -> ())? = nil
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title = NSLocalizedString("Please Select a Camera", comment: "Please Select a Camera")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutIfNeeded()
        
        pageControl.isHidden = true
        UnifiedCameraManager.shared.delegate = self
        view.addGestureRecognizer(scrollView.panGestureRecognizer)
        scrollView.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(onBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        rebuildCameraList()
        UnifiedCameraManager.shared.updateRemote()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.layoutIfNeeded()
        viewIsAppeared = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewIsAppeared = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for (i, cameraPreview) in cameraPreviews.enumerated() {
            cameraPreview.view.frame = CGRect(
                x: CGFloat(i) * scrollView.frame.width,
                y: 0,
                width: scrollView.frame.width,
                height: scrollView.frame.height
            )
        }
        
        if let lastCameraPreview = cameraPreviews.last {
            scrollView.contentSize = CGSize(width: lastCameraPreview.view.frame.maxX, height: scrollView.frame.height)
        } else {
            scrollView.contentSize = CGSize.zero
        }
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.cameraPickerBackground)
    }

    func checkVisibility() {
        let newValue = viewIsAppeared
        if newValue == visible {
            return
        }
        visible = newValue
        if visible {
            viewDidBecomeVisible()
        } else {
            viewDidBecomeInvisible()
        }
    }
    
    func viewDidBecomeVisible() {
        if cameraCount > 0 {
            cameraPreviews[pageControl.currentPage].show()
            refreshAnimation()
        }
    }
    
    func viewDidBecomeInvisible() {
        if cameraCount > 0 {
            cameraPreviews[pageControl.currentPage].hide()
            stopAnimation()
        }
    }
    
    private func rebuildCameraList() {
        let oldCount = cameraPreviews.count
        cameraCount = UnifiedCameraManager.shared.cameras.count
        let newCount = max(cameraCount, 1)
        if newCount > oldCount {
            // add more previews
            for i in oldCount..<newCount {
                let vc = CameraPreview.createViewController()
                vc.delegate = self
                scrollView.addSubview(vc.view)
                self.addChild(vc)
                vc.didMove(toParent: self)
                vc.view.translatesAutoresizingMaskIntoConstraints = true
                vc.view.frame = CGRect(
                    x: CGFloat(i) * scrollView.frame.width,
                    y: 0,
                    width: scrollView.frame.width,
                    height: scrollView.frame.height
                )
                cameraPreviews.append(vc)
            }
        } else if newCount < oldCount {
            // remove some previews
            for i in newCount..<oldCount {
                let vc = cameraPreviews[i]
                vc.hide()
                vc.view.removeFromSuperview()
                vc.removeFromParent()
            }
            cameraPreviews.removeSubrange(newCount..<oldCount)
        }

        pageControl.numberOfPages = newCount
        
        if cameraCount > 0 {
            for (i, camera) in UnifiedCameraManager.shared.cameras.enumerated() {
                let vc = cameraPreviews[i]
                vc.setupState = .settedUp
                vc.camera = camera
            }
            let currentIndex = UnifiedCameraManager.shared.currentIndex ?? 0
            pageControl.currentPage = currentIndex
        } else {
            let vc = cameraPreviews[0]
            vc.setupState = .notSettedUp
            vc.camera = nil
            pageControl.currentPage = 0
        }

        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(newCount), height: scrollView.frame.height)
        scrollView.contentOffset = CGPoint.init(x: CGFloat(pageControl.currentPage) * scrollView.frame.width, y: 0)

        if visible {
            cameraPreviews[pageControl.currentPage].show()
            refreshAnimation()
        }
        
    }
    
    func scrollToCamera(_ camera: UnifiedCamera) {
        for preview in cameraPreviews {
            if preview.camera == camera {
                scrollView.setContentOffset(preview.view.frame.origin, animated: true)
                break
            }
        }
    }
    
    @IBAction func scrollToPreviousCamera(_ sender: Any) {
        let previousIndex = max(pageControl.currentPage - 1, 0)
        scrollView.setContentOffset(cameraPreviews[previousIndex].view.frame.origin, animated: true)
    }
    
    @IBAction func scrollToNextCamera(_ sender: Any) {
        let nextIndex = min(pageControl.currentPage + 1, pageControl.numberOfPages - 1)
        scrollView.setContentOffset(cameraPreviews[nextIndex].view.frame.origin, animated: true)
    }
    
    // MARK: - CameraManagerDelegate

    func onCameraListUpdated() {
        rebuildCameraList()
        if let vcs = navigationController?.viewControllers {
            for case var vc as CameraRelated in vcs {
                if let camera = vc.camera {
                    if let updatedCamera = UnifiedCameraManager.shared.cameraForSN(camera.sn) {
                        vc.camera = updatedCamera
                    } else {
                        AppViewControllerManager.dismissToRootViewController()
                        break
                    }
                }
            }
        }
    }
    
    func onCameraUpdated(_ camera: UnifiedCamera) {
        if visible {
            if currentCamera == camera {
                refreshAnimation()
            }
            let preview = cameraPreviews.first {
                $0.camera === camera
            }
            preview?.refreshUI()
        } else {
            if let vcs = navigationController?.viewControllers {
                for case var vc as CameraRelated in vcs {
                    if vc.camera == camera {
                        vc.camera = camera
                    }
                }
            }
        }
    }
    
    func refreshAnimation() {
        let shouldAnimate = currentCamera == nil || currentCamera!.isOffline ? false : currentCamera!.mode == .driving
        if shouldAnimate {
            startAnimation()
        } else {
            stopAnimation()
        }
    }
    
    func stopAnimation() {
        animating = false
        dots.layer.removeAllAnimations()
    }
    
    func startAnimation() {
        if animating {
            return
        }
        animating = true
        let ratio: CGFloat = 387 / 375
        let offset = dots.bounds.height * (ratio - 1) * 0.5
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: [.repeat, .calculationModeLinear], animations: {
            self.dots.transform = CGAffineTransform.identity
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                self.dots.transform = CGAffineTransform(scaleX: ratio, y: ratio).concatenating(CGAffineTransform(translationX: 0, y: offset))
            })
        }, completion: { (_) in
            if !self.animating {
                UIView.setAnimationRepeatCount(0)
            }
        })
    }
    
    @objc func onBecomeActive() {
        animating = false
        refreshAnimation()
    }
    
    // MARK: - CameraPreviewDelegate

    func didTapOnPreview(_ preview: CameraPreview) {
        selectHandler?(preview.camera!)
    }
    
    func didTapLocation(_ preview: CameraPreview, location: WLLocation) {
        let vc = MapViewController.createViewController()
        vc.camera = preview.camera
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapOnPlan(_ preview: CameraPreview) {
        let vc = PlanWebViewController.createViewController()
        vc.camera = preview.camera
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5)
        currentIndex = max(0, min(currentIndex, cameraPreviews.count - 1))
        if currentIndex != pageControl.currentPage {
            cameraPreviews[pageControl.currentPage].hide()
            cameraPreviews[currentIndex].show()
            pageControl.currentPage = currentIndex
            refreshAnimation()
        }
    }
}
