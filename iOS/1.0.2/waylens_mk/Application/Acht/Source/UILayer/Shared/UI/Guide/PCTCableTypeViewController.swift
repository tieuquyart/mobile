//
//  PCTCableTypeViewController.swift
//  Acht
//
//  Created by forkon on 2019/2/21.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class PCTCableTypeViewController: BaseViewController, CameraRelated {
    fileprivate var selectedCableType: PowerCableType? = nil {
        didSet {
            refreshUI()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @objc var camera: UnifiedCamera?

    static func createViewController() -> PCTCableTypeViewController {
        let vc = UIStoryboard(name: "PowerCableTest", bundle: nil).instantiateViewController(withIdentifier: "PCTCableTypeViewController") as! PCTCableTypeViewController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Power Cord Test", comment: "Power Cord Test")
        view.backgroundColor = UIColor.semanticColor(.background(.secondary))

        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onCameraListUpdated), name: Notification.Name.UnifiedCameraManager.listUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI), name: UIApplication.didBecomeActiveNotification, object: nil)
        refreshUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    override func applyTheme() {
        super.applyTheme()

        refreshUI()
    }
    
    @objc func refreshUI() {
        nextButton.isEnabled = (selectedCableType != nil)
        nextButton.backgroundColor = nextButton.isEnabled ? UIColor.semanticColor(.tint(.primary)) : UIColor.semanticColor(.background(.quaternary))

        if let selectedCableType = selectedCableType, let selectedIndex = PowerCableType.allCases.firstIndex(of: selectedCableType) {
            tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PCTVehicleTypeViewController, let selectedCableType = self.selectedCableType  {
            vc.cableType = selectedCableType
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if selectedCableType == .directWire {
            #if FLEET
            var invalidMode: String? = nil
            
            if camera?.local?.isVirtualIgnitionEnabled == true {
                invalidMode = NSLocalizedString("Virtual Ignition", comment: "Virtual Ignition")
            }
            else {
                if camera?.local?.isMountACCTrusted == false {
                    invalidMode = NSLocalizedString("Trust Acc Off", comment: "Trust Acc Off")
                }
            }
            
            if let invalidMode = invalidMode {
                let message = String(format: NSLocalizedString("The camera is in 'xx' mode, so the power cord test cannot be done.\n\nIf a power cord test is required, please contact the administrator to switch the camera to 'Trust Acc' mode.", comment: "The camera is in '%@' mode, so the power cord test cannot be done.\n\nIf a power cord test is required, please contact the administrator to switch the camera to 'Trust Acc' mode."), invalidMode)

                if let setupGuide = parent?.flowGuide as? SetupGuide {
                    alert(title: nil, message: message) {
                        return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
                    } action2: {
                        return UIAlertAction(title: NSLocalizedString("Skip Power Cord Test", comment: "Skip Power Cord Test"), style: UIAlertAction.Style.default) { _ in
                            setupGuide.nextStep()
                        }
                    }
                }
                else {
                    alert(message: message) { [weak self] in
                        return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertAction.Style.default) { _ in
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            else {
                let vc = WireDiagnosisPrepareViewController.createViewController()
                vc.camera = UnifiedCameraManager.shared.local
                navigationController?.pushViewController(vc, animated: true)
            }
            #else
            let vc = WireDiagnosisPrepareViewController.createViewController()
            vc.camera = UnifiedCameraManager.shared.local
            navigationController?.pushViewController(vc, animated: true)
            #endif
            
            return false
        }
        return true
    }
    
    @objc func onCameraListUpdated() {
        let local = UnifiedCameraManager.shared.local
        if camera !== local  {
            camera = local
        }
        refreshUI()
    }

}

extension PCTCableTypeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PowerCableType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CableCell", for: indexPath) as! CableCell
        
        let cableType = PowerCableType.allCases[indexPath.row]
        cell.nameLabel.text = cableType.name
        cell.pictureView.image = cableType.image

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCableType = PowerCableType.allCases[indexPath.row]
    }
    
}

class CableCell: UITableViewCell, Themed {
    @IBOutlet private weak var wrapperView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        selectionStyle = .none
        
        wrapperView.layer.borderColor = UIColor.clear.cgColor
        wrapperView.layer.borderWidth = 1.0
        wrapperView.layer.cornerRadius = 3.0
        wrapperView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        wrapperView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        wrapperView.layer.shadowRadius = 8.0
        wrapperView.layer.shadowOpacity = 1.0
    }

    func applyTheme() {
        backgroundColor = UIColor.clear

        if isSelected {
            nameLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
            nameLabel.textColor = UIColor.semanticColor(.tint(.primary))
            wrapperView.layer.borderColor = UIColor.semanticColor(.tint(.primary)).cgColor
        } else {
            nameLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
            nameLabel.textColor = UIColor.semanticColor(.label(.secondary))
            wrapperView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        applyTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
    
}

enum PowerCableType: CaseIterable {
    case obdCable
    case directWire
}

extension PowerCableType {
    
    var name: String {
        switch self {
        case .obdCable:
            return NSLocalizedString("OBD-Ⅱ", comment: "OBD-Ⅱ")
        case .directWire:
            return NSLocalizedString("Direct Wire", comment: "Direct Wire")

        }
    }
    
    var image: UIImage {
        switch self {
        case .obdCable:
            return UIImage(named: "OBD") ?? UIImage()
        case .directWire:
            return UIImage(named: "direct_wire") ?? UIImage()
        }
    }
    
}
