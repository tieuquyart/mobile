//
//  MultilineTextHUD.swift
//  Acht
//
//  Created by forkon on 2018/9/20.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

@IBDesignable class MultilineTextHUD: UIView {
    
    enum Config {
        static var horizontalMargin: CGFloat = 8.0
        static var verticalMargin: CGFloat = 4.0
    }
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    fileprivate var labels: [UILabel] = []
    
    var stringLines: [NSAttributedString] = [] {
        didSet {
            updateUI()
            autoFadeOut()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stackView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        updateUI()
    }
    
}

extension MultilineTextHUD {
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        backgroundColor = UIColor.semanticColor(.background(.mask))

        updateUI()
    }
    
    private func updateUI() {
        stackView.removeAllArrangedSubviews()
       
        stringLines.forEach { (line) in
            let label = UILabel()
            label.attributedText = line
            label.sizeToFit()
            
            label.widthAnchor.constraint(equalToConstant: min(label.frame.size.width, 234.0)).isActive = true
            
            stackView.addArrangedSubview(label)
        }

        let fittingSize = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        let width = fittingSize.width + Config.horizontalMargin * 2
        let height = fittingSize.height + Config.verticalMargin * 2
        if let widthConstraint = widthConstraint {
            widthConstraint.constant = width
        } else {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let heightConstraint = heightConstraint {
            heightConstraint.constant = height
        } else {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
}

extension MultilineTextHUD: AutoFadeOutable {}

fileprivate struct AssociatedKeys {
    static var fadeOutWorkItem: UInt8 = 0
}

protocol AutoFadeOutable {
    var fadeOutWorkItem: DispatchWorkItem? {set get}
    func autoFadeOut()
    func cancelAutoFadeOut()
}

extension AutoFadeOutable where Self: UIView {
    
    var fadeOutWorkItem: DispatchWorkItem? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.fadeOutWorkItem, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.fadeOutWorkItem) as? DispatchWorkItem
        }
    }
    
    func autoFadeOut() {
        cancelAutoFadeOut()
        
        var mutatingSelf = self
        mutatingSelf.fadeOutWorkItem = DispatchWorkItem(block:{ [weak self] in
            self?.alpha = 0.0
        })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: fadeOutWorkItem!)
    }
    
    func cancelAutoFadeOut() {
        fadeOutWorkItem?.cancel()
        
        var mutatingSelf = self
        mutatingSelf.fadeOutWorkItem = nil
        mutatingSelf.alpha = 1.0
    }
    
}
