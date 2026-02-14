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
import WaylensCameraSDK

class HNHomeViewController: BaseViewController,
UnifiedCameraManagerDelegate,
CameraPreviewDelegate,
UIScrollViewDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var dots: UIImageView!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    
    private weak var shadowImageView: UIImageView?
    
    

    var cameraPreviews: [CameraPreview] = []
    var cameraCount = 0
    var visible: Bool = false
    var viewIsAppeared = false {
        didSet {
            checkVisibility()
        }
    }
    var CameraPreviewPageWidth: CGFloat = 290
    var animating: Bool = false
    var currentCamera: UnifiedCamera? {
        return pageControl.currentPage < cameraPreviews.count ? cameraPreviews[pageControl.currentPage].camera : nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title = ""
        navigationController?.tabBarItem.title = NSLocalizedString("Camera", comment: "Camera")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutIfNeeded()
        
        pageControl.isHidden = true
        UnifiedCameraManager.shared.delegate = self
        view.addGestureRecognizer(scrollView.panGestureRecognizer)
        scrollView.delegate = self
        CameraPreviewPageWidth = min(UIScreen.main.bounds.width * 290 / 375, 740)
        scrollViewWidth.constant = CameraPreviewPageWidth
        NotificationCenter.default.addObserver(self, selector: #selector(onBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        needsHideNavigationBar = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shadowImageView == nil, let navigationBar = navigationController?.navigationBar {
            shadowImageView = findShadowImage(under: navigationBar)
        }
        shadowImageView?.isHidden = true

        rebuildCameraList()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for vc in cameraPreviews {
            var frame = vc.view.frame
            frame.size.width = CameraPreviewPageWidth
            frame.size.height = scrollView.frame.size.height
            vc.view.frame = frame
        }
        
        if let lastCameraPreview = cameraPreviews.last {
            scrollView.contentSize = CGSize(width: lastCameraPreview.view.frame.maxX, height: scrollView.frame.height)
        } else {
            scrollView.contentSize = CGSize.zero
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if cameraCount>0 {
            cameraPreviews[pageControl.currentPage].show()
            refreshAnimation()
        }
    }
    
    func viewDidBecomeInvisible() {
        if cameraCount>0 {
            cameraPreviews[pageControl.currentPage].hide()
            stopAnimation()
        }
    }
    
    private func rebuildCameraList() {
//        let current = currentCamera
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
                vc.view.frame = CGRect(x: CGFloat(i)*CameraPreviewPageWidth, y: 0, width: CameraPreviewPageWidth, height: scrollView.frame.size.height)
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
            // set cameras
//            UnifiedCameraManager.shared.current = nil
//            for (i, camera) in UnifiedCameraManager.shared.cameras.enumerated() {
//                let vc = cameraPreviews[i]
//                vc.setupState = .settedUp
//                vc.camera = camera
//                if camera == current {
//                    UnifiedCameraManager.shared.current = camera
//                }
//            }
//            if UnifiedCameraManager.shared.current == nil {
//                UnifiedCameraManager.shared.current = UnifiedCameraManager.shared.cameras[0]
//            }
//            let currentIndex = UnifiedCameraManager.shared.currentIndex!
//            pageControl.currentPage = currentIndex
        } else {
            let vc = cameraPreviews[0]
            vc.setupState = .notSettedUp
            vc.camera = nil
            pageControl.currentPage = 0
        }

        scrollView.contentSize = CGSize(width: CameraPreviewPageWidth * CGFloat(newCount), height: scrollView.frame.size.height)
        scrollView.contentOffset = CGPoint.init(x: CGFloat(pageControl.currentPage) * CameraPreviewPageWidth, y: 0)

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
    
    @objc func openAlerts() {
        if AccountControlManager.shared.isAuthed {
            performSegue(withIdentifier: "openAlerts", sender: self)
        } else {
            let vc = SignInContainerViewController.createViewController()

            if #available(iOS 13.0, *) {
                vc.modalPresentationStyle = .fullScreen
            }

            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func onOpenAlerts(_ sender: Any) {
        performSegue(withIdentifier: "openAlerts", sender: self)
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
                    if vc.camera != camera {
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
    
    @available (iOS 11, *)
    override func viewSafeAreaInsetsDidChange() {
        if view.safeAreaInsets.top > 0 {
//            topToSuperview.constant = view.safeAreaInsets.top
        }
    }
    
    // MARK: - CameraPreviewDelegate
    func didTapOnPreview(_ preview: CameraPreview) {
        if preview.setupState == .notSettedUp {
            let vc = SetupStepOneViewController.createViewController()
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .plain, actionBlock: { _ in
                vc.dismissMyself(animated: true)
            })

            let navVC = vc.embedInNavigationController()

            if #available(iOS 13.0, *) {
                navVC.modalPresentationStyle = .fullScreen
            }

            present(navVC, animated: true, completion: nil)
        } else if preview.setupState == .settedUp {
            let detailVC = HNCameraDetailViewController.createViewController(camera: preview.camera)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func didTapLocation(_ preview: CameraPreview, location: WLLocation) {
        let vc = MapViewController.createViewController()
        vc.camera = preview.camera
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapOnPlan(_ preview: CameraPreview) {
        let vc = PlanWebViewController.createViewController()
        vc.camera = preview.camera
        vc.modalPresentationStyle = .fullScreen

        if #available(iOS 13.0, *) {
            vc.modalPresentationStyle = .fullScreen
        }

        present(vc, animated: true, completion: nil)
    }
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var currentIndex = Int(scrollView.contentOffset.x / CameraPreviewPageWidth + 0.5)
        currentIndex = max(0, min(currentIndex, cameraPreviews.count - 1))
        if currentIndex != pageControl.currentPage {
            cameraPreviews[pageControl.currentPage].hide()
            cameraPreviews[currentIndex].show()
            pageControl.currentPage = currentIndex
            refreshAnimation()
        }
    }
}

final class CameraEventObserver: NSObject {
    typealias ChangeHandlerType = (Int) -> Void

    private weak var cameraObserved: WLCameraDevice?
    private var changeHandler: ChangeHandlerType?

    private(set) var numberOfEventsInLast24Hours: Int = 0

    deinit {
        stopObserve()
    }

    func observe(_ camera: WLCameraDevice, withChangeHandler changeHandler: @escaping ChangeHandlerType) {
        guard cameraObserved != camera else {
            return
        }

        self.changeHandler = changeHandler
        self.cameraObserved = camera
        camera.clipsAgent.add(delegate: self)

        getTheNumberOfEventsInLast24Hours()
    }

    func stopObserve() {
        cameraObserved?.clipsAgent.remove(delegate: self)
        changeHandler = nil
    }

    private func getTheNumberOfEventsInLast24Hours() {
        guard let clips = cameraObserved?.clipsAgent.list(of: WLClipListType.bookMark) else {
            return
        }

        let eventClipsIn24Hours = clips.filter { (clip) -> Bool in
            if clip.eventType == .NULL {
                return false
            }

            let startTimeInterval = clip.startDate + clip.startTime - NSDate.zoneInterval()

            if Date().timeIntervalSince1970 - startTimeInterval <= 24 * 60 * 60 {
                return true
            }
            return false
        }

        if numberOfEventsInLast24Hours != eventClipsIn24Hours.count {
            numberOfEventsInLast24Hours = eventClipsIn24Hours.count
            changeHandler?(numberOfEventsInLast24Hours)
        }
    }

}

extension CameraEventObserver: WLCameraVDBClipsAgentDelegate {

    func onVDBReady(_ isReady: Bool) {

    }

    func onClipListLoaded(_ listType: WLClipListType) {
        getTheNumberOfEventsInLast24Hours()
    }

    func onNewClip(_ clip: WLVDBClip!, to listType: WLClipListType) {
        getTheNumberOfEventsInLast24Hours()
    }

    func onRemove(_ clip: WLVDBClip!, from listType: WLClipListType) {
        getTheNumberOfEventsInLast24Hours()
    }

    func onUpdate(_ clip: WLVDBClip!, from listType: WLClipListType) {

    }

}
