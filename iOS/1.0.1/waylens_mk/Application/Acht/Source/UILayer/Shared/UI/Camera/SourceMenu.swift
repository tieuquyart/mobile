//
//  SourceMenu.swift
//  Acht
//
//  Created by forkon on 2018/9/13.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

enum SourceMenuItemType: Equatable {
    case localLive
    case localLiveRecording
    case remoteLive(HNSignalStatus?)
    case localPlayback
    case remotePlayback
    case offline
    case unknow
    
    var isLive: Bool {
        switch self {
        case .localLive, .localLiveRecording, .remoteLive(_):
            return true
        default:
            return false
        }
    }
}

func ==(lhs: SourceMenuItemType, rhs: SourceMenuItemType) -> Bool {
    switch (lhs, rhs) {
    case (.localLive, .localLive):
        return true
    case (.localLiveRecording, .localLiveRecording):
        return true
    case (.localPlayback, .localPlayback):
        return true
    case (.remotePlayback, .remotePlayback):
        return true
    case (.offline, .offline):
        return true
    case (.unknow, .unknow):
        return true
    case (.remoteLive(_), .remoteLive(_)):
        return true
    default:
        return false
    }
}

class SourceMenu: UIControl {
    
    enum Config {
        static let defaultWidth: CGFloat = 110.0
        static let headerHeight: CGFloat = 24.0
        static let itemViewsTopPadding: CGFloat = 1.0
        static let itemViewHeight: CGFloat = 40.0
    }

    fileprivate var isExpandable: Bool = false {
        didSet {
            isExpanded = false
        }
    }
    fileprivate var isExpanded: Bool = false

    fileprivate var header: SourceMenuHeader!
    fileprivate var itemViews: [SourceMenuItemView] = []
    fileprivate var itemViewsContainingView: UIView!

    fileprivate var isShownAsTitleView: Bool = false
    fileprivate weak var targetViewController: UIViewController? = nil
    fileprivate weak var popoverVC: UIViewController?
    var headerIconView: UIImageView {
        return header.iconView
    }
    
    var items: [SourceMenuItemType] = [.localPlayback, .remotePlayback] {
        didSet {
            isExpandable = (items.count > 1 && isUserInteractionEnabled)
            if !items.contains(selectedItem) {
                selectedItem = items.first ?? .unknow
            }
            
            popoverVC?.dismiss(animated: true, completion: nil)
        }
    }
    
    var selectedItem: SourceMenuItemType = .localPlayback {
        didSet {
            isExpanded = false
            updateUI()
        }
    }

    override var isUserInteractionEnabled: Bool {
        didSet {
            isExpandable = false
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        header.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: Config.headerHeight)

        if isShownAsTitleView {
            if let itemViewsContainingViewSuperView = itemViewsContainingView.superview {
                itemViewsContainingView.frame = itemViewsContainingViewSuperView.bounds
            }
        } else {
            itemViewsContainingView.frame.origin = CGPoint(x: 0.0, y: header.frame.maxY + Config.itemViewsTopPadding)
            itemViewsContainingView.frame.size = CGSize(width: bounds.width, height: bounds.height - itemViewsContainingView.frame.origin.y)
        }
        
        for (i, itemView) in itemViews.enumerated() {
            itemView.frame = CGRect(x: 0.0, y: CGFloat(i) * Config.itemViewHeight, width: bounds.width, height: Config.itemViewHeight)
        }
    }
    
    func show(in containingView: UIView) {
        popoverVC?.dismiss(animated: false, completion: nil)
        targetViewController?.navigationItem.titleView = nil
        targetViewController = nil
        isShownAsTitleView = false
        
        itemViewsContainingView.removeFromSuperview()
        addSubview(itemViewsContainingView)

        self.removeFromSuperview()
        containingView.addSubview(self)
        
        isExpanded = false
        updateUI()
    }
    
    func show(asTitleViewOf viewController: UIViewController) {
        alpha = 1.0
        
        targetViewController?.navigationItem.titleView = nil
        targetViewController = viewController
        isShownAsTitleView = true
        
        itemViewsContainingView.removeFromSuperview()
        removeFromSuperview()
        viewController.navigationItem.titleView = self
        
        isExpanded = false
        updateUI()
    }
    
}

extension SourceMenu {
    
    fileprivate func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        header = SourceMenuHeader()
        header.addTarget(self, action: #selector(headerTapped), for: .touchUpInside)
        addSubview(header)
        
        itemViewsContainingView = UIView()
        itemViewsContainingView.backgroundColor = UIColor.clear
    }
    
