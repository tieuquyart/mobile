//
//  HNSegmentedSliderView.swift
//  Acht
//
//  Created by Chester Shen on 9/14/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

protocol HNSegmentedSliderViewDelegate: AnyObject {
    func segmentedSliderDidChange(_ sliderView:HNSegmentedSliderView, index: Int, finished: Bool)
}

class HNSegmentedSliderView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var slider: HNSegmentedSlider!
    
    struct Option {
        let name: String
        let color: UIColor
        let title: String
        let detail: String?
        let attributedDetail: NSAttributedString?
        init(name: String, color: UIColor, title: String, detail: String?=nil, attributedDetail: NSAttributedString?=nil) {
            self.name = name
            self.color = color
            self.title = title
            self.detail = detail
            self.attributedDetail = attributedDetail
        }
    }
    
    weak var delegate: HNSegmentedSliderViewDelegate?
    
    var image: UIImage? {
        get {
            return icon.image
        }
        
        set {
            icon.image = newValue
        }
    }
    
    var index: Int {
        get {
            return Int(slider.index)
        }
        
        set {
            setIndex(newValue, animated: false)
        }
    }
    
    var options = [Option]() {
        didSet {
            slider.titles = options.map({ $0.name })
            slider.tintColors = options.map({ $0.color })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("HNSegmentedSliderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        slider.bouncesOnChange = false
        slider.announcesValueImmediately = true
        slider.alwaysAnnouncesValue = true

        titleLabel.usingDynamicTextColor = true

        applyTheme()
    }
    
    private func selectIndex(_ index: Int) {
        titleLabel.text = options[index].title
        if let text = options[index].detail {
            detailLabel.text = text + NSLocalizedString("slide_to_change_sensitivity", comment: "\nSlide to change sensitivity.")
        } else if let attributedText = options[index].attributedDetail {
            let attributed = NSMutableAttributedString(attributedString: attributedText)
            attributed.append(NSAttributedString(string: NSLocalizedString("slide_to_change_sensitivity", comment: "\nSlide to change sensitivity.")))
            detailLabel.attributedText = attributed
        }
    }
    
    func setIndex(_ index: Int, animated: Bool=true) {
        if index >= 0 && index < slider.titles.count {
            try! slider.setIndex(UInt(index), animated: animated)
            selectIndex(index)
        }
    }
    
    @IBAction func onSliderChanged(_ sender: HNSegmentedSlider) {
        let i = Int(sender.index)
        selectIndex(i)
        delegate?.segmentedSliderDidChange(self, index: i, finished: false)
    }
    
    @IBAction func onValueConfirmed(_ sender: HNSegmentedSlider) {
        let i = Int(sender.index)
        selectIndex(i)
        delegate?.segmentedSliderDidChange(self, index: i, finished: true)
    }
    
}

extension HNSegmentedSliderView: Themed {

    func applyTheme() {
        slider.titleFont = UIFont(name: "BeVietnamPro-Bold", size: 12)!
        slider.indicatorColor = .white
        slider.coveredTitleColor = .white
        slider.backgroundColor = UIColor.semanticColor(.background(.secondary))
        slider.titleColor = UIColor.semanticColor(.label(.secondary))
    }

}
