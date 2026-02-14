//
//  ExportProgressViewController.swift
//  Acht
//
//  Created by Chester Shen on 1/25/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

protocol ExportProgressViewDelegate:NSObjectProtocol {
    func shouldShowGoToAlbumButtonWhenFinish() -> Bool
    func onCancel()
    func onDone()
    func onRetry()
    func onGoToAlbum()
}

class ExportProgressViewController: BaseViewController {

    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: MMSlidingButton!
    @IBOutlet weak var subButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var topProgressLength: NSLayoutConstraint!
    @IBOutlet weak var bottomProgressLength: NSLayoutConstraint!
    @IBOutlet weak var rightProgressLength: NSLayoutConstraint!
    @IBOutlet weak var leftProgressLength: NSLayoutConstraint!
    weak var delegate: ExportProgressViewDelegate?
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var progressInfoLabel: UILabel!
    var state: ExportState = .exporting {
        didSet {
            if isViewLoaded {
                refreshButtons()
            }
        }
    }
    var progress: Float = 0 {
        didSet {
            if progress >= 1 {
                progressInfoLabel.text = NSLocalizedString("Exported successfully", comment: "Exported successfully")
            } else {
                progressInfoLabel.text = String(format: NSLocalizedString("Exporting   %.2f%%", comment: "Exporting   %.2f%%"), progress * 100)
            }
        }
    }
    
    static func createViewController() -> ExportProgressViewController {
        let vc = UIStoryboard(name: "CameraDetail", bundle: nil).instantiateViewController(withIdentifier: "ExportProgressViewController")
        return vc as! ExportProgressViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        cancelButton.setTitle("Cancel", for: .normal)
//        cancelButton.applyClearStyle()
//        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.buttonFont = UIFont.systemFont(ofSize: 14)
        cancelButton.delegate = self
        doneButton.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
        doneButton.applyMainStyle()
        doneButton.setTitleColor(.white, for: .normal)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshButtons() {
        switch state {
        case .exportTriggered:
            cancelButton.isHidden = false
            doneButton.isHidden = true
            subButton.isHidden = true
        case .exported:
            cancelButton.isHidden = true
            doneButton.isHidden = false
            doneButton.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
            if delegate?.shouldShowGoToAlbumButtonWhenFinish() == true {
                subButton.isHidden = false
                subButton.setTitle(NSLocalizedString("Go to Album", comment: "Go to Album"), for: .normal)
            } else {
                subButton.isHidden = true
            }
        case .failed:
            cancelButton.isHidden = true
            doneButton.isHidden = false
            doneButton.setTitle(NSLocalizedString("Retry", comment: "Retry"), for: .normal)
            subButton.isHidden = false
            subButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
        default:
            break
        }
    }
    
    @IBAction func onDone(_ sender: Any) {
        if state == .exported {
            delegate?.onDone()
        } else if state == .failed {
            delegate?.onRetry()
        }
    }
    
    @IBAction func subButtonTapped(_ sender: Any) {
        if state == .exported {
            delegate?.onGoToAlbum()
        } else {
            delegate?.onCancel()
        }
    }
}

extension ExportProgressViewController: SlideButtonDelegate {
    func buttonStatus(status: String, sender: MMSlidingButton) {
        if status == "Unlocked" {
            delegate?.onCancel()
        }
    }
}
