//
//  CustomChartCardHeaderView.swift
//  Fleet
//
//  Created by DevOps MKVision on 12/01/2024.
//  Copyright © 2024 waylens. All rights reserved.
//

import UIKit

class CustomChartCardHeaderView: UIView {

    enum Segment: Int, CaseIterable {
        case mileage = 0
        case duration
        case event
    }

    var segments: [Segment] = []
    var selectHandler: ((Int) -> ())? = nil

//    private var selectionIndicator: UIView!
    private var segmentedControl: StatisticsSegmentedControl!
    private(set) var selectedSegmentIndex: Int = 0
    
    @IBOutlet private weak var contentView : UIView!
    
    @IBOutlet private weak var viewMileage : UIView!
    @IBOutlet private weak var viewDuration : UIView!
    @IBOutlet private weak var viewEvent : UIView!
    
    @IBOutlet private weak var lbMileage : UILabel!
    @IBOutlet private weak var lbDuration : UILabel!
    @IBOutlet private weak var lbEvent : UILabel!
    
    @IBOutlet private weak var lbSubMileage : UILabel!
    @IBOutlet private weak var lbSubDuration : UILabel!
    @IBOutlet private weak var lbSubEvent : UILabel!

    init(segments: [Segment] = Segment.allCases, frame: CGRect) {
        super.init(frame: frame)

        self.segments = segments
        customInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func customInit(){
        Bundle.main.loadNibNamed("CustomChartCardHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        clipsToBounds = true
        contentView.backgroundColor = .clear
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true
        //
        setShadowView([viewMileage,viewDuration,viewEvent])
        //
        lbSubMileage.text = NSLocalizedString("Kilometers", comment: "Kilometers")
        lbSubDuration.text = NSLocalizedString("Hours", comment: "Hours")
        lbSubEvent.text = NSLocalizedString("Events", comment: "Events")
        //
        updateSelectedView()
        
        tapView([viewMileage,viewDuration,viewEvent])
    }
    
    func tapView(_ view : [UIView]){
        view.forEach { v in
            v.addTapGesture {
                switch v {
                case self.viewMileage :
                    self.selectedSegmentIndex = 0
                    break
                case self.viewDuration:
                    self.selectedSegmentIndex = 1
                    break
                case self.viewEvent:
                    self.selectedSegmentIndex = 2
                    break
                    
                default:
                    self.selectedSegmentIndex = 0
                }
                self.selectHandler?(self.selectedSegmentIndex)
                self.updateSelectedView()
            }
        }
    }
    
    func updateSelectedView(){
        switch selectedSegmentIndex{
        case 0:
            //textColor
            lbMileage.textColor = UIColor.color(fromHex: "#0B4296")
            lbDuration.textColor = UIColor.color(fromHex: "#9AA7B6")
            lbEvent.textColor = UIColor.color(fromHex: "#9AA7B6")
            
            lbSubMileage.textColor = UIColor.color(fromHex: "#6BC1FF")
            lbSubDuration.textColor = UIColor.color(fromHex: "#9AA7B6")
            lbSubEvent.textColor = UIColor.color(fromHex: "#9AA7B6")
            
            //borderColor
            viewMileage.layer.borderColor = UIColor.color(fromHex: "#6BC1FF").cgColor
            viewDuration.layer.borderColor = UIColor.color(fromHex: "#9AA7B6").cgColor
            viewEvent.layer.borderColor = UIColor.color(fromHex: "#9AA7B6").cgColor
            break
        case 1:
            //textColor
            lbDuration.textColor = UIColor.color(fromHex: "#0B4296")
            lbMileage.textColor = UIColor.color(fromHex: "#9AA7B6")
            lbEvent.textColor = UIColor.color(fromHex: "#9AA7B6")
            
            lbSubDuration.textColor = UIColor.color(fromHex: "#6BC1FF")
            lbSubMileage.textColor = UIColor.color(fromHex: "#9AA7B6")
            lbSubEvent.textColor = UIColor.color(fromHex: "#9AA7B6")
            
            //borderColor
            viewDuration.layer.borderColor = UIColor.color(fromHex: "#6BC1FF").cgColor
            viewMileage.layer.borderColor = UIColor.color(fromHex: "#9AA7B6").cgColor
            viewEvent.layer.borderColor = UIColor.color(fromHex: "#9AA7B6").cgColor
            break
        case 2:
            //textColor
            lbEvent.textColor = UIColor.color(fromHex: "#0B4296")
            lbDuration.textColor = UIColor.color(fromHex: "#9AA7B6")
            lbMileage.textColor = UIColor.color(fromHex: "#9AA7B6")
            
            lbSubEvent.textColor = UIColor.color(fromHex: "#6BC1FF")
            lbSubDuration.textColor = UIColor.color(fromHex: "#9AA7B6")
            lbSubMileage.textColor = UIColor.color(fromHex: "#9AA7B6")
            
            //borderColor
            viewEvent.layer.borderColor = UIColor.color(fromHex: "#6BC1FF").cgColor
            viewDuration.layer.borderColor = UIColor.color(fromHex: "#9AA7B6").cgColor
            viewMileage.layer.borderColor = UIColor.color(fromHex: "#9AA7B6").cgColor
            break
        default:
            //textColor
            lbMileage.textColor = UIColor.color(fromHex: "#0B4296")
            lbDuration.textColor = UIColor.color(fromHex: "#9AA7B6")
            lbEvent.textColor = UIColor.color(fromHex: "#9AA7B6")
            
            lbSubMileage.textColor = UIColor.color(fromHex: "#6BC1FF")
            lbSubDuration.textColor = UIColor.color(fromHex: "#9AA7B6")
            lbSubEvent.textColor = UIColor.color(fromHex: "#9AA7B6")
            
            //borderColor
            viewMileage.layer.borderColor = UIColor.color(fromHex: "#6BC1FF").cgColor
            viewDuration.layer.borderColor = UIColor.color(fromHex: "#9AA7B6").cgColor
            viewEvent.layer.borderColor = UIColor.color(fromHex: "#9AA7B6").cgColor
        }
    }
    
    func setShadowView(_ views : [UIView]){
        views.forEach { v in
            v.layer.cornerRadius = 8
            v.layer.masksToBounds = true
            v.addShadow(offset: CGSize(width: 0.5, height: 1), opacity: 0.05)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
    
    func update(with mileage: Measurement<UnitLength>?, duration: Measurement<UnitDuration>?, eventCount: Int?) {
        
        if segments.contains(.mileage) {
            if let mileage = mileage {
               
                lbMileage.text = mileage.localeStringValue
            } else {
                lbMileage.text = 0.measurementLength(unit: .kilometers).localeStringValue
            }
        }

        if segments.contains(.duration) {
            if let duration = duration {
                lbDuration.text = duration.localeStringValue
            } else {
                lbDuration.text = 0.measurementDuration(unit: .hours).localeStringValue
            }
        }

        if segments.contains(.event) {
            lbEvent.text = eventCount?.description
        }
    }
}

extension CustomChartCardHeaderView: Themed {

    func applyTheme() {
        backgroundColor = UIColor.clear
//        selectionIndicator.backgroundColor = UIColor.semanticColor(.tint(.primary))
    }

}
