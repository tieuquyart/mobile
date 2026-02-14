//
//  HNTextDisplayView.swift
//  Acht
//
//  Created by Chester Shen on 5/30/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class HNTextDisplayView: UIView {
    var labels = [UILabel]()
    var animating: Bool = false
    var fontSize: CGFloat = UIFont.systemFontSize
    var fadedTextColor: UIColor = .lightGray
    var highlightTextColor: UIColor = .black
    var historyCount: Int = 2
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
    }
    
    func addNewLine(text:String, keepHistoryCount: Int?=nil) {
        if let count = keepHistoryCount {
            historyCount = count
        }
        let comingLabel = UILabel()
        comingLabel.numberOfLines = 0
        comingLabel.text = text
        comingLabel.font = UIFont.systemFont(ofSize: fontSize)
        comingLabel.textColor = highlightTextColor
        comingLabel.alpha = 0
        let fittingHeight = comingLabel.systemLayoutSizeFitting(CGSize(width: bounds.width, height: 0), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow).height
        addSubview(comingLabel)
        comingLabel.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: fittingHeight)
        labels.insert(comingLabel, at: 0)
        UIView.animate(withDuration: 0.5, animations: {
            for i in 0..<self.labels.count {
                self.labels[i].frame = self.labels[i].frame.offsetBy(dx: 0, dy: -fittingHeight)
                if i>=self.historyCount {
                    self.labels[i].alpha = 0
                }
                if i > 0 {
                    self.labels[i].textColor = self.fadedTextColor
                }
            }
            comingLabel.alpha = 1
        }) { (completed) in
            if completed {
                if self.historyCount < self.labels.count {
                    self.labels.removeSubrange(self.historyCount..<self.historyCount)
                }
            }
        }
    }
}