    fileprivate func updateUI() {
        updateHeader()
        
        itemViews.forEach { (itemView) in
            itemView.removeFromSuperview()
        }
        itemViews.removeAll()
        for (i, item) in items.enumerated() {
            let itemView = SourceMenuItemView()
            
            itemView.item = item
            
            if item == selectedItem {
                itemView.isSelected = true
            } else {
                itemView.isSelected = false
            }

            if isShownAsTitleView {
                itemView.color = UIColor.clear
                itemView.textColor = UIColor.black
                itemView.accessoryView.setTemplateImage(itemView.accessoryView.image, color: UIColor.black)
                itemView.roundedCorners = nil
            } else {
                itemView.color = UIColor.semanticColor(.background(.maskLight))
                itemView.textColor = UIColor.white
                itemView.accessoryView.setTemplateImage(itemView.accessoryView.image, color: UIColor.white)

                if i == items.count - 1 {
                    itemView.roundedCorners = [.bottomLeft, .bottomRight]
                } else {
                    itemView.roundedCorners = nil
                }
            }
            
            itemView.addTarget(self, action: #selector(itemViewTapped(_:)), for: .touchUpInside)
            
            itemViews.append(itemView)
            itemViewsContainingView.addSubview(itemView)
        }
        
        removeConstraints(constraints)
        
        if isShownAsTitleView {
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: Config.defaultWidth),
                heightAnchor.constraint(equalToConstant: Config.headerHeight)
            ])
        } else {
            var height: CGFloat = Config.headerHeight
            if isExpanded {
                height = Config.headerHeight + Config.itemViewsTopPadding + Config.itemViewHeight * CGFloat(items.count)
            }

            if let superview = superview {
                if superview.frame.height > Config.headerHeight && superview.frame.width > Config.defaultWidth {
                    transform = CGAffineTransform.identity
                    NSLayoutConstraint.activate([
                        widthAnchor.constraint(equalToConstant: Config.defaultWidth),
                        heightAnchor.constraint(equalToConstant: height),
                        topAnchor.constraint(equalTo: superview.topAnchor, constant: 27.0),
                        centerXAnchor.constraint(equalTo: superview.centerXAnchor)
                    ])
                } else {
                    let scale = superview.frame.height / Config.headerHeight
                    transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
                    NSLayoutConstraint.activate([
                        widthAnchor.constraint(equalToConstant: Config.defaultWidth),
                        heightAnchor.constraint(equalToConstant: height),
                        topAnchor.constraint(equalTo: superview.topAnchor, constant: 0.0),
                        centerXAnchor.constraint(equalTo: superview.centerXAnchor)
                    ])
                }
            }
        }
        
        setNeedsLayout()
    }
    
    fileprivate func updateHeader() {
        header.isExpandable = isExpandable
        header.isExpanded = isExpanded
        header.item = selectedItem

        if isShownAsTitleView {
            header.color = UIColor.clear
            header.textColor = UIColor.black
            header.roundedCorners = nil
            header.accessoryView.setTemplateImage(header.accessoryView.image, color: UIColor.black)
        } else {
            header.color = UIColor.semanticColor(.background(.maskLight))
            header.textColor = UIColor.white
            header.accessoryView.setTemplateImage(header.accessoryView.image, color: UIColor.white)
        }
    }
    
    @objc fileprivate func headerTapped() {
        if !isExpandable {
            return
        }
        
        isExpanded = !isExpanded
        
        if isShownAsTitleView, let targetViewController = targetViewController {
            let popoverVC = UIViewController()
            popoverVC.view.addSubview(itemViewsContainingView)
            
            targetViewController.popout(
            popoverVC,
            preferredContentSize: CGSize(width: Config.defaultWidth, height: Config.itemViewHeight * CGFloat(items.count)),
            from: targetViewController.navigationController!.navigationBar,
            didPresent: { [weak self] in
                self?.popoverVC = popoverVC
            }) {[weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.isExpanded = false
                strongSelf.updateUI()
            }
        }
        
        updateUI()
    }
    
    @objc fileprivate func itemViewTapped(_ sender: SourceMenuItemView) {
        selectedItem = sender.item
        sendActions(for: .valueChanged)
        
        if isShownAsTitleView {
            popoverVC?.dismiss(animated: true, completion: nil)
        }
    }
    
}

