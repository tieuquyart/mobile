//
//  GuideBasicPage.swift
//  Acht
//
//  Created by Chester Shen on 7/27/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class GuideBasicPage: GuidePage {
    var titleLabel = UILabel()
    var actionButton = UIButton()
    var skipButton = UIButton()
    var skipButtonBottomSpace: NSLayoutConstraint?
    var text: String = "" {
        didSet {
            if titleAttributes == nil {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 5
                style.paragraphSpacing = 8
                titleAttributes = [
                    .font: UIFont(name: "BeVietnamPro-Regular", size: 20)!,
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: style
                ]
            }
            titleLabel.attributedText = NSAttributedString(string: text, attributes: titleAttributes)
        }
    }
    var actionTitle: String = NSLocalizedString("Go", comment: "Go") {
        didSet {
            actionButton.setTitle(actionTitle, for: .normal)
        }
    }
    
    static func createViewController() -> GuideBasicPage {
        return GuideBasicPage()
    }
    
    var titleAttributes: [NSAttributedString.Key: Any]?

    override func loadView() {
        view = PassThroughView()
        view.backgroundColor = .clear
        titleLabel.numberOfLines = 0
        
        actionButton.setBackgroundImage(#imageLiteral(resourceName: "btn_white_lined"), for: .normal)
        actionButton.titleLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        
        skipButton.titleLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)
        skipButton.setTitle(NSLocalizedString("Skip", comment: "Skip"), for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        
        view.addSubview(titleLabel)
        view.addSubview(actionButton)
        view.addSubview(skipButton)
        
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        skipButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 34).isActive = true
        if #available(iOS 11.0, *) {
            skipButtonBottomSpace = skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        } else {
            skipButtonBottomSpace = skipButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        }
        skipButtonBottomSpace?.isActive = true
        skipButton.heightAnchor.constraint(equalToConstant: 49).isActive = true
        actionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -34).isActive = true
        actionButton.centerYAnchor.constraint(equalTo: skipButton.centerYAnchor).isActive = true
        actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 65).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: 49).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 54).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -40).isActive = true
        
        actionButton.addTarget(self, action: #selector(onAction(_:)), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(onSkip(_:)), for: .touchUpInside)
    }
    
    func showTapIndicator(point: CGPoint) {
        let tapIndicator = UIImageView(image: #imageLiteral(resourceName: "tap_gesture"))
        tapIndicator.frame = CGRect(origin: point, size: tapIndicator.bounds.size)
        view.addSubview(tapIndicator)
    }
    
    func showHalo(center: CGPoint) {
        let tapIndicator = UIImageView(image: #imageLiteral(resourceName: "tap_halo"))
        tapIndicator.frame = CGRect(x: center.x - 0.5 * tapIndicator.image!.size.width, y: center.y - 0.5 * tapIndicator.image!.size.height, width: tapIndicator.image!.size.width, height: tapIndicator.image!.size.height)
        view.addSubview(tapIndicator)
        tapIndicator.alpha = 0
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
            tapIndicator.alpha = 1
        }, completion: nil)
    }
    
    func showTip(_ text: String, center: CGPoint, width: CGFloat = 200) {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "BeVietnamPro-Semibold", size: 14)!
        label.textColor = .white
        label.numberOfLines = 0
        let expectedSize = label.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        let originX = min(max(34, center.x - expectedSize.width / 2), view.bounds.width - 20 - expectedSize.width)
        label.frame = CGRect(x: originX, y: center.y, width: expectedSize.width, height: expectedSize.height)
        label.autoresizingMask = [.flexibleHeight]
        view.addSubview(label)
    }
    
    @objc func onAction(_ sender: Any) {
        controller?.onAction()
    }
    
    @objc func onSkip(_ sender: Any) {
        controller?.onSkip()
    }
}


