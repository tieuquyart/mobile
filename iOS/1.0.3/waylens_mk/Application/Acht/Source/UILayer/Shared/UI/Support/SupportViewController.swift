//
//  SupportViewController.swift
//  Acht
//
//  Created by Chester Shen on 1/11/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SupportViewController: BaseTableViewController {
    let expandableCellId = "ExpandableCell"
    var expandableModels = [ExpandableCellModel]()
    let faqs: [(String, String, String?, String?)] = [
        ("How do you install the Secure360 power connection?", "Installation of the Secure360 takes a matter of minutes.\n\nThe Direct Wire has three wires to connect:\n1) constant electric\n2) ACC (used to determine engine status)\n3) ground\n\nYour Secure360 will ship with clear instructions for installation. The Direct-Wire Cable can be installed by anyone familiar with automotive electrical systems. If in doubt, see your car dealer or a car radio installer.", "Watch video tutorial", "\(UserSetting.shared.webServer.rawValue)/support/faq/33/0/2938?webview=1"),
        ("How does the Waylens Secure360 record and when?", "Video is recorded in two modes, driving mode and parking mode. The Secure360 camera switches between these modes automatically.\n\nWhile in parking mode, the Secure360’s advanced power management keeps the camera alert to events when your vehicle is in park, without draining your battery. As an event such as a bump or collision or break-in is detected, the Secure360 will boot up and record that event, after which it will sleep again and wait for the next event.\n\nWhile in driving mode, the camera records in a constant looping mode. If the Secure360 detects abnormal movement, as in a collision, a highlight video is automatically generated for easy location by the user. For the 4G model, this highlight is instantly uploaded to the Waylens Cloud.", nil , nil),
        ("How does the Secure360 manage storage on the microSD card?", "For video storage on the Secure360, Waylens recommends high-endurance SD cards (class 10 or higher MLC MicroSD cards) with a minimum size of 32GB, accommodating SD cards up to 256GB.\n\nIn driving mode, the Secure360 records video in looping fashion with the latest footage automatically overriding the earliest footage as storage becomes full. Videos for security events and user-specified highlights also loop (with new events and highlights overwrite the oldest ones to make sure the user doesn’t miss new evidence), but cannot be overwritten by regular driving footage. To ensure this preservation of critical event data, sufficient space (8GB minimum) is allocated for looping of driving video.\n\nFor the 4G model only, all captured event data is also automatically uploaded in real-time to the Waylens Cloud.", nil, nil)
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Support", comment: "Support")
        tableView.register(UINib(nibName: "ExpandableCell", bundle: nil), forCellReuseIdentifier: expandableCellId)
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = Constants.UI.sectionHeaderHeight
        for _ in faqs {
            expandableModels.append(ExpandableCellModel())
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 3
        case 1:
            return expandableModels.count + 1
        case 2:
            return 4
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        #if FLEET
        if section == 1 {
            return 0.01
        }
        #endif

        return tableView.sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        #if FLEET
        switch indexPath.section {
        case 0:
            return 68
        case 1:
            return 0.0
        case 2:
            if indexPath.row != 2 {
                return 0.0
            }
        default:
            break
        }
        return 60
        #else
        switch indexPath.section {
        case 0:
            return 68
        case 1:
            if indexPath.row < expandableModels.count {
                return expandableModels[indexPath.row].height
            } else {
                return 44
            }
        default:
            return 60
        }
        #endif
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("Guide", comment: "Guide")
        case 1:
            #if FLEET
            return nil
            #else
            return NSLocalizedString("FAQ", comment: "FAQ")
            #endif
        case 2:
            return NSLocalizedString("Need more help?", comment: "Need more help?")
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitle", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = NSLocalizedString("Start Tour", comment: "Start Tour")
                cell.detailTextLabel?.text = NSLocalizedString("Take a tour of the camera and app", comment: "Take a tour of the camera and app")
            case 1:
                cell.textLabel?.text = NSLocalizedString("Network", comment: "Network")
                cell.detailTextLabel?.text = NSLocalizedString("Test 4G LTE connection", comment: "Test 4G LTE connection")
            case 2:
                cell.textLabel?.text = NSLocalizedString("Power Cord", comment: "Power Cord")
                cell.detailTextLabel?.text = NSLocalizedString("Test power cord circuit", comment: "Test power cord circuit")
            default:
                break
            }
        case 1:
            if indexPath.row < expandableModels.count {
                cell = tableView.dequeueReusableCell(withIdentifier: expandableCellId, for: indexPath)
                guard let expandableCell = cell as? ExpandableCelldev else { break }
                let faq = faqs[indexPath.row]
                expandableCell.titleLabel.text = faq.0
                expandableCell.detailLabel.text = faq.1
                if let moreTitle = faq.2 {
                    expandableCell.delegate = self
                    expandableCell.moreButton.isHidden = false
                    expandableCell.moreButton.setTitle(moreTitle, for: .normal)
                }
                let model = expandableModels[indexPath.row]
                // if should animate, set initial state first, else set completed state
                expandableCell.setExpanded(model.isExpanded != model.shouldAnimated, animated: false)
                model.collapseHeight = expandableCell.height(forWidth: tableView.bounds.width, expanded: false)
                model.expandedHeight = expandableCell.height(forWidth: tableView.bounds.width, expanded: true)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "get_more", for: indexPath)
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = NSLocalizedString("Ask Community", comment: "Ask Community")
            case 1:
                cell.textLabel?.text = NSLocalizedString("Contact Support", comment: "Contact Support")
            case 2:
                cell.textLabel?.text = NSLocalizedString("Report an Issue", comment: "Report an Issue")
            case 3:
                cell.textLabel?.text = NSLocalizedString("Watch Video Tutorials", comment: "Watch Video Tutorials")
            default:
                break
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1, let expandableCell = cell as? ExpandableCelldev {
            let model = expandableModels[indexPath.row]
            expandableCell.setExpanded(model.isExpanded, animated: model.shouldAnimated)
            model.shouldAnimated = false
        }
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                #if !FLEET
                appDelegate.guideHelper.restartGuide()
                #endif
            case 1:
                let vc = NetworkDiagnosisViewController.createViewController()
                navigationController?.pushViewController(vc, animated: true)
            case 2:
                let success = showPowerCordTestIfPossible()
                if !success {
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            default:
                break
            }
        case 1:
            if indexPath.row < expandableModels.count {
                let model = expandableModels[indexPath.row]
                model.isExpanded = !model.isExpanded
                model.shouldAnimated = true
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                let vc = BaseWebViewController()
                vc.title = NSLocalizedString("FAQ", comment: "FAQ")
                vc.url = URL(string: "\(UserSetting.shared.webServer.rawValue)/support/faq/28?webview=1")
                navigationController?.pushViewController(vc, animated: true)
            }
        case 2:
            switch indexPath.row {
            case 0:
                loginOrOpen(RedirectForumViewController())
            case 1:
                loginOrOpen(FXOChatViewController(), shouldPresent: false)
            case 2:
                loginOrOpen(FeedbackController.createViewController())
            case 3:
                let vc = BaseWebViewController()
                vc.title = NSLocalizedString("Video Tutorials", comment: "Video Tutorials")
                vc.url = URL(string: "\(UserSetting.shared.webServer.rawValue)/support/guide/1?webview=1")
                navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        default:
            break
        }
    }
    
    func loginOrOpen(_ vc:UIViewController, shouldPresent:Bool=false) {
        if AccountControlManager.shared.isAuthed {
            if shouldPresent {
                present(vc, animated: true, completion: nil)
            } else {
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            AppViewControllerManager.gotoLogin()
        }
    }

}

extension SupportViewController: ExpandableCellDelegate {
    func onMoreButton(sender: ExpandableCelldev) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        let faq = faqs[indexPath.row]
        guard let urlString = faq.3, let url = URL(string: urlString) else { return }
        let vc = BaseWebViewController()
//        vc.title = NSLocalizedString("FAQ", comment: "FAQ")
        vc.url = url
        navigationController?.pushViewController(vc, animated: true)
    }
}
