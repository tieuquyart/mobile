//
//  SecureEsNetworkSetupWayRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

enum SecureEsNetworkSetupWay: CaseIterable, CustomStringConvertible {
    case throughMiFiHotspot
    case throughMobilePhoneHotspot

    var description: String {
        switch self {
        case .throughMiFiHotspot:
            return NSLocalizedString("Connect to the internet through the MiFi hotspots included in the package.", comment: "Connect to the internet through the MiFi hotspots included in the package.")
        case .throughMobilePhoneHotspot:
            return NSLocalizedString("Connect to the internet through the hotspots of the driver's mobile phone.", comment: "Connect to the internet through the hotspots of the driver's mobile phone.")
        }
    }

}

class SecureEsNetworkSetupWayRootView: FlowStepRootView<MenuContentView> {
    weak var ixResponder: SecureEsNetworkSetupWayIxResponder?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        title = NSLocalizedString("Please select the way to connect internet.", comment: "Please select the way to connect internet.")
        progressLabel.text = ""
        actionButton.isHidden = true
    }

}



private extension SecureEsNetworkSetupWayRootView {

}

extension SecureEsNetworkSetupWayRootView: SecureEsNetworkSetupWayUserInterface {

    func render(newState: SecureEsNetworkSetupWayViewControllerState) {
        contentView.itemViews = SecureEsNetworkSetupWay.allCases.map({ (setupWay) -> UIView in
            let itemView = MenuItemView()
            itemView.textLabel?.text = setupWay.description
            itemView.selectionHandler = {[weak self] in
                self?.ixResponder?.select(setupWay: setupWay)
            }
            return itemView
        })
    }

}

class MenuContentView: UIView {
    var itemViews: [UIView] = [] {
        didSet {
            itemViews.forEach { (v) in
                v.removeFromSuperview()
                scrollView.addSubview(v)
            }
            setNeedsLayout()
        }
    }

    private let scrollView: UIScrollView = {
        $0.isScrollEnabled = true
        $0.clipsToBounds = false
        return $0
    }(UIScrollView())

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        scrollView.frame.size.width = bounds.width

        var itemViewOriginY: CGFloat = 0.0
        let padding: CGFloat = 30.0
        for itemView in itemViews {
            itemView.frame.size.width = scrollView.frame.width
            itemView.frame.size.height = itemView.sizeThatFits(CGSize(width: itemView.frame.width, height: bounds.height)).height + 20.0
            itemView.frame.origin = CGPoint(x: 0.0, y: itemViewOriginY)
            itemViewOriginY += itemView.frame.height

            if itemView !== itemViews.last {
                itemViewOriginY += padding
            }
        }

//        if itemViewOriginY > bounds.height {
            scrollView.frame.size.height = bounds.height
            scrollView.frame.origin = CGPoint.zero
//        }
//        else {
//            scrollView.frame.size.height = itemViewOriginY
//            scrollView.frame.origin = CGPoint(x: 0.0, y: (bounds.height - itemViewOriginY) / 2)
//        }
    }

    private func setup() {
        clipsToBounds = false
        addSubview(scrollView)
    }
}

class MenuItemView: UITableViewCell {

    var selectionHandler: (() -> ())? = nil

    init() {
        super.init(style: .default, reuseIdentifier: nil)
        textLabel?.numberOfLines = 0

        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 3.0
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 1.0

        applyTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme() {
        if #available(iOS 13.0, *) {
            backgroundColor = UIColor.secondarySystemGroupedBackground
        } else {
            backgroundColor = UIColor.white
        }

        textLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)

        if isSelected {
            textLabel?.textColor = UIColor.black
            layer.borderColor = UIColor.black.cgColor
        } else {
            textLabel?.textColor = UIColor.black
            layer.borderColor = UIColor.clear.cgColor
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        applyTheme()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        setSelected(true, animated: false)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        setSelected(false, animated: false)
        selectionHandler?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        setSelected(false, animated: false)
    }

}
