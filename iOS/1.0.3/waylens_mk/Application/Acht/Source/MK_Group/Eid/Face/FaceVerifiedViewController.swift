
//
//  FaceVerifiedViewController.swift
//  NFCPassportReaderApp
//
//  Created by TranHoangThanh on 5/4/21.
//  Copyright © 2021 Andy Qua. All rights reserved.
//


import UIKit
import SwiftUI
import AVFoundation
import CoreNFC
import Combine
import Network
import SwiftAlertView
import Network

import eID_SDK_MKV
import MK_eID_liveness_MKV

class FaceVerifiedViewController: BaseViewController , NetworkCheckObserver {


  var networkCheck = NetworkCheck.sharedInstance()

  @IBOutlet weak var btnStart: UIButton!
  @IBOutlet weak var viewLive: FaceView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var viewStatus: UIView!
  @IBOutlet weak var viewErrorEmpty: UIView!
  @IBOutlet weak var lblErrorEmpty: UILabel!
  @IBOutlet weak var lblNoFace: UILabel!
  @IBOutlet weak var lbltutorialFace: UILabel!
  @IBOutlet weak var imgAvatar: UIImageView!
  @IBOutlet weak var viewTimer: UIView!
  @IBOutlet weak var viewError: UIView!
  @IBOutlet weak var viewIntenet: UIView!
  @IBOutlet weak var lblInternet: UILabel!
  @IBOutlet weak var viewLoading: UIView!
  @IBOutlet weak var lblTimer: UILabel!
  @IBOutlet weak var lblError: UILabel!
  @IBOutlet weak var statusLivenessMode: UILabel!
  var alertView : SwiftAlertView?
  let userDefaults = UserDefaults.standard
  var `totalTime` = 3
  var timer : Timer?

  var isLoginEid = false
    var passportReader = PassportReader.shared
//  var passportInfo : NFCPassportModel?
  var cardInfo : CardInfo?
  var message : NFCViewDisplayMessage?

  var isInternet = false
  var isSetting = false
  override func viewDidLoad() {
    super.viewDidLoad()


//    self.passportReader = PassportReader(bankTransactionId: "1",  andBankTransInfo: "", andBankTransType: 0, delegate: self)

    if networkCheck.currentStatus == .satisfied {

      self.isInternet = true

    }else {

      self.isInternet = false

    }

    networkCheck.addObserver(observer: self)

    appDelegate.delegate = self
    self.viewLive.layer.cornerRadius = 150
    self.viewLive.clipsToBounds = true
    self.viewLive.delegate = self
    self.capture()

    self.navigationController?.isNavigationBarHidden = false
    self.navigationItem.setHidesBackButton(true, animated: false)
    let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
    newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
    self.navigationItem.leftBarButtonItem = newBackButton
  }

  @objc func back(sender: UIBarButtonItem) {
    if isLoginEid {
      self.backTwo()
    } else {
      self.navigationController?.popViewController(animated: true)
    }

  }


  func statusDidChange(status: NWPath.Status) {
    if status == .satisfied {
      //Do something
      print("capture internet")
      self.isInternet = true

      configLblInternet()

    }else if status == .unsatisfied {
      //Show no network alert
      print("no internet")
      self.isInternet = false
      configLblInternet()
    }
  }

  func configLblInternet() {
    if !isInternet {
      lblInternet.text = "Bạn cần kết nối Internet".localizeMk()
      viewIntenet.isHidden = false
      stopTimer()
    } else {
      lblInternet.text = ""
      viewIntenet.isHidden = true
    }

  }


  func capture() {
    if self.isInternet {
        self.viewLive.enrollTask()
      self.setTimer()
    }


  }

  deinit {
    self.alertView = nil
    self.stopTimer()
    self.cardInfo = nil
    self.message = nil
//    self.passportReader = nil

    notification.removeObserver(self)
  }