fileprivate class SourceMenuHeader: SourceMenuItemView {
    fileprivate var isExpandable: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    var isExpanded: Bool = false {
        didSet {
            roundedCorners = isExpanded ? [.topLeft, .topRight] : .allCorners
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.sizeToFit()

        if isExpandable {
            accessoryView.isHidden = false
            
            iconView.frame.origin.x = (accessoryView.frame.minX - (iconView.frame.width + Config.padding + label.frame.width)) / 2
            if iconView.image == nil {
                if color == UIColor.clear { // use in navigation bar
                    label.frame.origin.x = (bounds.width - (label.frame.width + Config.padding * 4 + accessoryView.frame.width)) / 2
                    accessoryView.frame.origin.x = label.frame.maxX + Config.padding * 4
                } else {
                    label.frame.origin.x = (accessoryView.frame.minX - label.frame.width) / 2
                }
            } else {
                label.frame.origin.x = iconView.frame.maxX + Config.padding
            }
        } else {
            accessoryView.isHidden = true
            
            if let owner = owner(), owner.isShownAsTitleView {
                label.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
                iconView.frame.origin.x = label.frame.origin.x - Config.padding - 2.0 - iconView.frame.width
            } else {
                iconView.frame.origin.x = (bounds.width - (iconView.frame.width + Config.padding + label.frame.width)) / 2
                if iconView.image == nil {
                    label.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
                } else {
                    label.frame.origin.x = iconView.frame.maxX + Config.padding
                }
            }
        }
    }
    
    override func updateUI() {
        super.updateUI()
        
        if isExpandable && isExpanded {
            accessoryView.image = #imageLiteral(resourceName: "up arrow")
        } else {
            accessoryView.image = #imageLiteral(resourceName: "down arrow")
        }
    }
}

fileprivate class SourceMenuItemView: UIControl {
    enum Config {
        static let margin: CGFloat = 8.0
        static let iconSize: CGSize = CGSize(width: 20.0, height: 20.0)
        static let textFontSize: CGFloat = 13.0
        static let padding: CGFloat = 2.0
    }
    
    private var shapeLayer: CAShapeLayer!
    
    var item: SourceMenuItemType = .localLive {
        didSet {
            updateUI()
        }
    }
    var roundedCorners: UIRectCorner? = nil {
        didSet {
            setNeedsLayout()
        }
    }
    var color: UIColor = UIColor.semanticColor(.background(.maskLight)) {
        didSet {
            shapeLayer.fillColor = color.cgColor
        }
    }
    var textColor: UIColor {
        set {
            label.textColor = newValue
        }
        get {
            return label.textColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateUI()
        }
    }

    private(set) var iconView: UIImageView!
    private(set) var label: UILabel!
    private(set) var accessoryView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let roundedCorners = roundedCorners {
            let cornerRadii = min(12.0, bounds.height / 2)
            shapeLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundedCorners, cornerRadii: CGSize(width: cornerRadii, height: cornerRadii)).cgPath
        } else {
            shapeLayer.path = UIBezierPath(rect: bounds).cgPath
        }
        
        let centerY = bounds.height / 2
        iconView.frame = CGRect(x: Config.margin, y: 0.0, width: Config.iconSize.width, height: Config.iconSize.height)
        iconView.center.y = centerY
        
        label.frame = CGRect(
            x: iconView.frame.maxX + Config.padding,
            y: 0.0,
            width: 55.0,
            height: 16.0
        )
        label.center.y = centerY
        
        accessoryView.frame = CGRect(
            x: bounds.width - Config.margin - Config.iconSize.width,
            y: 0.0,
            width: Config.iconSize.width,
            height: Config.iconSize.height
        )
        accessoryView.center.y = centerY
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
        
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = color.cgColor
        layer.addSublayer(shapeLayer)
        
        iconView = UIImageView()
        iconView.contentMode = .center
        iconView.isUserInteractionEnabled = false
        addSubview(iconView)
        
        label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: Config.textFontSize)
        label.textColor = UIColor.white
        label.isUserInteractionEnabled = false
        addSubview(label)
        
        accessoryView = UIImageView()
        accessoryView.contentMode = .center
        accessoryView.isUserInteractionEnabled = false
        addSubview(accessoryView)
    }
    
    func updateUI() {
        switch item {
        case .localLive:
            iconView.image = nil
            label.text = NSLocalizedString("live_wifi", comment: "Live")
        case .localLiveRecording:
            iconView.image = #imageLiteral(resourceName: "wifi_live_recording_dot")
            label.text = NSLocalizedString("live_wifi", comment: "Live")
        case .remoteLive(let signalStatus):
            iconView.setSignalImage(signalStatus: signalStatus)
            label.text = NSLocalizedString("4G Live", comment: "4G Live")
        case .localPlayback:
            iconView.image = #imageLiteral(resourceName: "sd card_icon_blue")
            label.text = NSLocalizedString("SD Card", comment: "SD Card")
        case .remotePlayback:
            iconView.image = #imageLiteral(resourceName: "cloud_icon_blue")
            label.text = NSLocalizedString("Cloud", comment: "Cloud")
        case .offline:
            iconView.image = #imageLiteral(resourceName: "offline_icon")
            label.text = NSLocalizedString("Offline", comment: "Offline")
        default:
            break
        }
        
        if isSelected {
            accessoryView.image = #imageLiteral(resourceName: "circle_icon")
        } else {
            accessoryView.image = nil
        }
    }
    
}

extension SourceMenuItemView {
    
    func owner() -> SourceMenu? {
        if superview == nil {
            return nil
        } else {
            if let sourceMenu = superview as? SourceMenu {
                return sourceMenu
            } else {
                return owner()
            }
        }
    }
    
}
