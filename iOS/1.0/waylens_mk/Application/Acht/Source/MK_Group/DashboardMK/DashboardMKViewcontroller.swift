//
//  DashboardMKViewcontroller.swift
//  Acht
//
//  Created by TranHoangThanh on 8/30/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import Parchment

class DashboardMKViewcontroller: BaseViewController {

    @IBOutlet weak var viewChartCard: UIView!
    @IBOutlet weak var viewReport: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
     
    override func viewDidLoad() {
        super.viewDidLoad()
        let dashboardVC = DashboardViewController()
        self.embed(dashboardVC, inParent: self, inView: self.viewChartCard)
      
        // Do any additional setup after loading the view.
        
        let viewControllers = [
            
            ExportReportViewController(title: "B1.Hành trình xe chạy", index: 0, delegate: self),
            
            ExportReportViewController(title: "B2.Tốc độ của xe", index: 1,delegate: self),
            
            ExportReportViewController(title: "B3.Thời gian lái xe liên tục", index:2, delegate: self),
            
            ExportReportViewController(title: "B4.Dừng đỗ", index: 3,delegate: self),
            
            ExportReportViewController(title: "B5.Báo cáo tổng hợp", index: 4, delegate: self),
            
            ExportReportViewController(title: "B6.Chi tiết ảnh từ CMRGSHT", index: 5,delegate: self)
            
        ]

        let pagingViewController = PagingViewController(viewControllers: viewControllers)
        pagingViewController.menuItemSize = .fixed(width: 200 , height: 40)
        pagingViewController.selectedTextColor = UIColor.color(fromHex: ConstantMK.blueButton)
        pagingViewController.indicatorColor = UIColor.color(fromHex: ConstantMK.blueButton)
        
        pagingViewController.font = UIFont(name: SF_FONT_BOLD, size: 11) ?? UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.medium)
        pagingViewController.selectedFont = UIFont(name: SF_FONT_BOLD, size: 11) ?? UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.medium)

        // Make sure you add the PagingViewController as a child view
        // controller and constrain it to the edges of the view.
        addChild(pagingViewController)
        viewReport.addSubview(pagingViewController.view)
        viewReport.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.hideNavigationBar(animated: animated)
        self.title = "Báo cáo"
        self.showNavigationBar(animated: animated)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.viewChartCard {
                self.scrollView.isScrollEnabled = false
            } else {
                self.scrollView.isScrollEnabled = true
            }
            
        }
    }


    func embed(_ viewController:UIViewController, inParent controller:UIViewController, inView view:UIView){
       viewController.willMove(toParent: controller)
       viewController.view.frame = view.bounds
       view.addSubview(viewController.view)
       controller.addChild(viewController)
       viewController.didMove(toParent: controller)
    }

}

extension DashboardMKViewcontroller : ExportReportVCDelegate {
    func onClickViewSelectDate(show : Bool) {
        if show {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }else{
            self.scrollView.scrollToTop()
        }
    }
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
   }
}


import UIKit

extension UIView {
    func constrainCentered(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false

        let verticalContraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0
        )

        let horizontalContraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0
        )

        let heightContraint = NSLayoutConstraint(
            item: subview,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: subview.frame.height
        )

        let widthContraint = NSLayoutConstraint(
            item: subview,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: subview.frame.width
        )

        addConstraints([
            horizontalContraint,
            verticalContraint,
            heightContraint,
            widthContraint,
        ])
    }

    func constrainToEdges(_ subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false

        let topContraint = NSLayoutConstraint(
            item: subview,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0
        )

        let bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0
        )

        let leadingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0
        )

        let trailingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0
        )

        addConstraints([
            topContraint,
            bottomConstraint,
            leadingContraint,
            trailingContraint,
        ])
    }
}
