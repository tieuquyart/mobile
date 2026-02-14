//
//  AboutViewController.swift
//  Acht
//
//  Created by gliu on 1/17/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class AboutViewController: BaseViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshUI()
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        
        title = NSLocalizedString("About", comment: "About")
        
        self.showNavigationBar(animated: animated)
    }
    
    func refreshUI() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
        versionLabel.text = "v" + version! + (UserSetting.shared.debugEnabled ? " (" + build! + ")" : "")
        let thisYear = max(Date().component(.year)!, 2017)
        copyrightLabel.text = "MKGroup Copyright © 2020-\(thisYear) MKGroup.\nAll Rights Reserved."
        copyrightLabel.sizeToFit()
        self.view.backgroundColor = UIColor.color(fromHex: ConstantMK.bg_main_color)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTerms(_ sender: Any) {
        let vc = BaseWebViewController()
        vc.title = NSLocalizedString("Terms of Use", comment: "Terms of Use")
        vc.url = URL(string: "\(UserSetting.shared.webServer.rawValue)/terms/raw.html")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onPrivacy(_ sender: Any) {
        let vc = BaseWebViewController()
        vc.title = NSLocalizedString("Privacy Policy", comment: "Privacy Policy")
        vc.url = URL(string: "\(UserSetting.shared.webServer.rawValue)/privacy/raw.html")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onDebugOption(_ sender: Any) {
        UserSetting.shared.debugEnabled = !UserSetting.shared.debugEnabled
        HNMessage.showInfo(message: "Debug Options \(UserSetting.shared.debugEnabled ? "Enabled" : "Disabled")")
        refreshUI()
    }

}
