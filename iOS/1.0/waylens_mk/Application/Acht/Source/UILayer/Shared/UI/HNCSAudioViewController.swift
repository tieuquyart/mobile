//
//  HNCSAudioViewController.swift
//  Acht
//
//  Created by Chester Shen on 6/11/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WaylensCameraSDK

class HNCSAudioViewController: BaseTableViewController, CameraRelated {
    @objc var camera: UnifiedCamera? {
        didSet {
            camera?.local?.getAudioPromptEnabled()
            if isViewLoaded {
                refreshUI()
            }
        }
    }
    @IBOutlet weak var speakerSwitch: UISwitch!
    @IBOutlet weak var sirenSwitch: UISwitch!
    @IBOutlet weak var micSwitch: UISwitch!
    var isVisible: Bool = false
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rx.observeWeakly(Bool.self, #keyPath(camera.local.isMute))
            .subscribe(onNext: { [weak self] muted in
                if let this = self, let muted = muted {
                    this.micSwitch.setOn(!muted, animated: true)
                }
            }).disposed(by: disposeBag)
        title = NSLocalizedString("Audio", comment: "Audio")
        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
        tableView.sectionHeaderHeight = 12
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camera?.local?.settingsDelegate = self
        refreshUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVisible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
    }
    
    func refreshUI() {
        tableView.reloadData()
        guard let camera = camera else {
            return
        }
        speakerSwitch.setOn(camera.local?.isAudioPromptEnabled ?? false, animated: isVisible)
        sirenSwitch.setOn(!(camera.local?.isMute ?? false), animated: isVisible)
        sirenSwitch.setOn(camera.siren == .on, animated: isVisible)
    }
    
    // MARK: - Actions
    @IBAction func onSwitchMic(_ sender: UISwitch) {
        let gain = camera?.local?.micLevel ?? 8
        camera?.local?.setMicMute(!sender.isOn, gain: gain)
    }
    
    @IBAction func onSwitchSpeaker(_ sender: UISwitch) {
        camera?.local?.setAudioPromptEnabled(sender.isOn)
    }
    
    @IBAction func onSwitchSiren(_ sender: UISwitch) {
        camera?.siren = sender.isOn ? .on : .off
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = camera else { return 0 }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let camera = camera else { return 0 }
        if section == 1 {
            if camera.featureAvailability.isAudioPromptSettingsAvailable {
                return super.tableView(tableView, numberOfRowsInSection: section)
            } else {
                return 1
            }
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let settingCell = cell as? CameraSettingCell {
            settingCell.isEnabled = (camera?.local != nil)
        }

        cell.selectionStyle = .none
        cell.textLabel?.usingDynamicTextColor = true
        return cell
    }
   
}

extension HNCSAudioViewController: WLCameraSettingsDelegate {
    func onGetAudioPromptEnabled(_ enabled: Bool) {
        speakerSwitch.setOn(camera?.local?.isAudioPromptEnabled ?? false, animated: isVisible)
    }
}
