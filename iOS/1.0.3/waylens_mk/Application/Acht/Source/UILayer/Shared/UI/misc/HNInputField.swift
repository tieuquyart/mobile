//
//  HNInputField.swift
//  Acht
//
//  Created by Chester Shen on 9/18/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

@IBDesignable class HNInputField: UITextField {
    let bottomLine = UIView()
    
    // MARK:- Properties
    
    @IBInspectable var placeholderColor: UIColor = .lightGray {
        didSet {
            if let text = placeholder {
                placeholder = text
            }
        }
    }
    
    private var placeholderAttribute: Dictionary<NSAttributedString.Key, Any> {
        return [.foregroundColor: placeholderColor]
    }
    
    @IBInspectable override var placeholder:String? {
        didSet {
            if let string = placeholder {
                self.attributedPlaceholder = NSAttributedString(string: string, attributes: placeholderAttribute)
            } else {
                self.attributedPlaceholder = nil
            }
        }
    }
    
    @IBInspectable var bottomLineHeight : CGFloat = 1.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var bottomLineColor: UIColor = .gray {
        didSet {
            refreshBottomLine()
        }
    }
    
    var validColor: UIColor? {
        didSet {
            refreshBottomLine()
        }
    }
    
    var inValidColor: UIColor? {
        didSet {
            refreshBottomLine()
        }
    }
    
    var isValid: Bool = false {
        didSet {
            refreshBottomLine()
        }
    }
    
    @IBInspectable var margin: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK:- Init
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    func setup() {
        bottomLine.backgroundColor = bottomLineColor
        borderStyle = .none
        addSubview(bottomLine)
    }
    
    private var isEmpty: Bool {
        return text?.isEmpty ?? true
    }
    
    private func refreshBottomLine() {
        bottomLine.backgroundColor = isValid && (!isEmpty) ? (validColor ?? bottomLineColor): (isFirstResponder ? tintColor : (isEmpty ? bottomLineColor : inValidColor ?? bottomLineColor))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshBottomLine()
        bottomLine.frame = CGRect(x: 0, y: bounds.height - bottomLineHeight, width: bounds.width, height: bottomLineHeight)
    }

    override func textRect(forBounds bounds:CGRect) -> CGRect {
        var r = super.textRect(forBounds: bounds)
        r = r.inset(by:  UIEdgeInsets(top: 0.0, left: margin, bottom: bottomLineHeight, right: margin))
        return r.integral
    }
    
    override func editingRect(forBounds bounds:CGRect) -> CGRect {
        var r = super.editingRect(forBounds: bounds)
        r = r.inset(by: UIEdgeInsets(top: 0.0, left: margin, bottom: bottomLineHeight, right: margin))
        return r.integral
    }
}
