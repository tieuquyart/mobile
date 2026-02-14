//
//  HNCSMarkSpaceViewController.swift
//  Acht
//
//  Created by gliu on 6/5/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK

class HNCSMarkSpaceViewController: BaseTableViewController, CameraRelated {

    @objc dynamic var camera: UnifiedCamera? {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    var maxMarkSize : Int32?
    var arrayMarkSize : NSArray?

    var capacityObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = 24
//        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
        tableView.backgroundColor = UIColor.color(fromHex: "#EDEEF4")
        capacityObservation = observe(\.camera?.local?.totalMB) { (this, change) in
            Log.debug("Observed totalMB change \(this.camera?.local?.totalMB ?? -1)")
            if this.camera?.local?.totalMB == 0 {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        
        initHeader(text: NSLocalizedString("Event Video Management", comment: "Event Video Management"), leftButton: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camera?.local?.settingsDelegate = self
        if self.camera?.local != nil &&
            camera?.featureAvailability.isMarkSpaceSettingsAvailable == true {
            self.camera?.local?.getMarkStorageOptions()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if camera?.local?.settingsDelegate === self {
            camera?.local?.settingsDelegate = nil
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
    
//    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return NSLocalizedString("sdcard_event_videos_maximum_space_explanation", comment: "Set the maximum space to allocate for event videos. When events reach the selected value, the oldest event video will be removed automatically when a new event video is generated.")
//    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = FooterSDCardView()
        return v
    }	

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayMarkSize != nil {
            return arrayMarkSize!.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = .none
        cell.textLabel?.font = UIFont(name: "BeVietnamPro-Medium", size: 16)
        if arrayMarkSize == nil {
            return
        }
        if maxMarkSize == arrayMarkSize!.object(at: indexPath.row) as? Int32 {
            cell.accessoryType = .checkmark
        }
        cell.textLabel?.text = String.init(format: "%dGB", (arrayMarkSize!.object(at: indexPath.row) as? Int32)!)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if arrayMarkSize?.object(at: indexPath.row) != nil {
            camera?.local?.setMarkStorage((arrayMarkSize!.object(at: indexPath.row) as? Int32)!)
        }
    }
}

extension HNCSMarkSpaceViewController: WLCameraSettingsDelegate {
    func onSetMarkStorage(_ gb: Int32) {
        maxMarkSize = gb
        self.tableView.reloadData()
    }
    func onGetMarkStorageOptions(_ levels: [Any]?, current currentInGB: Int32) {
        maxMarkSize = currentInGB
        arrayMarkSize = NSArray.init(array: levels ?? [])
        self.tableView.reloadData()
    }
}
