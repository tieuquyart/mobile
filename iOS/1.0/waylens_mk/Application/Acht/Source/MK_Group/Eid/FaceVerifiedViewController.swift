//
//  FaceVerifiedViewController.swift
//  NFCPassportReaderApp
//
//  Created by TranHoangThanh on 5/4/21.
//  Copyright © 2021 Andy Qua. All rights reserved.
//

import UIKit
import AVFoundation
import MKiDNFCV4
import Combine
import Network



protocol FaceViewUIDelegate : AnyObject {
    func showInfoProfile(_ cardInfo : CardInfo , _ message : NFCViewDisplayMessage)
}

class FaceVerifiedViewController: BaseViewController {
    
    var isFirstLoad = true
    var isFont = true
    var isLoading = false
    var isGoSetting = false
    var isInternet = false
    var isRuning = false
    var isClose = false
    
    weak var delegate: FaceViewUIDelegate?
    var cardInfo : CardInfo?
    var message : NFCViewDisplayMessage?
    
    //For Camera
    @IBOutlet weak var viewLive: UIView!
    @IBOutlet weak var btnFinish: UIButton!
    @IBOutlet weak var lblNoFace: UILabel!
    @IBOutlet weak var lbltutorialFace: UILabel!
    
    
    var passportReader : PassportReader!
    var userCancel = true
    let userDefaults = UserDefaults.standard
    
    //Camera Capture requiered properties
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isConnectedInternet()
        
        self.setUI()
        self.viewLive.layer.cornerRadius = 150
        self.viewLive.clipsToBounds = true
        setupVideoPreview()
        do {
            try setupCaptureSession()
        } catch {
            let errorMessage = String(describing:error)
            print("[--ERROR--]: \(#file):\(#function):\(#line): " + errorMessage)
            alert(title: "Error", message: errorMessage)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBar(animated: animated)
        
        self.initHeader(text: "Xác thực khuôn mặt", leftButton: false)
        
        showNavigationBar(animated: animated)
        
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        AccountControlManager.shared.keyChainMgr.onLogOut()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.passportReader = PassportReader(bankTransactionId: "", andBankAppId: 0, andBankTransInfo: "", andBankTransType: 0)
        
        passportReader.delegate = self
    }
    
    
    func isConnectedInternet() {
        
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else {return}
            if path.status != .satisfied {
                // Not connected
                print("No connection.")
                DispatchQueue.main.async {
                    self.isInternet = false
                    self.isRuning = false
                }
            }
            else {
                // Cellular 3/4/5g connection
                if !self.isRuning {
                    DispatchQueue.main.async {
                        self.isInternet = true
                        print("We're connected!")
                        self.isRuning = true
                    }
                }
                
            }
        }
        
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    
    
    override func setUI() {
        lblNoFace.text = "Không tìm thấy khuôn mặt"
        lbltutorialFace.text = "Để mắt nhìn thẳng vào màn hình"
        btnFinish.setTitle("Chụp", for: .normal)
    }
    
    func checkCaptureSession() {
        if captureSession.isRunning {
            capturePhoto()
        } else {
            captureSession.startRunning()
        }
    }
    
    var timer: Timer?
    
    @IBAction func btnFinish(_ sender: Any) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            print("clicked button")
            if self.isInternet {
                self.checkCaptureSession()
            } else {
                self.showAlert(title: "Kết quả" , message: "Không có mạng")
            }
        })
        
    }
    
}



extension FaceVerifiedViewController:  AVCapturePhotoCaptureDelegate {
    
    @objc func capturePhoto() {
        let photoOutputSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: photoOutputSettings, delegate: self)
    }
    
    private func setupVideoPreview() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.bounds = self.viewLive.bounds
        previewLayer.position = CGPoint(x:viewLive.bounds.midX, y:viewLive.bounds.midY)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        viewLive.layer.addSublayer(previewLayer)
    }
    
    func stopCamera(){
        captureSession.stopRunning()
    }
    
    func reloadCamera() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func showAlertOK(title: String?, message: String,
                     btnRight: String, action: @escaping (() -> ())) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Check title left is availabel
        
        // Check title right is availabel
        alert.addAction(UIAlertAction(title: btnRight, style: .default, handler: { (_) in
            //ta sẽ thoát firebase ở đây
            action()
            
        }))
        
        // Show alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func setupCaptureSession() throws {
        let deviceDiscovery = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front)
        let devices = deviceDiscovery.devices
        
        guard let captureDevice = devices.first else {
            let errorMessage = "No camera available"
            print("[--ERROR--]: \(#file):\(#function):\(#line): " + errorMessage)
            alert(title: "Error", message: errorMessage)
            return
        }
        
        let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
        captureSession.addInput(captureDeviceInput)
        // captureSession.sessionPreset = AVCaptureSession.Preset.photo
        captureSession.startRunning()
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard  let photoData = photo.fileDataRepresentation() else {
            let errorMessage = "Photo capture did not provide output data"
            print("[--ERROR--]: \(#file):\(#function):\(#line): " + errorMessage)
            alert(title: "Error", message: errorMessage)
            return
        }
        
        guard let image = UIImage(data: photoData) else {
            let errorMessage = "could not create image to save"
            print("[--ERROR--]: \(#file):\(#function):\(#line): " + errorMessage)
            alert(title: "Error", message: errorMessage)
            return
        }
        
        
        getImage(image)
        
    }
    
    func getImage(_ image: UIImage) {
        self.stopCamera()
        //   let img = UIImage(named: "image")!
        self.passportReader.readIdInfo(image: image)
        
    }
    
    
}



