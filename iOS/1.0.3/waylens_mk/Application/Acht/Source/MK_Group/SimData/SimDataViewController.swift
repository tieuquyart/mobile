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
    @IBOutlet weak var viewPhone: UIView!
    @IBOutlet weak var infoTextView: PlaceHolderTextView!
    
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var infoResponseTextView: PlaceHolderTextView!
    
    @IBOutlet weak var viewResponse: UIView!
    @IBOutlet weak var viewCarrier: UIView!
    @IBOutlet weak var viewLine: UIView!
    @IBOutlet weak var viewInputData: UIView!
    @IBOutlet weak var imgCarrier: UIImageView!
    @IBOutlet weak var carrierLb : UILabel!
    
    var camera: UnifiedCamera?
    
    let config = ApplyCameraConfigMK()
    
    func setBorderButton() {
        btnSend.addShadow(offset: CGSize(width: 3, height: 4), backgroundColor: UIColor.color(fromHex: ConstantMK.blueButton))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show(withStatus: NSLocalizedString("Đang kiểm tra...", comment: "Đang kiểm tra..."))
        
        setBorderButton()
        
        config.camera =  camera
        viewResponse.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showResult(_:)), name: NSNotification.Name(rawValue: "msgSimData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showResultmsgCarrier(_:)), name: NSNotification.Name(rawValue: "msgCarrier"), object: nil)
        
        setBorderView([viewPhone, viewInputData, infoResponseTextView, viewCarrier, viewLine])
        
        config.buildCheckCarrier()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBack))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
        
    }
    
    @objc func leftBack(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        
        initHeader(text: "Kiểm tra thẻ SIM", leftButton: false)
        
        self.showNavigationBar(animated: animated)
    }
    
    
    func setBorderView(_ views :  [UIView]) {
        views.forEach { view in
            view.addShadow(offset: CGSize(width: 3, height: 4))
        }
    }
    
    
    
    
    
    @objc func  showResultmsgCarrier(_ notification: NSNotification) {
        
        if let result = notification.userInfo?["value"] as? String {
            
            SVProgressHUD.dismiss()
            // do something with your image
            self.carrierLb.text = "Nhà mạng \(result)"
            if result.lowercased() == "mobifone"{
                self.imgCarrier.image = UIImage(named: "icon_mobifone")
            }else if result.lowercased() == "viettel"{
                self.imgCarrier.image = UIImage(named: "icon_viettel")
            }else if result.lowercased() == "vinaphone"{
                self.imgCarrier.image = UIImage(named: "icon_vinaphone")
            }else if result.lowercased() == "wintel"{
                self.imgCarrier.image = UIImage(named: "icon_wintel")
            }else{
                self.imgCarrier.image = UIImage(named: "icon_viettel")
            }
        }
        
    }
    
    
    @objc func showResult(_ notification: NSNotification) {
        
        if let result = notification.userInfo?["dataSIM"] as? String {
            
            // do something with your image
            self.viewResponse.isHidden = false
            self.infoResponseTextView.text = result
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                SVProgressHUD.dismiss()
            })
        }
        
    }
    
    var timer: Timer?
    
    @IBAction func send(_ sender: Any) {
        print("send")
        
        let value = [
            "phoneNo": phoneTf.text ?? "",
            "msg": infoTextView.text?.lowercased() ?? ""
        ]
        
        SVProgressHUD.show(withStatus: NSLocalizedString("Đang kiểm tra...", comment: "Đang kiểm tra..."))
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            // print("clicked button")
            self.config.buildSimData(dict: value)
        })
        
        
        
        
        
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
