//
//  ViewControllerUtils.swift
//  Acht
//
//  Created by Chester Shen on 11/8/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import MJRefresh

extension UIViewController {

    fileprivate struct AssociatedKeys {
        static var emptyView: UInt8 = 8
    }

    var emptyView: HNSignBoard {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.emptyView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var signBoard = objc_getAssociatedObject(self, &AssociatedKeys.emptyView) as? HNSignBoard

            if signBoard == nil {
                signBoard = HNSignBoard(frame: CGRect(origin: .zero, size: view.frame.size))
                view.addSubview(signBoard!)
                signBoard?.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                objc_setAssociatedObject(self, &AssociatedKeys.emptyView, signBoard, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return signBoard!
        }
    }

    func showEmptyView(image: UIImage, title: String, detail: String) {
        emptyView.show(
            image: image,
            title: title,
            detail: detail,
            buttonTitle: nil
        )
    }

    func hideEmptyView() {
        emptyView.hide()
    }

}

extension UITableViewController {

    func setPullRefreshAction(_ refreshAction: Selector, loadMoreAction: Selector) {
        tableView.setPullRefreshAction(self, refreshAction: refreshAction, loadMoreAction: loadMoreAction)
    }

}
