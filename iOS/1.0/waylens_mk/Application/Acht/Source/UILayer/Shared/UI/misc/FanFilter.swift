//
//  FanFilter.swift
//  Acht
//
//  Created by Chester Shen on 6/22/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class FanFilter: UIControl {
    struct Item {
        var image: UIImage
        var highlightedImage: UIImage
        var selectedImage: UIImage
        var title: String
        var color: UIColor
        var lightButton: UIButton?
    }
    let maskBackgroundColor = UIColor.semanticColor(.background(.mask))
    let frontFanRadius: CGFloat = 124
    let backFanRadius: CGFloat = 230
    var isOpen = false
    var originalButton = UIButton()
    var isExpandedViewInitialized = false
    lazy var contentView = UIView()
    lazy var backFan = UIView()
    lazy var frontFan = UIView()
    lazy var closeButton = UIButton()
    lazy var countLabel = UILabel()
    lazy var titleLabel = UILabel()
    
    var items: [Item] = []
    var selectedIndex:Int = 0 {
        didSet {
            onSelectItem()
        }
    }
    
    var count: Int = 0 {
        didSet {
            countLabel.text = "\(count)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        finishInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        finishInit()
    }
    
    private func finishInit() {
        backgroundColor = .clear
        originalButton.layer.cornerRadius = bounds.width / 2
        originalButton.layer.masksToBounds = true
        addSubview(originalButton)
        originalButton.frame = bounds
        originalButton.addTarget(self, action: #selector(onExpand), for: .touchUpInside)
    }
    
    func addItem(title:String, image: UIImage, highlighted: UIImage, selected: UIImage, color: UIColor) {
        let item = Item(image: image, highlightedImage: highlighted, selectedImage: selected, title: title, color: color, lightButton: nil)
        items.append(item)
        collapsedLayout()
    }
    
    func initExpandedView() {
        guard let window = window else { return }
        window.addSubview(contentView)
        backFan.layer.masksToBounds = true
        backFan.backgroundColor = .white
        backFan.addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil))
        frontFan.layer.masksToBounds = true
        closeButton.setImage(#imageLiteral(resourceName: "btn_close_n"), for: .normal)
        closeButton.addTarget(self, action: #selector(onCollapse), for: .touchUpInside)
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCollapse)))
        contentView.frame = window.bounds
        contentView.addSubview(backFan)
        contentView.addSubview(frontFan)
        contentView.addSubview(closeButton)
        countLabel.font = UIFont.systemFont(ofSize: 144, weight: .bold)
        countLabel.textColor = .white
        contentView.addSubview(countLabel)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        countLabel.heightAnchor.constraint(equalToConstant: countLabel.font.pointSize).isActive = true
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor).isActive = true
        
        for i in 0..<items.count {
            let lightButton = UIButton(frame: bounds)
//            let image = item.image.withRenderingMode(.alwaysTemplate)
            lightButton.setImage(items[i].image, for: .normal)
            lightButton.setImage(items[i].highlightedImage, for: .selected)
            lightButton.setImage(items[i].highlightedImage, for: .highlighted)
            lightButton.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)
            lightButton.addTarget(self, action: #selector(onTouchButton(_:)), for: .touchDown)
            lightButton.tag = i
            contentView.insertSubview(lightButton, aboveSubview: frontFan)
            items[i].lightButton = lightButton
        }
        onHighlightItem(selectedIndex)
        isExpandedViewInitialized = true
    }
    
    func commonLayout() {
        guard let window = window else { return }
        contentView.frame = window.bounds
    }
    
    func collapsedLayout() {
        guard let window = window else { return }
        commonLayout()
        contentView.backgroundColor = .clear
        let convertedFrame = self.convert(self.bounds, to: window)
        frontFan.frame = convertedFrame
        frontFan.layer.cornerRadius = convertedFrame.width / 2
        frontFan.backgroundColor = UIColor.clear
        backFan.frame = convertedFrame
        backFan.layer.cornerRadius = convertedFrame.width / 2
        var i = 0
        for item in items {
//            if i == selectedIndex {
//                item.lightButton?.setImage(item.selectedImage, for: .selected)
//            } else {
                item.lightButton?.alpha = 0
//            }
            item.lightButton?.frame = convertedFrame
            i += 1
        }
        closeButton.frame = CGRect(x: convertedFrame.midX, y: convertedFrame.midY, width: 0, height: 0)
        closeButton.alpha = 0
        titleLabel.alpha = 0
        countLabel.alpha = 0
    }
    
    func expandedLayout() {
        guard let window = window else { return }
        commonLayout()
        contentView.backgroundColor = UIColor.semanticColor(.background(.mask))
        let convertedFrame = self.convert(self.bounds, to: window)
        let center = CGPoint(x: 0, y: convertedFrame.maxY + convertedFrame.minX)
        frontFan.frame = CGRect(x: center.x - frontFanRadius, y: center.y - frontFanRadius, width: 2 * frontFanRadius, height: 2 * frontFanRadius)
        frontFan.layer.cornerRadius = frontFanRadius
        frontFan.backgroundColor = items[selectedIndex].color
        backFan.frame = CGRect(x: center.x - backFanRadius, y: center.y - backFanRadius, width: 2 * backFanRadius, height: 2 * backFanRadius)
        backFan.layer.cornerRadius = backFanRadius
        
        var i:Double = 0
        let r:CGFloat = (backFanRadius + frontFanRadius) / 2
        for item in items {
            item.lightButton?.alpha = 1
            let a = Double.pi / (2 * Double(items.count)) * (i + 0.5)
            let ix = center.x + r * CGFloat(sin(a)) - bounds.width / 2
            let iy = center.y - r * CGFloat(cos(a)) - bounds.height / 2
            item.lightButton?.frame = CGRect(x:ix, y: iy, width: bounds.width, height: bounds.height)
            i += 1
        }
        closeButton.frame = convertedFrame
        closeButton.alpha = 1
        titleLabel.alpha = 1
        countLabel.alpha = 1
    }
    
    func onHighlightItem(_ index: Int) {
        guard index < items.count else { return }
        frontFan.backgroundColor = items[index].color
//        contentView.bringSubview(toFront: button)
        for i in 0..<items.count {
            if let button = items[i].lightButton {
                button.isHighlighted = i == index
                button.isSelected = false
            }
        }
    }
    
    func onSelectItem() {
        guard selectedIndex < items.count else { return }
        onHighlightItem(selectedIndex)
        for i in 0..<items.count {
            if let button = items[i].lightButton {
                button.isSelected = i == selectedIndex
            }
        }
        titleLabel.text = items[selectedIndex].title
//        onCollapse()
        originalButton.setImage(items[selectedIndex].selectedImage, for: .normal)
    }
    
    @objc func onTapButton(_ sender: UIButton) {
        selectedIndex = sender.tag
        sendActions(for: .valueChanged)
    }
    
    @objc func onTouchButton(_ sender: UIButton) {
        onHighlightItem(sender.tag)
    }
    
    @objc func onExpand() {
        if !isExpandedViewInitialized {
            initExpandedView()
        }
        contentView.isHidden = false
        collapsedLayout()
        UIView.animate(withDuration: 0.3) {
            self.expandedLayout()
        }
    }
    
    @objc func onCollapse() {
        UIView.animate(withDuration: 0.3, animations: {
            self.collapsedLayout()
        }) { (completed) in
            if completed {
                self.contentView.isHidden = true
            }
        }
    }
    
}