  func setTimer() {
    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setCapture), userInfo: nil, repeats: true)
  }


  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.initHeader(text: "Xác thực khuôn mặt", leftButton: false)
    self.setUI()

    NotificationCenter.default.addObserver(self, selector: #selector(showNotiFace(_:)), name: NSNotification.Name("NOTI_Face"), object: nil)

  }


  func getStatusLivenessMode() {
    let key = UserDefaults.standard.integer(forKey: "liveness_mode")
    if key == 0 {
      statusLivenessMode.text = "Chế độ Liveness : None"
    } else if key == 5 {
      //   statusLivenessMode.text = "Chế độ Liveness : Custom"
    } else if key == 1 {
      statusLivenessMode.text = "Chế độ Liveness : Passive"
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    print("Man Hinh 1 : viewDidDisappear")

    NotificationCenter.default.removeObserver(self)
  }


  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if isSetting {
      self.capture()
      self.isSetting = false
    }

  }


  func hideStatusInfo() {
    viewError.isHidden = true
    viewStatus.isHidden = true
    viewErrorEmpty.isHidden = true

  }

  func showStatusInfo() {
    viewError.isHidden = false
    viewStatus.isHidden = false
    viewErrorEmpty.isHidden = false
  }




  func forceCamera() {

    self.viewLive.startExtractFace()

  }

  @objc func setCapture() {
    if isInternet {
      self.viewTimer.isHidden = false
      self.totalTime -= 1
      self.lblTimer.text  = "\(self.totalTime)"
      print("totalTime",self.totalTime)
      if totalTime <= 0 {
        stopTimer()
        forceCamera()
        return
      }
    }

  }

  override func setUI() {
    lblNoFace.text = "Không tìm thấy khuôn mặt".localizeMk()
    lbltutorialFace.text = "Để mắt nhìn thẳng vào màn hình".localizeMk()
    btnStart.setTitle("Chụp".localizeMk(), for: .normal)

    getStatusLivenessMode()
    configLblInternet()
    hideStatusInfo()
    setButtonLoading()
  }
  var isLoading = false
  func setButtonLoading() {
    print("set Button Loading")
    if self.isLoading {
      // self.showProgress()
      self.hideStatusInfo()
      self.viewLoading.isHidden = false


    } else {
      //self.hideProgress()

      self.viewLoading.isHidden = true



    }
  }


  func stopTimer() {
    self.viewTimer.isHidden = true
    timer?.invalidate()
    timer = nil
    self.totalTime = 3
  }





  var centerFinish = false

  @objc func showNotiFace(_ notification: NSNotification) {
    if let data = notification.userInfo?["data"] as? String {
      print("noti text" , data)
      self.viewStatus.isHidden = false
      self.statusLabel.text = data.localizeMk()
    }
  }

}


extension FaceVerifiedViewController :  FaceViewDelegate {
    func validateLicense(_ error: Error!, withMessage value: String!) {
        
    }
    
    func fileVideoOutputPath(_ moviePath: URL!, withImage1 image1: UIImage!, withImage2 image2: UIImage!) {
        
    }
    
    
    
    
  func getTemplateSuccess() {
    print("tạo Template Success")
    self.passportReader.readIdInfo(nfcPopupTitle: "Giữ iPhone của bạn gần CCCD có hỗ trợ NFC.", bankTransactionId: "1",  andBankTransInfo: "", andBankTransType: 0, delegate: self)
    self.isLoading = true
  }




  func hideDelegateAlert() {
    self.alertView?.dismiss()
  }

  func getStatus(value : String) {

    if value == "Success"  {
      viewErrorEmpty.isHidden = true
      lblErrorEmpty.text = ""
    } else if value == "Cancelled" {
      viewError.isHidden = false
      lblError.text = value

    }

    else {

      if value.contains("index") {
        alertView = SwiftAlertView(title: "", message: "\("Error! No face in the picture.".localizeMk()) \("Please try again".localizeMk())", buttonTitles: "ok".localizeMk())
      } else {
        alertView = SwiftAlertView(title: "", message: "\(value.localizeMk()) . \("Please try again".localizeMk())", buttonTitles: "ok".localizeMk())
      }


      if value.contains("shutdown before between") {
        self.showAlert(title: "Thông báo".localizeMk(), message: "Unexpected error ! Please restart the app and try again".localizeMk(), btnRight: "ok".localizeMk()) {
          DispatchQueue.main.delay(1) {
            exit(0)

          }

        }
        return
      }

      alertView?.onButtonClicked { [weak self] _, buttonIndex in
        self?.hideStatusInfo()
        self?.capture()

      }

      alertView?.show()
    }

  }
  func showStatus(_ value: String) {
    print("value error", value ?? "")
    self.getStatus(value: value)

  }


}


