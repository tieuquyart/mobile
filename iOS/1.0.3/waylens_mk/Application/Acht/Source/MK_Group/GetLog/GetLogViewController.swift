//
//  GetLogViewController.swift
//  Fleet
//
//  Created by TranHoangThanh on 7/5/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK
import SVProgressHUD


struct FileLog : Codable {
    var nameFile : String
}




class GetLogViewController: BaseViewController {
    
    var camera: UnifiedCamera!
    let config = ApplyCameraConfigMK()
    var fileContent = ""
    
    @IBOutlet weak var btnReportSpeed: UIButton!
    @IBOutlet weak var btnTime: UIButton!
    @IBOutlet weak var btnGetLog: UIButton!
    @IBOutlet weak var day_tf: UITextField!
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var infoCameraLabel: UILabel!
    

    @IBOutlet weak var btnTimeDriver: UIButton!
    
//    func setBorderView(for views: UIButton...) {
//        for view in views {
//            view.backgroundColor = UIColor.color(fromHex: ConstantMK.blueButton)
//            view.layer.cornerRadius = 8
//            view.layer.masksToBounds = true
//        }
//    }
    
    func updateUIBtn() {
        infoCameraLabel.text = "Báo cáo logs camera : \(camera.sn)"
        self.setBorderButton([btnReportSpeed, btnTime , btnGetLog, btnTimeDriver])
        self.btnGetLog.setTitle("Lấy thông tin báo cáo", for: .normal)
        self.btnReportSpeed.setTitle("Xem thông tin tốc độ", for: .normal)
        self.btnTimeDriver.setTitle("Xem thông tin lái xe liên tục", for: .normal)
        self.btnTime.setTitle("Xem thời gian dừng đỗ", for: .normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.day_tf.text = Date().toString(format: .isoDate)
        self.day_tf.textAlignment = .center
        
//        self.day_tf.textColor = UIColor.color(fromHex: ConstantMK.blueButton)
        config.camera =  camera
        updateUIBtn()
        self.btnTime.isHidden = true
        self.btnReportSpeed.isHidden = true
        self.btnTimeDriver.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.showResult(_:)), name: Notification.Name.DownloadLog.download, object: nil)
        
        viewDate.addShadow(offset: CGSize(width: 3, height: 4))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        initHeader(text: NSLocalizedString("Xem báo cáo", comment: "Xem báo cáo"), leftButton: false)
        self.showNavigationBar(animated: animated)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setBorderButton(_ btns : [UIView]){
        btns.forEach { btn in
            btn.addShadow(offset: CGSize(width: 3, height: 4), backgroundColor: UIColor.color(fromHex: ConstantMK.blueButton))
        }
    }
    
    @IBAction func btnTimeInfo(_ sender: Any) {
        let vc = TimeInfoDriverViewController(nibName: "TimeInfoDriverViewController", bundle: nil)
        vc.stringPath = fileContent
        vc.isDrivingTime = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnReportSpeed(_ sender: Any) {
        let vc = TimeInfoDetailViewController(nibName: "TimeInfoDetailViewController", bundle: nil)
        vc.stringPath = fileContent
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnTimeDriver(_ sender: Any) {
//        let vc = TimeInfoDetailViewController(nibName: "TimeInfoDetailViewController", bundle: nil)
//        vc.stringPath = fileContent
//        self.navigationController?.pushViewController(vc, animated: true)troller", bundle: nil)
        let vc = TimeInfoDriverViewController(nibName: "TimeInfoDriverViewController", bundle: nil)
        vc.stringPath = fileContent
        vc.isDrivingTime = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showResult(_ notification: NSNotification) {
        print(" notification.object", notification.object as Any)
        
        self.hideProgress()
        if let result = notification.userInfo?["success"] as? Bool {
            
            if result {
                print("download log ")
                SVProgressHUD.dismiss()
                self.alert(title: "Thông báo", message: "Lấy thông tin thành công")
                self.btnGetLog.isEnabled = true
                self.btnTime.isHidden = false
                self.btnReportSpeed.isHidden = false
                self.btnTimeDriver.isHidden = false
            } else {
                self.alert(title: "Thông báo", message: "Lấy thông tin thất bại")
            }
        }
//        else if let progress = notification.userInfo?["progess"] as? Float {
//            HNMessage.show(message: NSLocalizedString("Downloading camera log", comment: "Downloading camera log") + "(\(Int(ceil(progress * 100)))%)")
//        }
        
        if let filePath = notification.userInfo?["filePath"] as? String {
            
            let fullPath = NSString(string: filePath).expandingTildeInPath
            
            
            do
            {
                self.fileContent = try NSString(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue) as String
                print("txt load" , fileContent)
            }catch let err {
                
                self.alert(title: "Thông báo", message: err.localizedDescription)
            }
        }
    
    }
    
    var timer: Timer?
    
    
    @IBAction func buttonGetLog(_ sender: Any) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            print("clicked button")
            self.showProgress()
            self.config.downLoadingLog(value: self.day_tf.text!)
        })

        
        
        
    }
    
    private lazy var datePicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.autoresizingMask = .flexibleWidth
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker .backgroundColor = .white
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var toolBar : UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneClicked))]
        toolBar.sizeToFit()
        return toolBar
    }()
    
    
    
    private func addDatePicker() {
        self.view.addSubview(self.datePicker)
        self.view.addSubview(self.toolBar)
        
        NSLayoutConstraint.activate([
            self.datePicker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.datePicker.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.datePicker.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.datePicker.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        NSLayoutConstraint.activate([
            self.toolBar.bottomAnchor.constraint(equalTo: self.datePicker.topAnchor),
            self.toolBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.toolBar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.toolBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    @objc private func onDoneClicked() {
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
    }
    
    
    @objc private func dateChanged(picker : UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        let date = picker.date
        self.btnGetLog.isHidden = false
        self.day_tf.text = date.toString(format: .isoDate)
        self.btnTime.isHidden = true
        self.btnReportSpeed.isHidden = true
        self.btnTimeDriver.isHidden = true
        self.onDoneClicked()
        
    }

    
    @IBAction func btnShowDate(_ sender: Any) {
        
        addDatePicker()
        
    }
    
 

    
    
    class func saveOrders(_ orders: [FileLog]) {
        guard let data = try? JSONEncoder().encode(orders) else { return }
        UserDefaults.standard.set(data, forKey: "FileLog")
    }
    
    class func loadOrders() -> [FileLog] {
        guard
            let data = UserDefaults.standard.data(forKey: "FileLog"),
            let orders = try? JSONDecoder().decode([FileLog].self, from: data)
        else { return [] }
        return orders
    }
    
    
}


