//
//  SortBarLayout.swift
//  Fleet
//
//  Created by forkon on 2020/6/19.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

class SortBarLayout: ItemPickerViewLayout {
    private let margins: UIEdgeInsets

    init(margins: UIEdgeInsets) {
        self.margins = margins
    }

    func layout(titleLabel: UILabel, scrollView: UIScrollView, itemViews: [UIView]) {
        guard titleLabel.superview === scrollView.superview, let containingView = titleLabel.superview else {
            return
        }

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        containingView.layoutMargins = UIEdgeInsets(top: margins.top, left: margins.left, bottom: margins.bottom, right: 0.0)

        let layoutFrameDivider = RectDivider(rect: containingView.layoutMarginsGuide.layoutFrame)

        titleLabel.sizeToFit()

        titleLabel.frame = layoutFrameDivider.divide(atDistance: titleLabel.frame.width, from: CGRectEdge.minXEdge)

        let padding: CGFloat = 12.0

        // padding
        layoutFrameDivider.divide(atDistance: padding, from: CGRectEdge.minXEdge)

        scrollView.frame = layoutFrameDivider.remainder

        var layoutedItemViews: [UIView] = []

        let itemViewHeight: CGFloat = 23.0
        let itemViewY: CGFloat = (scrollView.frame.height - itemViewHeight) / 2

        itemViews.forEach { (itemView) in
            itemView.sizeToFit()
            itemView.frame.size.height = itemViewHeight
            itemView.frame.size.width += 20.0

            itemView.layer.cornerRadius = itemView.frame.height / 2

            if let lastLayoutedItemView = layoutedItemViews.last {
                itemView.frame.origin = CGPoint(x: lastLayoutedItemView.frame.maxX + padding, y: itemViewY)
            }
            else {
                itemView.frame.origin = CGPoint(x: 0.0, y: itemViewY)
            }

            layoutedItemViews.append(itemView)
        }

        if let lastLayoutedItemView = layoutedItemViews.last {
            scrollView.contentSize = CGSize(width: lastLayoutedItemView.frame.maxX + margins.right, height: scrollView.frame.height)
        }
    }

}
