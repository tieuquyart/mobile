//
//  Constant.swift
//  Acht
//
//  Created by TranHoangThanh on 11/25/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate
import Combine
import eID_SDK_MKV
import MK_eID_liveness_MKV

//typealias SUCCESS_CLORUSE = (() -> ())
//private var window: UIWindow!

extension UIAlertController {
    func present(animated: Bool, completion: (() -> Void)?) {
//        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.windowLevel = .alert + 1
        window?.makeKeyAndVisible()
        window?.rootViewController?.present(self, animated: animated, completion: completion)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        window = nil
    }
}

public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}



extension String {

    func validatePhone() -> Bool {
//        let PHONE_REGEX = "(84|0[3|5|7|8|9])+([0-9]{8})"
        let PHONE_REGEX = "^[+]?[0-9]{10,13}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: self)
        return result
    }
    
    func containsOnlyLetters() -> Bool {
       for chr in self {
          if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
             return false
          }
       }
       return true
    }
    func matchsIn(regexString: String) -> Bool {
            do { let regex = try NSRegularExpression(pattern: regexString, options: [])
                 return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.utf8.count)) != nil
            } catch { return false }
        }
}

let providerSecret = "MKVisionK2CePwUjJcV2Wyf8RxIWqkJ6"

struct ConstantMK {
    static let bgColorLogin = "F5F5F5"
    static let blueButton = "133D7A"
    static let bgTabar = "133D7A"
    static let grayLabel = "9DA1A7"
    static let greenLabel = "7DC065"
    static let borderGrayColor = "EEEEEE"
    static let redBGColor = "F3E4E5"
    static let redTextColor = "E4636B"
    static let greenBG = "E6F9EF"
    static let grayBG = "F5F5F5"
    static let purpleBG = "F5EDFD"
    static let purpleText = "9E57E5"
    static let bg_main_color = "F5F5F5"
    static var vehicleItemList : [VehicleItemModel] = []
    static var isShowUpdate = false
    static var isUseMOC = false
    static var locationHN = CLLocationCoordinate2D(latitude: 21.028333, longitude: 105.853333)
    
    static func language(str : String) -> String {
        return NSLocalizedString(str, comment: str)
    }
    
    static let helperMK: MKIDNFCHelper = MKIDNFCHelper(appId: 40, providerSecret: providerSecret)
    static var config : ConfigSetting!
    
    
    static func getVehicleWithPlateNo(str : String?) -> VehicleItemModel?{
        for item in ConstantMK.vehicleItemList{
            if str == item.plateNo {
                return item
            }
        }
        return nil
    }
    
    static func initConfig(){
        self.config = ConfigSetting()
        self.config.setUrl("https://dev.mk.com.vn:18778/api/")
        self.config.initFaceVerification()
    }
    
    static func deinitConfig(){
        if(self.config != nil){
            self.config.finishFaceVerification()
        }
    }
    
    static func drivingTimeToDate(value : String) ->  Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: value)!
        return date
    }
    
    
    static func fixTimeLabel(time : String) -> String {
//        let date = drivingTimeToDate(value: time)
//        return date.toString(format: .isoDate)
        
        
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: time)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = tempLocale // reset the locale
        let dateString = dateFormatter.string(from: date)
        print("EXACT_DATE : \(dateString)")
        return dateString
    }
    
    
    
    static func okButton() -> String {
         return language(str: "OK")
    }
    static func cancelButton() -> String {
        return language(str: "Cancel")
    }
    
    static func borderButton( _ items : [UIButton]) {
        items.forEach { btn in
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 12
            btn.layer.masksToBounds = true
        }
    }
    
    static func borderTF( _ items : [UITextField]) {
        items.forEach { tf in
            tf.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
            tf.layer.borderColor = UIColor.lightGray.cgColor
            tf.layer.borderWidth = 1
            tf.layer.cornerRadius = 12
            tf.layer.masksToBounds = true
        }
    }
    
    static func parseJson(dict : JSON , handler : @escaping (Bool,String) -> ()) {
        
        if let success = dict["success"] as? Bool {
            if success{
                handler(success,"")
            }else{
                if let msg = dict["message"] as? String{
                    handler(false,msg)
                }else{
                    handler(false,"failure")
                }
            }
        } else {
            
            if let mess = dict["message"] as? String {
                handler(false,mess)
            }else{
                
                handler(false,"failure")
            }
            
        }
    }
    
}

//7DC065


extension PaddingLabel {
    
    func borderGrayMK() {
        //Setting the border
              layer.borderWidth = 1
              layer.borderColor = UIColor.blue.cgColor
              
              //Setting the round (optional)
              layer.masksToBounds = true
              layer.cornerRadius = frame.height / 2
          
              //Setting the padding label
              edgeInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
       
    }
    
    func backGroundGrayMK(){
       
        textColor = .white
        layer.backgroundColor = UIColor.lightGray.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = frame.height / 2
        edgeInset = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
    }
    
    
}
extension String {
    
