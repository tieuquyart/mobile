//
//  BaseTableViewController.swift
//  Acht
//
//  Created by Chester Shen on 6/21/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyTheme()

        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
    
    func initHeader(text: String, leftButton: Bool){
        
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        self.navigationItem.title = ""
        if text == ""{
            
        }else{
            
            let atts = [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont(name: "BeVietnamPro-Semibold", size: 20.0)!,
            ]
            let titleLb = UILabel()
            titleLb.attributedText = NSAttributedString(string: text, attributes: atts)
            titleLb.sizeToFit()
            
            self.navigationItem.titleView = titleLb
        }
        
        self.navigationItem.hidesBackButton = !leftButton
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.black
        
        self.view.layoutIfNeeded()
    }

}

extension BaseTableViewController: Themed {

    @objc open func applyTheme() {
//        view.backgroundColor = UIColor.color(fromHex: "#9AA7B6")
        view.backgroundColor = UIColor.color(fromHex: "#EDEEF4")
    }

}
