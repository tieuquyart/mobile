//
//  LoginFaceMKViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 12/29/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class LoginFaceMKViewController: BaseViewController {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    let config = ApplyCameraConfigMK()
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    var camera: UnifiedCamera?
    var image : UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.imageView.image = image
        setBorderView(view: self.viewContainer)
        btnCancel.addShadow(offset: CGSize(width: 3, height: 4))
        btnSend.addShadow(offset: CGSize(width: 3, height: 4), backgroundColor: UIColor.color(fromHex: ConstantMK.blueButton))
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.showResult(_:)), name: NSNotification.Name(rawValue: "msgFaceImage"), object: nil)
        
    }
   
    
//    func alert(title: String? = nil, message: String, okHandler: (() -> Void)? = nil) {
//        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
//
//        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { _ in
//            okHandler?()
//        })
//        alertVC.addAction(okAction)
//
//        present(alertVC, animated: true, completion: nil)
//    }
//
    
    @objc func showResult(_ notification: NSNotification) {

      if let result = notification.userInfo?["param"] as? Bool {
      // do something with your image
          if result {
              self.alert(title: "Thông báo", message: "Gửi ảnh Thành công", okHandler:  {
                  self.remove(asChildViewController: self)
              })
          } else {
              self.alert(title: "Thông báo", message: "Gửi ảnh Thất bại", okHandler:  {
                  self.remove(asChildViewController: self)
              })
          }
      }
         
     }
    func setBorderView(view : UIView) {
        view.addShadow(offset: CGSize(width: 3, height: 4))
    }
    func remove(asChildViewController childController: UIViewController) -> Void {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
    @IBAction func btnCancel(_ sender: Any) {
        remove(asChildViewController: self)
    }
    
    @IBAction func btnSend(_ sender: Any) {
        if let image = image {
            if let stringBase64 =  ImageConverter().imageToBase64(image) {
               self.config.camera =  UnifiedCameraManager.shared.local
               self.config.buildImage(dict: ["imgBase64" : stringBase64])
           }
        }
    }

}
