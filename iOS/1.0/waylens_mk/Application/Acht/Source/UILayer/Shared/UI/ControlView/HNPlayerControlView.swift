//
//  HNPlayerControlView.swift
//  Acht
//
//  Created by forkon on 2018/9/6.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class HNPlayerControlView: PassThroughView {
    fileprivate let portraitControlView: (UIView & HNPlayerControlProtocol)
    fileprivate let landScapeControlView: (UIView & HNPlayerControlProtocol)?
    
    fileprivate var fadeOutControlViewWorkItem: DispatchWorkItem?
    
    weak var player: PlayerPanel? {
        didSet {
            portraitControlView.player = player
            landScapeControlView?.player = player
        }
    }
    private(set) var controlViewAppeared: Bool = true
    
    var recordingSwitches: [UISwitch] {
        var switches: [UISwitch] = []
        if let controlView = portraitControlView as? RecordingStateToggleable {
            switches.append(controlView.recordingSwitch)
        }
        if let controlView = landScapeControlView as? RecordingStateToggleable {
            switches.append(controlView.recordingSwitch)
        }
        return switches
    }
    
    var transferRateLabels: [UILabel] {
        var labels: [UILabel] = []
        if let controlView = portraitControlView as? TransferRateDisplayable {
            labels.append(controlView.transferRateLabel)
        }
        if let controlView = landScapeControlView as? TransferRateDisplayable {
            labels.append(controlView.transferRateLabel)
        }
        return labels
    }
    
    var highlightCards: [HighlightCard] {
        var cards: [HighlightCard] = []
        if let controlView = portraitControlView as? Highlightable {
            cards.append(controlView.highlightCard)
        }
        if let controlView = landScapeControlView as? Highlightable {
            cards.append(controlView.highlightCard)
        }
        return cards
    }

    var highlightButtons: [UIButton] {
        var buttons: [UIButton] = []
        if let controlView = portraitControlView as? Highlightable {
            buttons.append(controlView.highlightButton)
        }
        if let controlView = landScapeControlView as? Highlightable {
            buttons.append(controlView.highlightButton)
        }
        return buttons
    }

    fileprivate(set) var currentHighlightButton: UIButton?
    fileprivate(set) var currentHighlightCard: HighlightCard?
    fileprivate(set) var viewModeButton: UIButton?
    
    var additionalAnimations: ((_ isToHide: Bool) -> ())? = nil
    
    init(portraitControlView: UIView & HNPlayerControlProtocol, landScapeControlView: (UIView & HNPlayerControlProtocol)? = nil) {
        self.portraitControlView = portraitControlView
        self.landScapeControlView = landScapeControlView
        
        super.init(frame: CGRect.zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        portraitControlView.frame = bounds
        landScapeControlView?.frame = bounds
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return super.hitTest(point, with: event)
    }
    
    func updateUI() {
        guard let player = player else {
            return
        }
        
        portraitControlView.updateUI()
        landScapeControlView?.updateUI()
        
        if controlViewAppeared {
            showControlView(animated: false)
        } else {
            hideControlView(animated: false)
        }
        
        if player.fullScreen, let landScapeControlView = landScapeControlView {
            portraitControlView.isHidden = true
            landScapeControlView.isHidden = false
            
            if let landScapeControlView = landScapeControlView as? Highlightable {
                currentHighlightCard = landScapeControlView.highlightCard
                currentHighlightButton = landScapeControlView.highlightButton
            }
            
            if let landScapeControlView = landScapeControlView as? PlayerViewModeToggleable {
                viewModeButton = landScapeControlView.viewModeButton
            }
        } else {
            portraitControlView.isHidden = false
            landScapeControlView?.isHidden = true
            
            if let portraitControlView = portraitControlView as? Highlightable {
                currentHighlightCard = portraitControlView.highlightCard
                currentHighlightButton = portraitControlView.highlightButton
            }
            
            if let portraitControlView = portraitControlView as? PlayerViewModeToggleable {
                viewModeButton = portraitControlView.viewModeButton
            }
        }
    }
    
    func hideDMSFaceButton(hide: Bool){
        UIView.animate(withDuration: 0, animations: { [weak self] in
            guard let strongSelf = self, let player = strongSelf.player else {
                return
            }
            strongSelf.portraitControlView.hideDMSFaceButton(hide: hide)
            strongSelf.controlViewAppeared = true
        })
    }
    
    func showControlView(animated: Bool = true) {
        UIView.animate(withDuration: animated ? Constants.Animation.defaultDuration : 0, animations: { [weak self] in
            guard let strongSelf = self, let player = strongSelf.player else {
                return
            }
            if player.fullScreen, let landScapeControlView = strongSelf.landScapeControlView {
                landScapeControlView.showControlView()
            } else {
                strongSelf.portraitControlView.showControlView()
            }
            strongSelf.additionalAnimations?(false)
            strongSelf.controlViewAppeared = true
        }) { [weak self] _ in
            self?.autoFadeOutControlView()
        }
    }
    
    func hideControlView(animated: Bool = true) {
        UIView.animate(withDuration: animated ? Constants.Animation.defaultDuration : 0) { [weak self] in
            guard let strongSelf = self, let player = strongSelf.player else {
                return
            }
            if player.fullScreen, let landScapeControlView = strongSelf.landScapeControlView {
                landScapeControlView.hideControlView()
            } else {
                strongSelf.portraitControlView.hideControlView()
            }
            strongSelf.additionalAnimations?(true)
            strongSelf.controlViewAppeared = false
        }
    }
    
    func addTimeLineHorizontalView(_ timeLineView: CameraTimeLineHorizontalView) {
        if let landScapeControlView = landScapeControlView as? TimeLineViewRequirable {
            landScapeControlView.addTimeLineView(timeLineView)
        }
    }
    
    func removeTimeLineHorizontalView() {
        if let landScapeControlView = landScapeControlView as? TimeLineViewRequirable {
            landScapeControlView.removeTimeLineView()
        }
    }
    
    func showTime(_ date: Date) {
        if let landScapeControlView = landScapeControlView as? PlayTimeDisplayable {
            landScapeControlView.timeLabel.text = date.toString(format: .timeSec12)
        }
    }
    
    func showTimePointInfo(_ timePointInfo: HNTimePointInfo) {
        guard let landScapeControlView = landScapeControlView as? TimePointInfoDisplayable else {
            return
        }
        
        var stringLines: [NSAttributedString] = []
        let font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
        let baselineOffset: CGFloat = 2.5
        
        let dateString = NSAttributedString(
            string: timePointInfo.dateString,
            attributes: [
                .font : font,
                .foregroundColor : UIColor.white,
                .baselineOffset : baselineOffset
            ]
        )
        let timeString = NSAttributedString(
            string: timePointInfo.timeString,
            attributes: [
                .font : font,
                .foregroundColor : UIColor.semanticColor(.tint(.primary)),
                .baselineOffset : baselineOffset
            ]
        )
        
        stringLines.append(dateString + " " + timeString)
        if let locationString = timePointInfo.locationString {
            let locationAttributedString = NSAttributedString(
                string: locationString,
                attributes: [
                    .font : font,
                    .baselineOffset : baselineOffset
                ]
            )
            stringLines.append(locationAttributedString)
        }
        landScapeControlView.timePointInfoHUD.stringLines = stringLines
    }
    func showResolutionButton(_ show: Bool, streams : Int) {
        portraitControlView.showResolutionButton(show, streams: streams)
        landScapeControlView?.showResolutionButton(show, streams: streams)
    }
    func showViewModeButton(_ show: Bool) {
        portraitControlView.showViewModeButton(show)
        landScapeControlView?.showViewModeButton(show)
    }
}

