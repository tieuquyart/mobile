//
//  AlertCustomMKViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 12/29/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class AlertCustomMKViewController: UIViewController {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnMobile: UIButton!
    
    @IBOutlet weak var btnAuto: UIButton!
    
    let config = ApplyCameraConfigMK()
    var camera : UnifiedCamera?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        btnMobile.addShadow(offset: CGSize(width: 3, height: 4), backgroundColor: UIColor.color(fromHex: ConstantMK.blueButton))
        btnAuto.addShadow(offset: CGSize(width: 3, height: 4), backgroundColor: .red)
        // Do any additional setup after loading the view.
        setBorderView(view: self.viewContainer)
        self.config.camera = self.camera

    }
 
    
    @IBAction func btnClose(_ sender: Any) {
        self.remove(asChildViewController: self)
    }
    @objc func showResult(_ notification: NSNotification) {

      if let result = notification.userInfo?["MOC"] as? String {
      // do something with your image
          if result == "mobile" || result == "auto" {
              self.remove(asChildViewController: self)
          } else {
              self.showToast(message: "Thất Bại", seconds: 1)
          }
      }
         
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
    

    @IBAction func btnMobile(_ sender: Any) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            self.config.configMOC(isMobile: true)
            self.remove(asChildViewController: self)
        })
       
        
    }
    @IBAction func btnAuto(_ sender: Any) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            self.config.configMOC(isMobile: false)
            self.remove(asChildViewController: self)
        })
       
       
    }
    var timer : Timer?
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
