//
//  ItemPickerView.swift
//  Acht
//
//  Created by forkon on 2020/6/11.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

protocol ItemPickerViewLayout {
    func layout(titleLabel: UILabel, scrollView: UIScrollView, itemViews: [UIView])
}

struct ItemPickerViewConfig {
    typealias ColorGenerator = () -> UIColor
    var itemBackgroundColor: ColorGenerator = { UIColor.semanticColor(.background(.primary)) }
    var itemTitleColor: ColorGenerator = { UIColor.semanticColor(.label(.secondary)) }
    var itemBorderColor: ColorGenerator = { UIColor.semanticColor(.border(.primary)) }
    var selectedItemBorderColor: ColorGenerator = { UIColor.semanticColor(.tint(.primary)) }
    var selectedItemTitleColor: ColorGenerator = { UIColor.semanticColor(.tint(.primary)) }
}

class ItemPickerView<T: Equatable & CustomStringConvertible>: UIView {
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "BeVietnamPro-Regular", size: 14.0)
        return titleLabel
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    private(set) var itemViews: [UIButton] = []

    private(set) var selectedItem: T?

    private let items: [T]
    private let selectedItemChangeHandler: (T) -> ()

    private let layout: ItemPickerViewLayout
    private let config: ItemPickerViewConfig
    

    init(
        frame: CGRect,
        layout: ItemPickerViewLayout,
        config: ItemPickerViewConfig = ItemPickerViewConfig(),
        items: [T],
        selectedItem: T?,
        selectedItemChangeHandler: @escaping (T) -> ()
    ) {
        self.layout = layout
        self.config = config
        self.items = items
        self.selectedItem = selectedItem
        self.selectedItemChangeHandler = selectedItemChangeHandler
        super.init(frame: frame)

        setup()
    }

    convenience init(
        frame: CGRect,
        layout: ItemPickerViewLayout,
        config: ItemPickerViewConfig = ItemPickerViewConfig(),
        items: [T],
        selectedItemChangeHandler: @escaping (T) -> ()
    ) {
        self.init(
            frame: frame,
            layout: layout,
            items: items,
            selectedItem: items.first,
            selectedItemChangeHandler: selectedItemChangeHandler
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
        layout.layout(titleLabel: titleLabel, scrollView: scrollView, itemViews: itemViews)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                updateUI()
            }
        }
    }

    @objc
    private func buttonTapped(_ sender: UIButton) {
        selectedItem = items[sender.tag]
        selectedItemChangeHandler(selectedItem!)
        updateUI()
    }
}

//MARK: - Private

private extension ItemPickerView {

    func setup() {
       
        addSubview(titleLabel)
        addSubview(scrollView)

        for (i, item) in items.enumerated() {
            let mainScreenWidth = UIScreen.main.bounds.width
            let button = UIButton(type: .custom)
            button.titleLabel?.font = UIFont(name: "BeVietnamPro-Regular", size:mainScreenWidth >= 428 ? 14.0 : (mainScreenWidth <= 375 ? 11.5 : 12.0))
            button.setTitle(item.description, for: .normal)

            button.layer.borderWidth = 1.0
            button.layer.masksToBounds = true

            button.tag = i

            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

            scrollView.addSubview(button)
            itemViews.append(button)
        }

        updateUI()
        setNeedsLayout()
    }

    func updateUI() {
        for (i, button) in itemViews.enumerated() {
            button.backgroundColor = config.itemBackgroundColor()
            
            
            if items[i] == selectedItem {
                button.setTitleColor(config.selectedItemTitleColor(), for: .normal)
                button.layer.borderColor = config.selectedItemBorderColor().cgColor
            } else {
                button.setTitleColor(config.itemTitleColor(), for: .normal)
                button.layer.borderColor = config.itemBorderColor().cgColor
            }
        }
    }
}
