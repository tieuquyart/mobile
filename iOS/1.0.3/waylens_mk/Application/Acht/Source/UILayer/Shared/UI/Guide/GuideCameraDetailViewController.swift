//
//  GuideCameraDetailViewController.swift
//  Acht
//
//  Created by Chester Shen on 7/13/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class GuideCameraDetailViewController: NSObject, GuideController {
    var background: UIImageView!
    let view = PassThroughView()
    var gradientLayer: CAGradientLayer?
    var presentedPage: GuidePage?
    weak var detailVC: HNCameraDetailViewController?
    var state: GuideState {
        get {
            return UserSetting.shared.guideState
        }
        set {
            UserSetting.shared.guideState = newValue
        }
    }
    
    var isPresented: Bool = false
    
    static func createViewController() -> GuideCameraDetailViewController {
        let vc = GuideCameraDetailViewController()
        return vc
    }
    
    override init() {
        super.init()
        view.backgroundColor = .clear
        background = PassThroughImageView()
        view.addSubview(background)
        background.frame = view.bounds
        background.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func presentIn(_ vc: UIViewController, animated: Bool) { // todo: animated
        guard let window = vc.view.window else { return }
        detailVC = vc as? HNCameraDetailViewController
        
        window.addSubview(view)
        view.frame = window.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if animated {
            view.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.view.alpha = 1
            }
        }
        refreshUI()
        isPresented = true
    }
    
    func dismiss(animated:Bool) { // todo: animated
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.alpha = 0
            }) { (_) in
                self.clearPage()
                self.view.removeFromSuperview()
            }
        } else {
            clearPage()
            view.removeFromSuperview()
        }
        isPresented = false
    }
    
    @objc func present(_ vc: GuidePage) {
        clearPage()
        vc.controller = self
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentedPage = vc
        view.layoutIfNeeded()
        setGradientLayer()
    }
    
    func clearPage() {
        if let vc = presentedPage {
            vc.view.removeFromSuperview()
            presentedPage = nil
        }
        background.layer.mask = nil
    }
    
    private func setGradientLayer() {
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            gradientLayer?.frame = self.background.bounds
            let color3 = UIColor(rgb: 0x1C95EB).cgColor
            let color2 = UIColor(rgb: 0x0F2447, a: 0.9).cgColor
            let color1 = UIColor(rgb: 0x0C102B, a: 0.85).cgColor
            gradientLayer?.colors = [color1, color2, color3]
            gradientLayer?.locations = [0.0, 0.33, 1.0]
            gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer?.endPoint = CGPoint(x: 0, y: 1)
            UIView.transition(
                with: background,
                duration: 0.6,
                options: .transitionCrossDissolve,
                animations: {
                    self.background.layer.addSublayer(self.gradientLayer!)
            },
                completion: nil
            )
        }
        if gradientLayer?.frame != background.bounds {
            gradientLayer?.frame = self.background.bounds
        }
    }
    
    @objc func refreshUI() {
        
//        let camera = UnifiedCameraManager.shared.local
        switch state {
        case .inCamera:
            state = .showViewMode
            fallthrough
        case .showViewMode:
            if detailVC?.playerPanel.viewMode == .panorama {
                state = .showPanorama
                fallthrough
            }
            let vc = GuideShowViewModePage()
            vc.detailVC = detailVC
            present(vc)
        case .showPanorama:
            if detailVC?.playerPanel.viewMode == .frontBack {
                state = .showViewMode
                refreshUI()
                break
            }
            let vc = GuideShowPanoramaPage()
            vc.detailVC = detailVC
            present(vc)
        case .showTimeline:
            #if FLEET
            if detailVC?.clipInfoBar?.isAppeared == true {
                state = .showActionBar
                fallthrough
            }
            #else
            if detailVC?.actionBar?.status == .action {
                state = .showActionBar
                fallthrough
            }
            #endif

            guard let index = detailVC?.timeLineVerticalView?.collectionView.indexPathsForVisibleItems.sorted().first else {
                dismiss(animated: true)
                break
            }
            let vc = GuideShowTimelinePage()
            vc.detailVC = detailVC
            vc.indexPath = index
            vc.cellHeight = (detailVC?.timeLineVerticalView?.collectionView.collectionViewLayout as? CameraTimeLineLayout)?.thumbnailHeight ?? 56
            present(vc)
        case .showActionBar:
            #if FLEET
            // User did tap the info button in clipInfoBar.
            if detailVC?.clipInfoBar?.isAppeared == true && detailVC?.userSelectedIndex == nil {
                state = .congrats
                dismiss(animated: false)
                break
            }

            guard let selectedIndex = detailVC?.userSelectedIndex, detailVC?.clipInfoBar?.isAppeared == true else {
                state = .showTimeline
                refreshUI()
                break
            }
            #else
            if detailVC?.presentedViewController is EventLegendViewController {
                state = .congrats
                dismiss(animated: false)
                break
            }

            guard let selectedIndex = detailVC?.userSelectedIndex, detailVC?.actionBar?.status == .action else {
                state = .showTimeline
                refreshUI()
                break
            }
            #endif
            let vc = GuideShowActionBarPage()
            vc.detailVC = detailVC
            vc.indexPath = selectedIndex
            clearPage()
            perform(#selector(present(_:)), with: vc, afterDelay: 0.5)
        case .congrats:
            let vc = GuideCongratsPage()
            present(vc)
        default:
            dismiss(animated: true)
        }
    }

    func onAction() {
        switch state {
        case .showPanorama:
            state = .showTimeline
            refreshUI()
        case .showActionBar:
            state = .congrats
            refreshUI()
        case .congrats:
            state = .end
            refreshUI()
        default:
            break
        }
    }
    
    func onSkip() {
        let alert = GuideSkipAlertViewController()
        alert.image = UIImage(named: "image_discontinue")
        alert.text = NSLocalizedString("skip_guide", comment: "skip guide tip")
        alert.addAction(HNAlertAction(title: NSLocalizedString("Continue tour", comment: "Continue tour"), style: .primary))
        alert.addAction(HNAlertAction(title: NSLocalizedString("Skip", comment: "Skip"), style: .cancel, handler: {
            UserSetting.shared.guideSwitch = .skipped
            self.dismiss(animated: true)
        }))
        alert.modalTransitionStyle = .crossDissolve
        alert.modalPresentationStyle = .overCurrentContext
        alert.show()
    }
}
