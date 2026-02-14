//
//  HNTagSegmentedControl.swift
//  Acht
//
//  Created by Chester Shen on 1/10/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class HNTagSegmentedControl: HNSegmentedControl {

    var activeIndex: UInt? {
        didSet {
            if activeIndex == oldValue {
                return
            }
            if let _ = oldValue, let newIndex = activeIndex {
                moveTag(to: newIndex)
            } else if oldValue == nil {
                addTag(index: activeIndex!)
            } else {
                removeTag(index: oldValue!)
            }
        }
    }
    
    var _tagView: UILabel?
    var tagView: UILabel {
        if _tagView == nil {
            _tagView = initTagView()
            addSubview(_tagView!)
        }
        return _tagView!
    }
    
    func initTagView() -> UILabel {
        let tagView = UILabel()
        tagView.textAlignment = .center
        tagView.text = NSLocalizedString("ACTIVE", comment: "ACTIVE")
        tagView.textColor = .white
        tagView.font = UIFont.systemFont(ofSize: 7)
        tagView.backgroundColor = UIColor.semanticColor(.tint(.primary))
        let size = tagView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        tagView.frame =
            CGRect(origin: .zero, size: CGSize(width: size.width + 8, height: size.height + 4))
        tagView.isHidden = true
        tagView.layer.cornerRadius = 2
        tagView.clipsToBounds = true
        return tagView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let index = activeIndex {
            tagView.frame = tagFrame(forIndex: index)
        }
    }
    
    func tagFrame(forIndex index:UInt) -> CGRect{
        let label = titleLabels[Int(index)]
        let titleSize = label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let size = tagView.bounds.size
        let _frame = CGRect(x: label.bounds.midX + titleSize.width * 0.5 + 5, y: label.bounds.midY - size.height * 0.5 + 1, width: size.width, height: size.height)
        let frame = label.convert(_frame, to: self)
        return frame
    }
    func moveTag(to: UInt) {
        tagView.frame = tagFrame(forIndex: to)
    }
    
    func removeTag(index: UInt) {
        tagView.isHidden = true
    }

    func addTag(index: UInt) {
        tagView.frame = tagFrame(forIndex: index)
        tagView.isHidden = false
    }
}
