//
//  HNScoreBoard.swift
//  Acht
//
//  Created by Chester Shen on 3/22/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class HNScoreBoard: UIView {
    var newLabel = UILabel()
    var currentLabel = UILabel()
    var font: UIFont = UIFont(name: "BeVietnamPro-Regular", size: UIFont.systemFontSize)! {
        didSet {
            currentLabel.font = font
            newLabel.font = font
            invalidateIntrinsicContentSize()
        }
    }
    var textColor: UIColor = UIColor.black {
        didSet {
            currentLabel.textColor = textColor
            newLabel.textColor = textColor
        }
    }
    var text: String? {
        didSet {
            currentLabel.text = text
            invalidateIntrinsicContentSize()
        }
    }
    var newText: String? {
        didSet {
            newLabel.text = newText
            invalidateIntrinsicContentSize()
        }
    }
    var animating: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        finishInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        finishInit()
    }
    
    func finishInit() {
        addSubview(newLabel)
        addSubview(currentLabel)
        newLabel.textAlignment = .center
        currentLabel.textAlignment = .center
        newLabel.isHidden = true
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        if animating == 0 {
            currentLabel.frame = bounds
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let sa = currentLabel.intrinsicContentSize
        let sb = newLabel.intrinsicContentSize
        return CGSize(width: max(sa.width, sb.width), height: max(sa.height, sb.height))
    }

    func setText(_ text: String, fromBottom: Bool=true) {
        newText = text
        let size = intrinsicContentSize
        let startFrame = CGRect(x: 0, y: fromBottom ? size.height : -size.height, width: size.width, height: size.height)
        newLabel.frame = startFrame
        newLabel.isHidden = false
        layoutIfNeeded()
        animating += 1
        UIView.animate(withDuration: 0.3, animations: {
            self.currentLabel.frame = CGRect(x: 0, y: fromBottom ? -size.height : size.height, width: size.width, height: size.height)
            self.newLabel.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }) { (completed) in
            self.animating -= 1
            if completed {
                self.swapLabels()
                self.newLabel.isHidden = true
            }
        }
    }
    
    func swapLabels() {
        let tmp = currentLabel
        currentLabel = newLabel
        newLabel = tmp
    }
}
