//
//  SimDataViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 10/11/22.
//  Copyright © 2022 msg. All rights reserved.
//

import UIKit
import WaylensCameraSDK
import WaylensFoundation
import SVProgressHUD

class SimDataViewController: BaseViewController {
    
    @IBOutlet weak var phoneTf: PlaceHolderTextView!
    @IBOutlet weak var infoTextView: UITextView!
    
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var infoResponseTextView: PlaceHolderTextView!
    
    @IBOutlet weak var viewResponse: UIView!
    var placeholderLabel : UILabel!
    var camera: UnifiedCamera?
    
    let config = ApplyCameraConfigMK()
    func setBorderView() {
        btnSend.layer.cornerRadius = 12
        btnSend.layer.masksToBounds = true
       
        btnSend.backgroundColor = UIColor.color(fromHex: ConstantMK.blueButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show("", maxTime: 20)
        
        title = "Nhà mạng"
        self.showNavigationBar(animated: false)
        setBorderView()
       

        config.camera =  camera
        viewResponse.isHidden = true
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.showResult(_:)), name: NSNotification.Name(rawValue: "msgSimData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showResultmsgCarrier(_:)), name: NSNotification.Name(rawValue: "msgCarrier"), object: nil)
       
        setBorderView(view: infoTextView)
        setBorderView(view: infoResponseTextView)
        
        config.buildCheckCarrier()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        title = "Nhà mạng"
        self.showNavigationBar(animated: animated)
    }
    
    
    func setBorderView(view :  UITextView) {
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
    }
    
   

    
   
    @objc func  showResultmsgCarrier(_ notification: NSNotification) {

        if let result = notification.userInfo?["value"] as? String {
            
            SVProgressHUD.dismiss()
          // do something with your image
            self.title = "Nhà mạng \(result)"
            self.showNavigationBar(animated: false)
        }
         
     }
    
    
    @objc func showResult(_ notification: NSNotification) {

        if let result = notification.userInfo?["dataSIM"] as? String {
            
          // do something with your image
            
              SVProgressHUD.dismiss()
              self.viewResponse.isHidden = false
              self.infoResponseTextView.text = result
        }
         
     }
    
    var timer: Timer?
    
    @IBAction func send(_ sender: Any) {
        print("send")
        
        let value = [
            "phoneNo": phoneTf.text ?? "",
            "msg": infoTextView.text.lowercased()
        ]

        SVProgressHUD.show("", maxTime: 20)

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
           // print("clicked button")
            self.config.buildSimData(dict: value)
        })

        
    
      
        
    }
    

}


extension SVProgressHUD {
    open class func show(_ status: String, maxTime: TimeInterval) {
        //  SVProgressHUD.show(withStatus: status)
        SVProgressHUD.show()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + maxTime) {
            
            SVProgressHUD.dismiss()
            
        }
    }
}

@IBDesignable
class PlaceHolderTextView: UITextView {

    @IBInspectable var placeholder: String = "" {
         didSet{
             updatePlaceHolder()
        }
    }

    @IBInspectable var placeholderColor: UIColor = UIColor.gray {
        didSet {
            updatePlaceHolder()
        }
    }

    private var originalTextColor = UIColor.darkText
    private var originalText: String = ""

    private func updatePlaceHolder() {

        if self.text == "" || self.text == placeholder  {

            self.text = placeholder
            self.textColor = placeholderColor
            if let color = self.textColor {

                self.originalTextColor = color
            }
            self.originalText = ""
        } else {
            self.textColor = self.originalTextColor
            self.originalText = self.text
        }

    }

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        self.text = self.originalText
        self.textColor = self.originalTextColor
        return result
    }
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        updatePlaceHolder()

        return result
    }
}