    func fixTimeLabel() -> String {
//        let date = drivingTimeToDate(value: time)
//        return date.toString(format: .isoDate)
        if self.isEmpty {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: self)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = tempLocale // reset the locale
        let dateString = dateFormatter.string(from: date)
        print("EXACT_DATE : \(dateString)")
        return dateString
    }
}





class PaddingLabel: UILabel {

    var edgeInset: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: edgeInset.top, left: edgeInset.left, bottom: edgeInset.bottom, right: edgeInset.right)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + edgeInset.left + edgeInset.right, height: size.height + edgeInset.top + edgeInset.bottom)
    }
}


extension UIImage
{
  func resizedImage(Size sizeImage: CGSize) -> UIImage?
  {
      let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: sizeImage.width, height: sizeImage.height))
      UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
      self.draw(in: frame)
      let resizedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      self.withRenderingMode(.alwaysOriginal)
      return resizedImage
  }
}




import UIKit

extension CAShapeLayer {
func drawRoundedRect(rect: CGRect, andColor color: UIColor, filled: Bool) {
    fillColor = filled ? color.cgColor : UIColor.white.cgColor
    strokeColor = color.cgColor
    path = UIBezierPath(roundedRect: rect, cornerRadius: 7).cgPath
}
}

private var handle: UInt8 = 0;

extension UIBarButtonItem {
private var badgeLayer: CAShapeLayer? {
    if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
        return b as? CAShapeLayer
    } else {
        return nil
    }
}

func setBadge(text: String?, withOffsetFromTopRight offset: CGPoint = CGPoint.zero, andColor color:UIColor = UIColor.red, andFilled filled: Bool = true, andFontSize fontSize: CGFloat = 10)
{
    badgeLayer?.removeFromSuperlayer()

    if (text == nil || text == "") {
        return
    }

    addBadge(text: text!, withOffset: offset, andColor: color, andFilled: filled)
}

private func addBadge(text: String, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true, andFontSize fontSize: CGFloat = 10)
{
    guard let view = self.value(forKey: "view") as? UIView else { return }

    var font = UIFont(name: SF_FONT_BOLD, size: fontSize)
//    var font = UIFont.boldSystemFont(ofSize: fontSize)

     if #available(iOS 9.0, *) { font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: UIFont.Weight.regular) }
    let badgeSize = text.size(withAttributes: [NSAttributedString.Key.font: font ?? UIFont.boldSystemFont(ofSize: fontSize)])

    // Initialize Badge
    let badge = CAShapeLayer()

    let height = badgeSize.height + 2;
    var width = badgeSize.width + 6 /* padding */

    //make sure we have at least a circle
    if (width < height) {
        width = height
    }

    //x position is offset from right-hand side
    let x = view.frame.width - width + offset.x

    let badgeFrame = CGRect(origin: CGPoint(x: x + 2 , y: offset.y), size: CGSize(width: width, height: height))

    badge.drawRoundedRect(rect: badgeFrame, andColor: color, filled: filled)
    badge.lineWidth = 1
    badge.strokeColor = UIColor.color(fromHex: ConstantMK.blueButton).cgColor
    view.layer.addSublayer(badge)

    // Initialiaze Badge's label
    let label = CATextLayer()
    label.string = text
    label.alignmentMode = CATextLayerAlignmentMode.center
    label.font = font ?? UIFont.boldSystemFont(ofSize: fontSize)
    label.fontSize = fontSize
   

    label.frame = CGRect(origin: CGPoint(x: x + 2 , y: offset.y + 1), size: CGSize(width: width, height: height))
    label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
    label.backgroundColor = UIColor.clear.cgColor
    label.contentsScale = UIScreen.main.scale
    badge.addSublayer(label)

    // Save Badge as UIBarButtonItem property
    objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

 func removeBadge() {
    badgeLayer?.removeFromSuperlayer()
}
}


extension CALayer {


    func innerBorder(borderOffset: CGFloat = 24, borderColor: UIColor = UIColor.blue, borderWidth: CGFloat = 2) {
        let innerBorder = CALayer()
        innerBorder.frame = CGRect(x: borderOffset, y: borderOffset, width: frame.size.width - 2 * borderOffset, height: frame.size.height - 2 * borderOffset)
        innerBorder.borderColor = borderColor.cgColor
        innerBorder.borderWidth = borderWidth
        innerBorder.name = "innerBorder"
        insertSublayer(innerBorder, at: 0)
    }
}




extension UIButton {
    func addRightIcon(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)

        let length = CGFloat(15)
        titleEdgeInsets.right += length

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.titleLabel!.trailingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: length),
            imageView.heightAnchor.constraint(equalToConstant: length)
        ])
    }
    
    func addLeftIcon(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)

        let length = CGFloat(15)
        titleEdgeInsets.left += length

        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: self.titleLabel!.leadingAnchor, constant: -10),
            imageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: length),
            imageView.heightAnchor.constraint(equalToConstant: length)
        ])
    }
}



extension Bundle {

    var appName: String {
        return infoDictionary?["CFBundleName"] as! String
    }

    var bundleId: String {
        return bundleIdentifier!
    }

    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }

}
