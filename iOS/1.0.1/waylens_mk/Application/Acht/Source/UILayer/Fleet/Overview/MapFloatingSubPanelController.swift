//
//  MapFloatingSubPanelController.swift
//  Acht
//
//  Created by forkon on 2019/9/24.
//  Copyright © 2019 Maxim Bilan. All rights reserved.
//

import UIKit
import FloatingPanel
import MapKit

class MapFloatingSubPanelController: UIViewController {

    open lazy private(set) var floatingPanelLayout: FloatingPanelLayout = FloatingSubPanelLayout(positionConfigs: positionConfigs)

    open var positionConfigs: [FloatingSubPanelLayout.PositionConfig] {
        return [FloatingSubPanelLayout.PositionConfig(postion: .tip, inset: self.view.frame.height)]
    }

    var previousSubPanel: MapFloatingSubPanelController? {
        return presentingViewController as? MapFloatingSubPanelController
    }

    var nextSubPanel: MapFloatingSubPanelController? {
        return presentedViewController as? MapFloatingSubPanelController
    }

    open lazy var position: FloatingPanelPosition = self.floatingPanelLayout.initialPosition

    weak var delegate: MapActionCoordination? = nil
    open var isActive: Bool = false

    var userNeverTouchedMap: Bool = true
    var currentRegion: MKCoordinateRegion? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        definesPresentationContext = true
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // first time present or go back
        if (parentPanel?.lastSubPanel == self) || (parentPanel?.lastSubPanel == nextSubPanel && nextSubPanel?.isActive == false) {
            isActive = true
        }

        if isActive {
            delegate?.viewControllerWillPresent(self)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        isActive = false
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    override func removeFromParent() {
        super.removeFromParent()

        // All MapFloatingSubPanelControllers presented must be dismissed when their parents are removed, if you don't do that, it will cause a memory leak.
        dismiss(animated: true, completion: nil)
    }

}

extension MapFloatingSubPanelController {

    var parentPanel: MapFloatingPanelController? {
        var subPanel = previousSubPanel

        if subPanel == nil {
            return parent as? MapFloatingPanelController
        } else {
            while subPanel?.previousSubPanel != nil {
                subPanel = subPanel?.previousSubPanel
            }

            return subPanel?.parent as? MapFloatingPanelController
        }
    }

}

extension MapFloatingSubPanelController: Themed {

    @objc func applyTheme() {
        view.backgroundColor = UIColor.semanticColor(.mapFloatingPanelBackground)
    }
    
}

class FloatingSubPanelLayout: FloatingPanelLayout {

    struct PositionConfig {
        var postion: FloatingPanelPosition
        var inset: CGFloat
    }

    var supportedPositions: Set<FloatingPanelPosition> {
        return Set(positionConfigs.map{$0.postion})
    }

    public var initialPosition: FloatingPanelPosition {
        return .tip
    }

    private(set) var positionConfigs: [PositionConfig] = []

    init(positionConfigs: [PositionConfig]) {
        self.positionConfigs = positionConfigs
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        return positionConfigs.first(where: {$0.postion == position})?.inset
    }

}