extension HNPlayerControlView {
    
    fileprivate func setup() {
        addSubview(portraitControlView)
        if let landScapeControlView = landScapeControlView {
            addSubview(landScapeControlView)
        }
        
        updateUI()
    }
    
    fileprivate func autoFadeOutControlView() {
        cancelAutoFadeOutControlView()
        
        fadeOutControlViewWorkItem = DispatchWorkItem(block:{ [weak self] in
            self?.hideControlView()
        })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.0, execute: fadeOutControlViewWorkItem!)
    }
    
    fileprivate func cancelAutoFadeOutControlView() {
        fadeOutControlViewWorkItem?.cancel()
        fadeOutControlViewWorkItem = nil
    }
    
}

extension Array where Element: UISwitch {
    
    var isOn: Bool {
        return first?.isOn ?? false
    }
    
    func setOn(_ on: Bool) {
        forEach { (switchControl) in
            switchControl.isOn = on
        }
    }
    
    var isEnabled: Bool {
        return first?.isEnabled ?? false
    }
    
    func setEnabled(_ enabled: Bool) {
        forEach { (switchControl) in
            switchControl.isEnabled = enabled
        }
    }
    
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        forEach { (switchControl) in
            switchControl.addTarget(target, action: action, for: controlEvents)
        }
    }
    
}

extension Array where Element: UILabel {
    
    func setText(_ text: String) {
        forEach { (label) in
            label.text = text
        }
    }
    
}

extension Array where Element: HighlightCard {
    
    func setImage(_ image: UIImage?) {
        forEach { (highlightCard) in
            highlightCard.image = image
        }
    }

    func setHighlightCardState(_ highlightCardState: HighlightCardState) {
        forEach { (highlightCard) in
            highlightCard.highlightCardState = highlightCardState
        }
    }    
}