extension  FaceVerifiedViewController : UpdateReaderSessionMessageDelegate {



  //    func closeNfcPopUp() {
  //
  //        if let model = cardInfo ,  let mess = message  {
  //
  //
  //            self.cardInfo = nil
  //            self.message = nil
  //
  //            self.passportReader = nil
  //            self.alertView = nil
  //
  //
  //            DispatchQueue.main.async {
  //                self.hideStatusInfo()
  //                self.isLoading = false
  //                self.setButtonLoading()
  //                self.stopTimer()
  //                self.delegate?.showInfoProfile(model,mess)
  //            }
  //
  //        }
  //    }

  func closeNfcPopUp() {
    //
    if let model = cardInfo {

      self.cardInfo = nil

//      self.passportReader = nil
      self.alertView = nil


      DispatchQueue.main.async {
        self.stopTimer()
        //                self.delegate?.showInfoProfile(model,mess)
        UserSetting.shared.isMoc = true
        UserSetting.shared.isLoggedIn = true
        if let rootWindow = appDelegate.window {
          let rootViewController = AppViewControllerManager.createTabBarController()
          rootWindow.rootViewController = rootViewController

          UIView.transition(with: rootWindow, duration: Constants.Animation.defaultDuration, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
            rootWindow.rootViewController = rootViewController
          }, completion: nil)
        }
      }

    }
  }
  //

  func errorCard(_ value: NFCPassportReaderError) {
    //   reloadCamera()
    print("value NFCPassportReaderError",value.rawValue)
    switch value.rawValue {

    case 19,2:

      DispatchQueue.main.async {
        self.hideStatusInfo()
        self.capture()
        self.isLoading = false
        self.setButtonLoading()
      }

      break
    case 17,18:
      passportReader.errorReaderMessage("Lỗi kết nối. Vui lòng thử lại.".localizeMk())
      break
    default:
      passportReader.errorReaderMessage("Lỗi kết nối. Vui lòng thử lại.".localizeMk())
      break
    }
  }

  func errorMessage(_ value: NFCViewDisplayMessage){

    //    reloadCamera()
    print("value errorMessage",value.rawValue)
    switch value.rawValue {
    case -1:
      //  self.showAlert("Lỗi Het licenese".localizeMk())
      //self.passportReader.errorReaderMessage("Lỗi Het licenese".localiz())
      break
    case 403:
      self.passportReader.errorReaderMessage("Khuôn mặt không khớp".localizeMk())
      break
    case 301:
      self.passportReader.errorReaderMessage("VERIFY_MOC_SERVER_ERROR".localizeMk())
      break
    case 302:
      self.passportReader.errorReaderMessage("ICAO_ERROR".localizeMk())
      break
    case 303:
      self.passportReader.errorReaderMessage("VERIFY_SOD_SERVER_ERROR".localizeMk())
      break
    case 203:

      self.passportReader.errorReaderMessage("Tag not found".localizeMk())

      break
    case 600:
      self.passportReader.errorReaderMessage("NotActivate".localizeMk())
      break
    case 601:
      self.passportReader.errorReaderMessage("FAILED_TO_VERIFY_SOD".localizeMk())
      break
    case 999:
      self.passportReader.errorReaderMessage("UNKNOWN_ERROR".localizeMk())
      break
    default:
      print("default")
      break

    }
  }


  func getInfoCard(_ value : CardInfo) {
    self.cardInfo = value
  }

}


extension FaceVerifiedViewController : StatusAppDelegate {
  func didBecomeActive() {
    print("didBecomeActive")
    self.setCapture()
    self.setButtonLoading()

  }

  func willEnterForeground() {
    print("willEnterForeground")


  }

  func didEnterBackground() {
    print("DidEnterBackground")
    exit(0)
  }



}

extension DispatchQueue {
  func delay(_ timeInterval: TimeInterval, execute work: @escaping () -> Void) {
    asyncAfter(deadline: .now() + timeInterval , execute: work)

  }
}
