//
//  FeedbackController.swift
//  Acht
//
//  Created by Chester Shen on 11/3/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import Zip
import WaylensFoundation
import WaylensCameraSDK

class FeedbackController: BaseViewController {
    
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var camLogButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!// HNMainButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextView: UITextView!
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var cameraContainer: UIStackView!
    @IBOutlet weak var camListContainer: UIStackView!
    @IBOutlet weak var camLogContainer: UIStackView!
    @IBOutlet weak var camLogTipContainer: UIView!
    @IBOutlet weak var emailContainer: UIStackView!
    
    @IBOutlet weak var emailTextField: EmailTextField!
    @IBOutlet weak var emailHintLabel: UILabel!
    
    var camera: UnifiedCamera?
    var topic: String?
    
    static func createViewController() -> FeedbackController {
        let vc = UIStoryboard(name: "Support", bundle: nil).instantiateViewController(withIdentifier: "FeedbackController")
        return vc as! FeedbackController
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 2
        inputTextView.delegate = self
        placeholderLabel.text = NSLocalizedString("Please describe the issue", comment: "Please describe the issue")
        inputTextView.text = ""
        camLogButton.setTitleColor(UIColor.semanticColor(.label(.secondary)), for: .normal)
        camLogButton.setTitleColor(UIColor.semanticColor(.label(.primary)), for: .disabled)
        
#if FLEET
        sendButton.isEnabled = false
        emailHintLabel.isHidden = true
        emailTextField.validityChangeHandler = { [weak self] isValid in
            self?.sendButton.isEnabled = isValid
            
            if isValid || self?.emailTextField.text?.isEmpty == true {
                self?.emailHintLabel.isHidden = true
            } else {
                self?.emailHintLabel.isHidden = false
            }
        }
        
        if AccountControlManager.shared.isLogin {
            emailTextField.text = AccountControlManager.shared.keyChainMgr.email
            sendButton.isEnabled = true
        }
#endif
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
        
        title = NSLocalizedString("Report an Issue", comment: "Report an Issue")
        
        self.showNavigationBar(animated: animated)
        
        applyTheme()
        refreshUI()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDisconnected), name: Notification.Name.UnifiedCameraManager.localDisconnected, object: nil)
    }
    
    @objc func deviceDisconnected() {
        refreshUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func applyTheme() {
        super.applyTheme()
        
        emailTextField.backgroundColor = UIColor.semanticColor(.textInputAreaBackground)
        backgroundView.backgroundColor = UIColor.semanticColor(.textInputAreaBackground)
        logButton.tintColor = UIColor.semanticColor(.tint(.primary))
        camLogButton.tintColor = UIColor.semanticColor(.tint(.primary))
        sendButton.backgroundColor = UIColor.color(fromHex: "#003D7A")
        sendButton.layer.cornerRadius = 12
        sendButton.layer.masksToBounds = true
    }
    
    func createButton(title: String?) -> UIButton {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 8)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        btn.setImage(UIImage(named: "radio_empty"), for: .normal)
        btn.setImage(UIImage(named: "radio_selected"), for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.semanticColor(.label(.secondary)), for: .normal)
        btn.addTarget(self, action: #selector(onSelectButton(sender:)), for: .touchUpInside)
        btn.tintColor = UIColor.semanticColor(.tint(.primary))
        btn.usingDynamicTextColor = true
        return btn
    }
    
    func refreshUI() {
        if UnifiedCameraManager.shared.cameras.count == 0 {
            topic = nil
            camLogButton.isEnabled = false
            camLogButton.isSelected = false
            cameraContainer.isHidden = true
            camLogContainer.isHidden = true
        } else {
            if camera == nil {
                camera = UnifiedCameraManager.shared.local ?? UnifiedCameraManager.shared.current
            }
            topic = camera?.name
            if UnifiedCameraManager.shared.cameras.count == 1 {
                cameraContainer.isHidden = true
            } else {
                cameraContainer.isHidden = false
                camListContainer.removeAllArrangedSubviews()
                for (index, cam) in UnifiedCameraManager.shared.cameras.enumerated() {
                    let btn = createButton(title: cam.name)
                    btn.isSelected = cam == camera
                    btn.tag = 100 + index
                    camListContainer.addArrangedSubview(btn)
                }
            }
            camLogContainer.isHidden = false
            if camera?.local == nil {
                camLogButton.isEnabled = false
                camLogButton.isSelected = false
                camLogTipContainer.isHidden = false
            } else {
                camLogButton.isEnabled = true
                camLogTipContainer.isHidden = true
            }
        }
        
#if FLEET
        if AccountControlManager.shared.isLogin {
            emailContainer.isHidden = true
        } else {
            emailContainer.isHidden = false
        }
#else
        emailContainer.isHidden = true
#endif
        
        let format = NSLocalizedString("on_topic", comment: "On ")
        if topic != nil {
            titleLabel.isHidden = false
            titleLabel.text = String(format: format, topic!)
        } else {
            titleLabel.isHidden = false
            titleLabel.text = "Lỗi xảy ra trên Ứng dụng AutoSecure"
        }
    }
    
    @objc func onSelectButton(sender: UIButton) {
        camera = UnifiedCameraManager.shared.cameras[sender.tag - 100]
        refreshUI()
    }
    
    func sendFeedBack(with cameraLogFileUrl: URL? = nil) {
        var logs = [URL]()
        if camLogButton.isSelected, let cameraLogFileUrl = cameraLogFileUrl, FileManager.default.fileExists(atPath: cameraLogFileUrl.path) { // let
            logs.append(cameraLogFileUrl)
        }
        if logButton.isSelected, FileManager.default.fileExists(atPath: WLLogUtil.logFilePath()) {
            logs.append(URL(fileURLWithPath: WLLogUtil.logFilePath()))
        }
        var logUrl: URL?
        if logs.count > 0 {
            do {
//                logUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Feedbacklogs.zip")
                let currentDate = NSDate()
                let strDate = currentDate.dateString(withFormat: "yyyy-MM-dd HH:mm:ss")
                logUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(strDate ?? "Time_Err")_Feedbacklogs.zip")
                try Zip.zipFiles(paths: logs, zipFilePath: logUrl!, password: nil) { (progress) in
                    Log.verbose("Zipping app log, \(progress)")
                }
            } catch {
                Log.error("Fail to archive log files!")
                HNMessage.showError(message: NSLocalizedString("Fail to archive log files", comment: "Fail to archive log files"))
                return
            }
        }
        
        HNMessage.show(message: NSLocalizedString("Sending...", comment: "Sending..."))
        
        var userInfo = ""
#if FLEET
        if !AccountControlManager.shared.isLogin {
            userInfo = "[\(emailTextField.text ?? "")]\n"
        }
#endif
        
        WaylensClientS.shared.report(userInfo + inputTextView.text, camera: camera, logFile: logUrl) { [weak self] (result) in
            guard let self = self else {
                return
            }
            
            self.cleanUp(files: [cameraLogFileUrl, logUrl].compactMap{$0})
            switch result {
            case .success(let value):

                ConstantMK.parseJson(dict: value, handler: {success, msg in
                    if success{
                        HNMessage.showSuccess(message: NSLocalizedString("Feedback sent", comment: "Feedback sent"))
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Fail to send feedback", comment: "Fail to send feedback"))

                    }
                })
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Fail to send feedback", comment: "Fail to send feedback"))
            }
        }
    }
    
    @IBAction func onTap(_ sender: Any) {
        inputTextView.resignFirstResponder()
    }
    
    @IBAction func onSend(_ sender: Any) {
        inputTextView.resignFirstResponder()
        
#if FLEET
        if inputTextView.text.lowercased().hasPrefix("access2ccamera") {
            let access2CCamera = UserSetting.shared.access2CCamera
            UserSetting.shared.access2CCamera = !access2CCamera
            HNMessage.showSuccess(message: access2CCamera ? "Don't aceess 2C cameras now!" : "Enable to aceess 2C cameras now!")
            self.navigationController?.popViewController(animated: true)
            return
        }
#else
        if inputTextView.text.lowercased().hasPrefix("access2bcamera") {
            let access2BCamera = UserSetting.shared.access2BCamera
            UserSetting.shared.access2BCamera = !access2BCamera
            HNMessage.showSuccess(message: access2BCamera ? "Don't aceess 2B cameras now!" : "Enable to aceess 2B cameras now!")
            self.navigationController?.popViewController(animated: true)
            return
        }
#endif
        
        if inputTextView.text.lowercased().hasPrefix("showvideoqualitysettings") {
            let showCameraDebugSettings = UserSetting.shared.showCameraDebugSettings
            UserSetting.shared.showCameraDebugSettings = !showCameraDebugSettings
            HNMessage.showSuccess(message: showCameraDebugSettings ? "Don't show Video Quality Settingss now!" : "Show Video Quality Settings now!")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if inputTextView.text.lowercased().hasPrefix("showdebugsettings") {
            let showCameraDebugSettings = UserSetting.shared.showCameraDebugSettings
            UserSetting.shared.showCameraDebugSettings = !showCameraDebugSettings
            HNMessage.showSuccess(message: showCameraDebugSettings ? "Don't show Debug Settings now!" : "Show Debug Settings now!")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
#if !FLEET
        if !AccountControlManager.shared.isAuthed {
            AppViewControllerManager.gotoLogin()
            return
        }
#endif
        
        if camLogButton.isSelected {
            myIdleTimerManager.instance()?.myIdleTimerAdd(self)
//            let timer = TimeoutHandler(15.0, {
//                
//            })
            
            HNMessage.show(message: NSLocalizedString("Preparing camera log", comment: "Preparing camera log"))
            if let local = camera?.local {
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { timer in
                    local.downloadDebugLog(
                        progress: { (progress) in
                            Log.verbose("camera log downloaded \(progress)")
                            HNMessage.show(message: NSLocalizedString("Downloading camera log", comment: "Downloading camera log") + "(\(Int(ceil(progress * 100)))%)")
                        },
                        destination: {
                            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            
                            
                            let sourceURL = documentsUrl.appendingPathComponent("cameraDebugLogs.zip")
                            
                            return sourceURL
                            
                        },completionHandler: { [weak self] (finished, saveFileUrl, error) in
                            guard let self = self else {
                                return
                            }
                            
                            Log.info("Camera log download \(finished ? "finished: \(saveFileUrl?.path ?? "")" : "failed: \(error?.localizedDescription ?? "Unkown Error")")")
                            
                            myIdleTimerManager.instance()?.myIdleTimerRemove(self)
                            
                            if finished {
                                self.sendFeedBack(with: saveFileUrl)
                            } else {
                                HNMessage.showError(message: NSLocalizedString("Fail to download camera log", comment: "Fail to download camera log"))
                            }
                            
                        })
                                    })
                
            }else{
                HNMessage.showError(message: NSLocalizedString("Fail to download camera log", comment: "Fail to download camera log"))
            }
            
        } else {
            sendFeedBack()
        }
    }
    
    @IBAction func onLogButton(_ sender: Any) {
        logButton.isSelected = !logButton.isSelected
    }
    
    @IBAction func onCamLogButton(_ sender: Any) {
        camLogButton.isSelected = !camLogButton.isSelected
    }
    
}

private extension FeedbackController {
    
    func cleanUp(files: [URL]) {
        files.forEach { (fileUrl) in
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                do {
                    try FileManager.default.removeItem(atPath: fileUrl.path)
                } catch {
                    Log.error(error.localizedDescription)
                }
            }
        }
    }
}

extension FeedbackController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.alpha = textView.text.count == 0 ? 1 : 0
    }
}

extension FeedbackController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}

class EmailTextField: UITextField {
    
    var validityChangeHandler: ((_ isValid: Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 12.0, dy: 0.0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 12.0, dy: 0.0)
    }
    
    private func setup() {
        if let placeholder = placeholder {
            attributedPlaceholder =
            NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x99A0A9)])
        }
        
        self.delegate = self
        addTarget(self, action: #selector(textDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc private func textDidChange() {
        if text?.isValidEmail() == true {
            validityChangeHandler?(true)
        } else {
            validityChangeHandler?(false)
        }
        
        if let text = text, !text.isEmpty, !text.isValidEmail() {
            layer.borderWidth = 1.0
            layer.borderColor = UIColor.red.cgColor
        } else {
            layer.borderWidth = 0.0
            layer.borderColor = UIColor.clear.cgColor
        }
    }
}

extension EmailTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}
