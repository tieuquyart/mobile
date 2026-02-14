//
//  HNActionBar.swift
//  Acht
//
//  Created by Chester Shen on 9/21/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

protocol HNActionBarDelegate: NSObjectProtocol {
    func actionBarDidDelete(_ actionBar: HNActionBar)
    func actionBarDidCancel(_ actionBar: HNActionBar)
    func actionBarDidDownload(_ actionBar: HNActionBar)
    func actionBarDidRequestInfo(_ actionBar: HNActionBar)
}

class HNActionBar: PassThroughView {
    enum HNActionBarStatus {
        case hidden
        case action
        case progress
    }

    @IBOutlet weak var background: UIView!
    @IBOutlet var view: PassThroughView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    
    @IBOutlet weak var indicatorBar: UIView!
    @IBOutlet weak var deleteButton: CenteredButton!
    @IBOutlet weak var exportButton: CenteredButton!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var progressIndicator: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    var clip: HNClip? {
        didSet {
            if let clip = clip {
                refreshInfo(clip.videoType, duration: clip.duration)
            }
        }
    }
    weak var delegate: HNActionBarDelegate?
    var status: HNActionBarStatus = .hidden
    var isHideable: Bool = true
    
    var progress: Double = 0 {
        didSet {
            guard let frame = progressIndicator.superview?.frame else { return }
            progressIndicator?.frame = CGRect(x: 0, y: 0, width: progress > 0 ? max(1, CGFloat(progress) * frame.width) : 0, height: frame.height)
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
    
    private func commonInit() {
        Bundle.main.loadNibNamed("HNActionBar", owner: self, options: nil)
        addSubview(view)
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        viewHeight.constant = 0
        progress = 0
        indicatorBar.layer.cornerRadius = 2
        indicatorBar.layer.masksToBounds = true
        background.backgroundColor = UIColor.semanticColor(.background(.senary)).withAlphaComponent(0.95)
    }
    
    func showActions() {
        if status == .action {
            return
        }
        status = .action
        topSpace.constant = 0
        viewHeight.constant = 125
        UIView.animate(withDuration: 0.4) {
            self.layoutIfNeeded()
        }
    }
    
    func showProgress() {
        if status == .progress {
            return
        }
        status = .progress
        topSpace.constant = -90
        viewHeight.constant = 125
        UIView.animate(withDuration: 0.4) { 
            self.layoutIfNeeded()
        }
    }
    
    func hide() {
        if status == .hidden || !isHideable {
            return
        }
        status = .hidden
        viewHeight.constant = 0
        UIView.animate(withDuration: 0.4) {
            self.layoutIfNeeded()
        }
    }
    
    func refreshInfo(_ type: HNVideoType, duration: TimeInterval) {
        infoLabel.text = "\(type.description) · \(duration.toString(.hms))"
        if UserSetting.shared.debugEnabled &&
            clip?.rawClip?.eventType ?? .NULL != .NULL &&
            clip?.rawClip?.eventDate ?? 0.0 > 0.0 {
            infoLabel.text = infoLabel.text! + String.init(format: " @ %0.1f", clip!.rawClip!.eventDate)
        }
        indicatorBar.backgroundColor = type.color
    }
    
    @IBAction func onDelete(_ sender: Any) {
        delegate?.actionBarDidDelete(self)
    }
    
    @IBAction func onDownload(_ sender: Any) {
        delegate?.actionBarDidDownload(self)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        delegate?.actionBarDidCancel(self)
    }
    
    @IBAction func onInfo(_ sender: Any) {
        delegate?.actionBarDidRequestInfo(self)
    }
    
}
