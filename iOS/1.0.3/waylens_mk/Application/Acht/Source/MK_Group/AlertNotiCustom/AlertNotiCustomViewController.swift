//
//  AlertNotiCustomViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 1/4/23.
//  Copyright © 2023 waylens. All rights reserved.
//

import UIKit

class AlertNotiCustomViewController: UIViewController {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnOK: UIButton!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    var item : UpdateMK!
    @IBOutlet weak var btnClose: UIButton!
    
    func createCornerRadius(for views: UIButton..., radius: CGFloat) {
        // create border for many views or a view
        for view in views {
            view.layer.cornerRadius = radius
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        if item.forceUpdate! {
            self.btnCancel.isHidden = true
            self.btnClose.isHidden = true
        } else {
            self.btnCancel.isHidden = false
            self.btnClose.isHidden = false
        }
        
        self.createCornerRadius(for: btnOK,btnCancel, radius: 5)
        // Do any additional setup after loading the view.
        setBorderView(view: self.viewContainer)
     

    }

  
    
    
    
    @IBAction func btnClose(_ sender: Any) {
        self.remove(asChildViewController: self)
    }
 
    
    func remove(asChildViewController childController: UIViewController) -> Void {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
    }
    

    @IBAction func btnOk(_ sender: Any) {
        if let url = URL(string: item.storeUrl ?? "")
        {
                   if #available(iOS 10.0, *) {
                      UIApplication.shared.open(url, options: [:], completionHandler: nil)
                   }
                   else {
                         if UIApplication.shared.canOpenURL(url as URL) {
                            UIApplication.shared.openURL(url as URL)
                        }
                   }
        }
    }
    
    
    @IBAction func btnCancel(_ sender: Any) {
        self.remove(asChildViewController: self)
       
    }
   
}
