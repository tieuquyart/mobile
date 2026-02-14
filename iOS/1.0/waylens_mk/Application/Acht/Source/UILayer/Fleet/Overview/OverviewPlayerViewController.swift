//
//  OverviewPlayerViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/10.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import MapKit
 class OverviewPlayerViewController<HeaderViewType>: BaseViewController, HNPlayerPanelDelegate  {

    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet private weak var headerViewContainerView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!

     @IBOutlet weak var mapViewCustom: MapViewCustom!
     
     
    private(set) var playerPanel: PlayerPanel!
    private(set) var headerView: HeaderViewType!

    override var shouldAutorotate: Bool {
        return true
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if isFirstAppearance {
            return .portrait
        }
        else {
            return .allButUpsideDown
        }
    }

    private var isFirstAppearance: Bool = true

    init() {
        super.init(nibName: "OverviewPlayerViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let closeButton = UIBarButtonItem(image: FleetResource.Image.closeButton, style: .plain, target: self, action:  #selector(closeButtonTapped(_:)))
        navigationItem.leftBarButtonItem = closeButton

        playerPanel = createPlayerPanel()
        playerPanel.addToParentViewController(self, superView: playerContainerView)
        playerPanel.delegate = self

        headerView = createHeaderView()
        
        if let headerView = headerView as? UIView {
            headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            headerView.frame = headerViewContainerView.bounds
            headerViewContainerView.addSubview(headerView)
        }
        actionButton.isHidden = true
        configActionButton(actionButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isFirstAppearance = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let width = size.width
        let height = size.height

        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else {
                return
            }

            if width > height {
                // Will enter landscape
                self.playerPanel.fullScreen = true
                self.headerViewHeightConstraint.constant = 0.0
//                self.headerViewContainerView.removeFromSuperview()
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            } else {
                // Will enter portrait
                self.playerPanel.fullScreen = false
                self.headerViewHeightConstraint.constant = 130
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }) { _ in

        }

        super.viewWillTransition(to: size, with: coordinator)
    }

    open func createPlayerPanel() -> PlayerPanel {
        return PlayerPanelCreator.createDefaultPlayerPanel()
    }

    open func createHeaderView() -> HeaderViewType {
        let header = UIView()
        return header as! HeaderViewType
    }

    open func configActionButton(_ button: UIButton) {
        button.isHidden = true
    }

    //MARK: HNPlayerPanelDelegate

    open func onPlay(_ play: Bool){
        // leaving this empty
    }

    open func playerDidChange(_ state: HNPlayState) {
        // leaving this empty
    }

    func playerDidChange(source: HNPlaySource) {

    }

    func onSnapshot() {

    }

    func onHighlight() {

    }

    func onHighlightCard() {

    }

    open func showControls(show:Bool, duration: TimeInterval) {

    }

    func onViewMode(_ viewMode: HNViewMode) {

    }

//    func onFullScreen(_ full: Bool) {
//        if full {
//            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
//        } else {
//            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
//        }
//    }
     func onFullScreen(_ full: Bool) {
//         layout(asLandscape: full)
         if full {
 //            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
             self.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight)
         } else {
             self.lockOrientation(.portrait, andRotateTo: .portrait)
 //            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
         }
     }
     

     func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
         
         if let delegate = UIApplication.shared.delegate as? AppDelegate {
             delegate.orientationLock = orientation
         }
     }
     
     /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
     func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
         
         self.lockOrientation(orientation)
         
         UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
         UINavigationController.attemptRotationToDeviceOrientation()
     }
     

    func onResolution(_ resolution: HNVideoResolution) {

    }

    func onSeekingBegan() {

    }

    func onSeeking() {

    }

    func onSeekingEnded() {

    }

    //MARK: Action

    @objc private func closeButtonTapped(_ sender: UIButton) {
        dismissMyself(animated: true)
    }
}



