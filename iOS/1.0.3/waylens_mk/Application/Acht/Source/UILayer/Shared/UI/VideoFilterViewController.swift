//
//  VideoFilterViewController.swift
//  Acht
//
//  Created by Chester Shen on 10/26/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
#if useMixpanel
import Mixpanel
#endif

protocol VideoFilterDelegate: NSObjectProtocol {
    func onFilterChanged(sender: VideoFilterViewController)
    func onFilterDismissed(sender: VideoFilterViewController)
}

class VideoFilterViewController: UIViewController {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var videoLabel: UILabel!
    
    @IBOutlet weak var sdcardButton: UIButton!
    @IBOutlet weak var cloudButton: UIButton!
    
//    @IBOutlet weak var allButton: CenteredButton!
    @IBOutlet weak var motionButton: CenteredButton!
    @IBOutlet weak var bumpButton: CenteredButton!
    @IBOutlet weak var impactButton: CenteredButton!
    @IBOutlet weak var highlightButton: CenteredButton!
    @IBOutlet weak var bufferedButton: CenteredButton!
    @IBOutlet weak var behaviorButton: CenteredButton!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneButtonBottomSpace: NSLayoutConstraint!
    
    var videoCount: Int = 0 {
        didSet {
            if isViewLoaded {
                refreshCount()
            }
        }
    }
    var sources: [HNVideoSource] = []
    var selectedSource: HNVideoSource = .sdcard
    var selectedType: HNVideoOptions = []
    let videoTypes: [HNVideoOptions] = [.motion, .hit, .heavy, .manual, .buffered, .behavior]
    var typeButtons = [UIButton]()
    weak var delegate: VideoFilterDelegate?
    
    static func createViewController() -> VideoFilterViewController {
        #if FLEET
        let vc = VideoFilterViewController(nibName: "VideoFilterViewController-Fleet", bundle: nil)
        #else
        let vc = VideoFilterViewController(nibName: "VideoFilterViewController", bundle: nil)
        #endif
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshCount()
        cloudButton.isHidden = !sources.contains(.cloud)
        sdcardButton.isHidden = !sources.contains(.sdcard)
        setupSourceButton(cloudButton)
        setupSourceButton(sdcardButton)
        refreshSourceButtons()
        
//        setupTypeButton(allButton, title: NSLocalizedString("All", comment: "All"), normal: UIImage(named: "event_all_unselected")!, selected: UIImage(named: "event_all_selected")!, color: UIColor.semanticColor(.tint(.primary)))
        setupTypeButton(motionButton, title: NSLocalizedString("Motion", comment: "Motion"), normal: UIImage(named: "event_motion_unselected")!, selected: UIImage(named: "event_motion_selected")!, color: UIColor.semanticColor(.activity(.motion)))
        setupTypeButton(bumpButton, title: NSLocalizedString("Bump", comment: "Bump"), normal: UIImage(named: "event_bump_unselected")!, selected: UIImage(named: "event_bump_selected")!, color: UIColor.semanticColor(.activity(.hit)))
        setupTypeButton(impactButton, title: NSLocalizedString("Impact", comment: "Impact"), normal: UIImage(named: "event_impact_unselected")!, selected: UIImage(named: "event_impact_selected")!, color: UIColor.semanticColor(.activity(.heavy)))
        setupTypeButton(highlightButton, title: NSLocalizedString("Highlight", comment: "Highlight"), normal: UIImage(named: "event_highlight_unselected")!, selected: UIImage(named: "event_highlight_selected")!, color: UIColor.semanticColor(.activity(.manual)))
        setupTypeButton(bufferedButton, title: NSLocalizedString("Buffered", comment: "Buffered"), normal: UIImage(named: "buffered_unselected")!, selected:  UIImage(named: "buffered_selected")! , color: UIColor.semanticColor(.activity(.buffered)))

        #if FLEET
        setupTypeButton(behaviorButton, title: NSLocalizedString("Behavior", comment: "Behavior"), normal: UIImage(named: "behavior unselected")!, selected: UIImage(named: "behavior selected")!, color: UIColor.semanticColor(.activity(.hardBehavior)))
        #endif

        typeButtons = [motionButton, bumpButton, impactButton, highlightButton, bufferedButton, behaviorButton]
        var i = 0
        for button in typeButtons {
            button.tag = i
            i += 1
        }
        refreshTypeButtons()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        var safeSpace:CGFloat = 20
        if #available(iOS 11, *) {
            safeSpace = max(safeSpace - view.safeAreaInsets.bottom, 0)
        }
        doneButtonBottomSpace.constant = safeSpace
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    func refreshCount() {
        numberLabel.text = "\(videoCount)"
        let format: String = NSLocalizedString("Video no count", comment: "Video no count")
        videoLabel.text = String.localizedStringWithFormat(format, videoCount)
    }

    func setupSourceButton(_ button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.semanticColor(.tint(.primary)), for: .selected)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
    }
    
    func setupTypeButton(_ button: UIButton, title: String, normal: UIImage, selected: UIImage, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(color, for: .selected)
        button.setTitleColor(color, for: .highlighted)
        button.setImage(normal, for: .normal)
        button.setImage(selected, for: .selected)
        button.setImage(selected, for: .highlighted)
    }
    
    func refreshSourceButtons() {
        refreshSourceButton(cloudButton, selected: selectedSource == .cloud)
        refreshSourceButton(sdcardButton, selected: selectedSource == .sdcard)
    }
    
    func refreshSourceButton(_ button: UIButton, selected: Bool) {
        button.isSelected = selected
        button.layer.borderColor = (selected ? UIColor.semanticColor(.tint(.primary)) : .white).cgColor
    }
    
    func refreshTypeButtons() {
//        allButton.isSelected = selectedType == .all
        motionButton.isSelected = selectedType.contains(.motion)
        bumpButton.isSelected = selectedType.contains(.hit)
        impactButton.isSelected = selectedType.contains(.heavy)
        highlightButton.isSelected = selectedType.contains(.manual)
        bufferedButton.isSelected = selectedType.contains(.buffered)

        #if FLEET
        behaviorButton.isSelected = selectedType.contains(.behavior)

        // show or hide type stackView
        if selectedSource == .sdcard {
            motionButton.superview?.superview?.superview?.isHidden = false
        } else {
            motionButton.superview?.superview?.superview?.isHidden = true
        }
        #else
        behaviorButton.alpha = 0
        behaviorButton.isUserInteractionEnabled = false
        #endif
    }
    
    @IBAction func onSelectSource(_ sender: UIButton) {
        selectedSource = (sender == sdcardButton ? .sdcard : .cloud)
        refreshSourceButtons()

        #if FLEET
        refreshTypeButtons()
        #endif

        delegate?.onFilterChanged(sender: self)
    }

    @IBAction func onSelectType(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            selectedType.insert(videoTypes[sender.tag])
        } else {
            selectedType.subtract(videoTypes[sender.tag])
        }

        delegate?.onFilterChanged(sender: self)
    }

    @IBAction func onDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.onFilterDismissed(sender: self)
        var prop = Dictionary<String, Any>()
        prop["video_source"] = selectedSource == .sdcard ? "sdcard" : "cloud"
        prop["video_selected_types"] = selectedType.toString()
        MixpanelHelper.track(event: "Button-Filter", properties: prop)
    }

}

extension VideoFilterViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}
