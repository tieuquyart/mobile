//
//  HNCSProfileViewController.swift
//  Acht
//
//  Created by Chester Shen on 9/13/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class HNCSProfileViewController: BaseTableViewController, CameraRelated {
//    @IBOutlet weak var saveButton: UIBarButtonItem!
    weak var nameTextField: UITextField?
    
    var showShortVersion : Bool = true {
        didSet {
            refreshUI()
        }
    }
    var camera: UnifiedCamera? {
        didSet {
            refreshUI()
        }
    }
    
    var info = [(String, String?)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initHeader(text: NSLocalizedString("Device Information", comment: "Device Information"), leftButton: false)
        
        tableView.tableFooterView = UIView()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = saveButton
//        saveButton.isEnabled = false
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        tableView.register(UINib(nibName: HNProfileInputCell.cellID, bundle: nil), forCellReuseIdentifier: HNProfileInputCell.cellID)
        tableView.register(UINib(nibName: HNInformationCell.cellID, bundle: nil), forCellReuseIdentifier: HNInformationCell.cellID)
        tableView.register(UINib(nibName: HNTableViewCell.cellID, bundle: nil), forCellReuseIdentifier: HNTableViewCell.cellID)
        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
        tableView.sectionHeaderHeight = 12
        refreshUI()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBack))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
        
    }
    
    @objc func leftBack(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onSave(self)
    }

    func refreshUI() {
        if !isViewLoaded { return }
        info.removeAll()
//        var firmwareString = ""
//        if let v_short = camera?.firmwareShort, let v = camera?.firmware {
//            firmwareString = "\(v_short)(\(v))"
//        }

        #if FLEET
        if camera?.viaWiFi == true {
            info.append(contentsOf: [
                (NSLocalizedString("Serial Number", comment: "Serial Number"), camera?.sn),
                (NSLocalizedString("Model", comment: "Model"), camera?.model),
                (NSLocalizedString("Version", comment: "Version"), showShortVersion ? camera?.firmwareShort : camera?.firmware),
                (NSLocalizedString("Mount Model", comment: "Mount Model"), camera?.mountHwModel),
                (NSLocalizedString("Mount Version", comment: "Mount Version"), camera?.mountFwVersion),
                (NSLocalizedString("Driver name", comment: "Driver name"), camera?.nameDriver)
                ])
        } else {
            info.append(contentsOf: [
                (NSLocalizedString("Serial Number", comment: "Serial Number"), camera?.sn),
                (NSLocalizedString("Model", comment: "Model"), camera?.model),
                (NSLocalizedString("Version", comment: "Version"), showShortVersion ? camera?.firmwareShort : camera?.firmware)
                ])
        }
        #else
        info.append(contentsOf: [
            (NSLocalizedString("Serial Number", comment: "Serial Number"), camera?.sn),
            (NSLocalizedString("Model", comment: "Model"), camera?.model),
            (NSLocalizedString("Version", comment: "Version"), showShortVersion ? camera?.firmwareShort : camera?.firmware),
            (NSLocalizedString("Mount Model", comment: "Mount Model"), camera?.mountHwModel),
            (NSLocalizedString("Mount Version", comment: "Mount Version"), camera?.mountFwVersion)
            ])
        #endif

        if let modem = camera?.local?.lteFirmwareVersionPublic {
            info.append((NSLocalizedString("Modem Version", comment: "Modem Version"), modem))
        }
        if let modem2 = camera?.local?.lteFirmwareVersionInternal {
            if UserSetting.shared.debugEnabled {
                info.append((NSLocalizedString("Modem Version", comment: "Modem Version"), modem2))
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func onSave(_ sender: Any) {
        let newString = nameTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if camera?.name != newString && nameIsValid(newString) {
            camera?.name = newString
        }
//        navigationController?.popViewController(animated: true)
    }
    
    func nameIsValid(_ name: String?) ->Bool {
        guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return false
        }
        return name != "" && name.count <= 20
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return camera?.supports4g ?? false ? 3 : 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return info.count
        } else if section == 2 {
            return 1
        } else {
            return 0
        }
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        } else if indexPath.section == 1{
            return 44
        } else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HNProfileInputCell.cellID, for: indexPath) as! HNProfileInputCell

            cell.selectionStyle = .none
            cell.textField.delegate = self
            cell.titleLabel.text = NSLocalizedString("Name", comment: "Name")
            cell.textField.text = camera?.name
            nameTextField = cell.textField

            #if FLEET
            nameTextField?.isEnabled = false
            nameTextField?.rightView = nil
            #endif

            return cell
        } else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: HNInformationCell.cellID, for: indexPath)
            let (title, value) = info[indexPath.row]
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = value
            cell.detailTextLabel?.numberOfLines = 2
//            cell.detailTextLabel.addGestureRecognizer(longpress)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: HNTableViewCell.cellID, for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Network", comment: "Network")
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            nameTextField?.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 2 {
            showShortVersion = !showShortVersion
        } else if indexPath.section == 2 {
            let vc = HNCSNetworkViewController(style: .grouped)
            vc.camera = camera
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            let (_, value) = info[indexPath.row]
            UIPasteboard.general.string = value
        }
    }
}

extension HNCSProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = textField.text as NSString?
        let newString = currentString?.replacingCharacters(in: range, with: string)
        let shouldChange = newString?.count ?? 0 <= 20
        return shouldChange
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let name = textField.text {
            textField.text = name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