extension FaceVerifiedViewController {
    
    func captureDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [ .builtInWideAngleCamera, .builtInMicrophone, .builtInDualCamera, .builtInTelephotoCamera ], mediaType: AVMediaType.video, position: .unspecified).devices
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
}




extension  FaceVerifiedViewController : UpdateReaderSessionMessageDelegte {
    
    func errorCard(_ value: NFCPassportReaderError) {
        //   reloadCamera()
        print("value NFCPassportReaderError",value.rawValue)
        switch value.rawValue {
        case 17,18:
            passportReader.errorReaderMessage("Lỗi kết nối. Vui lòng thử lại.")
            break
        case 20 :
            passportReader.errorReaderMessage("Khóa MRZ không hợp lệ cho tài liệu này.")
            break
        default:
            self.passportReader.errorReaderMessage("Xin lỗi, đã xảy ra sự cố khi đọc CCCD.")
            break
        }
    }
    
    func errorMessage(_ value: NFCViewDisplayMessage){
        
        DispatchQueue.main.async {
            print("value NFCViewDisplayMessage",value.rawValue)
            switch value.rawValue {
            case -1:
                self.showAlert(title: "Thông báo", message: "Lỗi hết licenese")
                break
            case 7,28:
                self.showAlertOK(title: "Thông báo", message: "Lỗi kết nối tới server", btnRight: "OK", action: {
                    self.checkCaptureSession()
                })
                break
            case 213:
                self.passportReader.invalidate()
                self.showAlert(title: "Kết quả" , message: "Không thành công")
                break
            case 300:
                self.passportReader.errorReaderMessage("Khuôn mặt không khớp")
                break
            case 301:
                self.passportReader.errorReaderMessage("VERIFY_MOC_SERVER_ERROR")
                break
            case 302:
                self.passportReader.errorReaderMessage("Lỗi 302")
                break
            case 600:
                self.passportReader.errorReaderMessage("NotActivate")
                break
            case 999:
                self.passportReader.errorReaderMessage("UNKNOWN_ERROR")
                break
            default:
                print("default")
                break
                
            }
            
        }
    }
    
    func showMessage(alertMessage: NFCViewDisplayMessage) {
        print("alertMessage NFCViewDisplayMessage",alertMessage.rawValue)
        UserSetting.shared.isMoc = false
        UserSetting.shared.isLoggedIn = false
        switch alertMessage.rawValue {
        case 2:
            passportReader.showReaderMessage("Giữ iPhone của bạn gần CCCD có hỗ trợ NFC.")
            self.isLoading = true
            break
        case 304 :
            passportReader.showReaderMessage("Đã MoC thành công")
            UserSetting.shared.isMoc = true
            UserSetting.shared.isLoggedIn = true
            DispatchQueue.main.sync {
                if let rootWindow = appDelegate.window {
                    let rootViewController = AppViewControllerManager.createTabBarController()
                    rootWindow.rootViewController = rootViewController
                    
                    UIView.transition(with: rootWindow, duration: Constants.Animation.defaultDuration, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
                        rootWindow.rootViewController = rootViewController
                    })
                }
            }
            break
        case 5:
            passportReader.showReaderMessage("Đã đọc thẻ CCCD thành công")
            self.passportReader.invalidate()
            break
        case 12:
            self.reloadCamera()
            if let model = cardInfo , let mess = message {
                DispatchQueue.main.async {
                    self.delegate?.showInfoProfile(model,mess)
                }
            }
            break
        default:
            break
        }
    }
    
    func getSODresult(_ value : NFCViewDisplayMessage) {
        self.message = value
    }
    
    
    func getInfoCard(_ value : CardInfo) {
        self.cardInfo = value
    }
    
    
    
    
    
}
