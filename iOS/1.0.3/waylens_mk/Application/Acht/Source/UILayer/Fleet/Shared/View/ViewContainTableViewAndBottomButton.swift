//
//  ViewContainTableViewAndBottomButton.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ViewContainTableViewAndBottomButton: UIView {
    private(set) var tableView: UITableView!

    private var itemViews: [UIView] = []

    init() {
        super.init(frame: CGRect.zero)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        tableView.removeObserver(self, forKeyPath: #keyPath(UITableView.contentSize))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrameDivider = RectDivider(rect:
            bounds.inset(by:
                UIEdgeInsets(
                    top: layoutMargins.top,
                    left: 0.0,
                    bottom: 0.0,
                    right: 0.0
                )
            )
        )

        let bottomMargin = layoutMargins.bottom != 0 ? layoutMargins.bottom : layoutMargins.left

        if !itemViews.isEmpty {
            layoutFrameDivider.divide(atDistance: bottomMargin, from: .maxYEdge)
        }

        let bottomItemViewPadding: CGFloat = 10.0
        var bottomItemViewsAreaHeight: CGFloat = 0.0

        if !itemViews.isEmpty {
            // sum itemView height
            bottomItemViewsAreaHeight += itemViews.reduce(0.0){$0 + $1.frame.height}
            // sum all padding
            bottomItemViewsAreaHeight += max(CGFloat(itemViews.count - 1), 0) * bottomItemViewPadding
            bottomItemViewsAreaHeight += bottomMargin
        }

        let preferredBottomItemViewsAreaHeight = layoutFrameDivider.remainder.height * 0.2

        if tableView.contentSize.height + bottomItemViewsAreaHeight > layoutFrameDivider.remainder.height {
            itemViews.reversed().forEach { (itemView) in
                let itemViewHeight = itemView.frame.height
                itemView.frame = layoutFrameDivider.divide(atDistance: itemViewHeight, from: .maxYEdge).inset(by: UIEdgeInsets(top: 0.0, left: layoutMargins.left, bottom: 0.0, right: layoutMargins.right))

                if itemView == itemViews.first {
                    layoutFrameDivider.divide(atDistance: bottomMargin, from: .maxYEdge)
                }
                else {
                    layoutFrameDivider.divide(atDistance: bottomItemViewPadding, from: .maxYEdge)
                }
            }

            tableView.frame = layoutFrameDivider.remainder
        }
        else {
            if itemViews.isEmpty || bottomItemViewsAreaHeight > preferredBottomItemViewsAreaHeight {
                itemViews.reversed().forEach { (itemView) in
                    let itemViewHeight = itemView.frame.height
                    itemView.frame = layoutFrameDivider.divide(
                        atDistance: itemViewHeight,
                        from: .maxYEdge
                    ).inset(by: UIEdgeInsets(top: 0.0, left: layoutMargins.left, bottom: 0.0, right: layoutMargins.right))

                    if itemView == itemViews.first {
                        layoutFrameDivider.divide(atDistance: bottomMargin, from: .maxYEdge)
                    }
                    else {
                        layoutFrameDivider.divide(atDistance: bottomItemViewPadding, from: .maxYEdge)
                    }
                }

                tableView.frame = layoutFrameDivider.remainder
            }
            else {
                tableView.frame = layoutFrameDivider.divide(atDistance: tableView.contentSize.height, from: .minYEdge)

                let bottomItemViewsAreaDivider: RectDivider

                if layoutFrameDivider.remainder.height > preferredBottomItemViewsAreaHeight {
                    bottomItemViewsAreaDivider = RectDivider(rect: layoutFrameDivider.divide(atDistance: preferredBottomItemViewsAreaHeight, from: .maxYEdge))
                }
                else {
                    bottomItemViewsAreaDivider = RectDivider(rect: layoutFrameDivider.remainder)
                }

                itemViews.forEach { (itemView) in
                    if itemView == itemViews.first {
                        bottomItemViewsAreaDivider.divide(atDistance: bottomMargin, from: .minYEdge)
                    }
                    else {
                        bottomItemViewsAreaDivider.divide(atDistance: bottomItemViewPadding, from: .minYEdge)
                    }

                    let itemViewHeight = itemView.frame.height
                    itemView.frame = bottomItemViewsAreaDivider.divide(
                        atDistance: itemViewHeight,
                        from: .minYEdge
                    ).inset(by: UIEdgeInsets(top: 0.0, left: layoutMargins.left, bottom: 0.0, right: layoutMargins.right))
                }
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UITableView.contentSize) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                self.setNeedsLayout()
            }
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

    func addBottomItemView(_ itemView: UIView, height: CGFloat = 50.0) {
        itemView.frame.size.height = height
        itemViews.append(itemView)
        addSubview(itemView)
        setNeedsLayout()
    }

    func removeAllBottomItemViews() {
        itemViews.forEach {
            $0.removeFromSuperview()
        }

        itemViews.removeAll()

        setNeedsLayout()
    }

}

//MARK: - Private

private extension ViewContainTableViewAndBottomButton {

    func setup() {
        tableView = TableViewFactory.makeGroupedTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.showsVerticalScrollIndicator = false
        addSubview(tableView)

        applyTheme()

        tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), options: .new, context: nil)
    }

}

extension ViewContainTableViewAndBottomButton: Themed {

    @objc func applyTheme() {
        tableView.backgroundColor = UIColor.clear

        if tableView.dataSource != nil {
            tableView.reloadData()
        }
    }

}
