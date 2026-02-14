//
//  HNMessageManager.swift
//  Acht
//
//  Created by Chester Shen on 12/18/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import RxSwift
import WaylensCameraSDK

struct HNCameraMessage: Equatable {
    let level: HNWarningLevel
    let content: String
    let actionTitle: String?
    let actionBlock: (()->Void)?
    var isRead = false
    
    init(level: HNWarningLevel, content: String, actionTitle: String?=nil, actionBlock:(()->Void)?=nil) {
        self.level = level
        self.content = content
        self.actionTitle = actionTitle
        self.actionBlock = actionBlock
    }
    
    static func == (lhs: HNCameraMessage, rhs: HNCameraMessage) -> Bool {
        return lhs.level == rhs.level && lhs.content == rhs.content
    }
}

protocol HNMessageManagerDelegate: NSObjectProtocol {
    func onCameraTopMessageUpdated(camera: UnifiedCamera)
}

class HNMessageManager: NSObject {
    @objc weak var camera: UnifiedCamera?
    var messages: [HNCameraMessage] = []
    let disposeBag = DisposeBag()
    weak var delegate: HNMessageManagerDelegate?
    init(with camera:UnifiedCamera) {
        super.init()
        self.camera = camera
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup() {
        camera?.rx.observeWeakly(WLStorageState.self, #keyPath(UnifiedCamera.local.storageState))
            .subscribe(onNext: { [weak self] _ in
                self?.refreshMessages()
        }).disposed(by: disposeBag)
        camera?.rx.observeWeakly(Int.self, #keyPath(UnifiedCamera.local.totalMB))
            .subscribe(onNext: { [weak self] _ in
                self?.refreshMessages()
            }).disposed(by: disposeBag)
        camera?.rx.observeWeakly(WLRecordState.self, #keyPath(UnifiedCamera.local.recState))
            .subscribe(onNext: { [weak self] _ in
                self?.refreshMessages()
            }).disposed(by: disposeBag)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMessages), name: Notification.Name.App.loggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMessages), name: Notification.Name.UnifiedCameraManager.listUpdated, object: nil)
    }
    
    @objc func refreshMessages() {
        var newMessages = [HNCameraMessage]()
        if let storageState = camera?.local?.storageState {
            switch storageState {
            case .error:
                newMessages.append( HNCameraMessage(level: .error, content: WLCopy.sdcardError, actionTitle: NSLocalizedString("Format", comment: "Format"), actionBlock: { [weak camera] in
                    guard let camera = camera else { return }
                    let vc = HNCSSDCardViewController.createViewController()
                    vc.camera = camera
                    AppViewControllerManager.homeViewController?.navigationController?.pushViewController(vc, animated: true)
                }))
            case .noStorage:
                newMessages.append( HNCameraMessage(level: .error, content: WLCopy.sdcardNotDetected))
            default:
                break
            }
        }
        if camera?.local?.shouldFormat == true {
            newMessages.append(HNCameraMessage(level: .warning, content: WLCopy.sdcardFormatRecommended, actionTitle: NSLocalizedString("Format", comment: "Format"), actionBlock: { [weak camera] in
                guard let camera = camera else { return }
                let vc = HNCSSDCardViewController.createViewController()
                vc.camera = camera
                AppViewControllerManager.homeViewController?.navigationController?.pushViewController(vc, animated: true)
            }))
        }
        if let capacity = camera?.sdcardUsageTotal, capacity > 0, capacity < 15000000000 {
            newMessages.append(HNCameraMessage(level: .warning, content: WLCopy.sdcardCapacityTooLow))
        }
        if let recState = camera?.local?.recState {
            switch recState {
            case .error:
                newMessages.append( HNCameraMessage(level: .error, content: WLCopy.recordError))
            case .stopped:
                newMessages.append( HNCameraMessage(level: .information, content: WLCopy.recordStopped, actionTitle: NSLocalizedString("Start Recording", comment: "Start Recording"), actionBlock: { [weak camera] in
                    camera?.local?.startRecord()
                }))
            default:
                break
            }
        }
        if !AccountControlManager.shared.isAuthed {
            #if !FLEET
            newMessages.append(HNCameraMessage(level: .information, content: WLCopy.loginTip, actionTitle: NSLocalizedString("Log In", comment: "Log In"), actionBlock: {
                AppViewControllerManager.gotoLogin()
            }))
            #endif
        } else if AccountControlManager.shared.isAuthed && UnifiedCameraManager.shared.remoteUpdated {
            if camera?.ownerUserId != AccountControlManager.shared.keyChainMgr.userID {
                newMessages.append(HNCameraMessage(level: .information, content: WLCopy.bindTip, actionTitle:NSLocalizedString("Add", comment: "Add"), actionBlock: { [weak camera, weak self] in
                    if AccountControlManager.shared.isAuthed {
                        camera?.bind(password: camera?.local?.password ?? "", completion: { [weak self] (result) in
                            if result.isSuccess {
                                self?.camera?.reportICCID(completion: nil)
                                HNMessage.showSuccess(message: NSLocalizedString("Camera added", comment: "Camera added"))
                            } else {
                                HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Failed to add camera", comment: "Failed to add camera"))
                            }
                        })
                    }
                }))
            } else if let remoteCamera = camera?.remote, remoteCamera.supports4g ?? false, !remoteCamera.hadSubscription {
                let sn = remoteCamera.sn
                newMessages.append(HNCameraMessage(level: .information, content: WLCopy.noPlan, actionTitle: NSLocalizedString("Subscribe", comment: "Subscribe"), actionBlock: {
                    sharedApplication.open(URL(string: "\(UserSetting.shared.webServer.rawValue)/my/device/\(sn)/4g_subscription/plans")!, options: [:], completionHandler: nil)
                }))
            }
        }
        for var message in newMessages {
            if let found = messages.first(where: { $0 == message}) {
                message.isRead = found.isRead
            }
        }
        let shoudNotify = newMessages.first != messages.first
        messages.removeAll()
        messages.append(contentsOf: newMessages)
        if let cam = camera, shoudNotify {
            delegate?.onCameraTopMessageUpdated(camera: cam)
        }
    }
    
    func read(_ message: HNCameraMessage) {
        if let index = messages.firstIndex(of:message) {
            messages[index].isRead = true
        }
    }
}
