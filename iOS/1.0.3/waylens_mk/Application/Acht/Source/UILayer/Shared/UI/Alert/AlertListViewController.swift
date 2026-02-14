//
//  AlertListViewController.swift
//  Acht
//
//  Created by gliu on 8/23/16.
//  Copyright © 2016 waylens. All rights reserved.
//

import UIKit
#if useMixpanel
import Mixpanel
#endif

//fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l < r
//  case (nil, _?):
//    return true
//  default:
//    return false
//  }
//}
//
//fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l > r
//  default:
//    return rhs < lhs
//  }
//}
import MJRefresh

class AlertListViewController: BaseTableViewController {
    private var refresher: Refresher?
    private var shouldStopRefresherWhenViewDisappear: Bool {
        if alertDetailViewController != nil {
            return false
        } else {
            return true
        }
    }
    private var alertDetailViewController: AlertDetailViewController? {
        return (presentedViewController as? UINavigationController)?.viewControllers.first as? AlertDetailViewController
    }
    private var hasUnreadMessages: Bool = false

    var alertList = Array<AchtAlert>()
    
    let cellID = "AlertListCell"
    var signBoard: HNSignBoard?
    var readAllButton: UIBarButtonItem?
    
    static func createViewController() -> AlertListViewController {
        let vc = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertListViewController")
        return vc as! AlertListViewController
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title = NSLocalizedString("Events", comment: "Events")
        
        navigationController?.tabBarItem.title = title
        
        NotificationCenter.default.addObserver(self, selector: #selector(badgeNumberDidChange), name: Notification.Name.AppIconBadge.numberDidChange, object: nil)

        WaylensClientS.shared.fetchAlertsUnreadCount { (count) in
            if let count = count {
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        #if !FLEET
        readAllButton = UIBarButtonItem(image: #imageLiteral(resourceName: "navbar_more _n"), style: .plain, target: self, action: #selector(onReadAll))
        #endif

        setPullRefreshAction(#selector(refreshData), loadMoreAction: #selector(fetchMoreData))
        
        tableView.mj_header?.beginRefreshing()

        tableView.tableFooterView = UIView()

        #if !FLEET
        let messageButton = UIBarButtonItem(image: #imageLiteral(resourceName: "navbar_message"), style: .plain, target: self, action: #selector(messageButtonTapped(_:)))
        navigationItem.rightBarButtonItem = messageButton
        #endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification), name: NSNotification.Name.Remote.alert, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceListChangedNotification), name: Notification.Name.UnifiedCameraManager.listUpdated, object: nil)
        
        MixpanelHelper.track(event: "Enter Alert Tab")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshMessageIcon()
        togglePromotionDisplay()
        
        if alertList.hasUploadingAlerts {
            if !tableView.mj_header!.isRefreshing {
                refresher?.start()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if shouldStopRefresherWhenViewDisappear {
            refresher?.stop()
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertListCell", for: indexPath) as! AlertListCell
        let alert = alertList[indexPath.row]
        cell.alert = alert
        return cell
    }
    
    //Mark : table view delegate
   
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let alert = alertList[indexPath.row]
        
        return alert.uploadStatus?.isUploading == true ? false : true
    }

    #if !FLEET
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        let alert = self.alertList[indexPath.row]
        
        let hideAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Hide", comment: "Hide")) { (action, indexPath) in
            if !alert.isRead {
                AppIconBadge.decrease()
            }
            alert.remove()
            self.alertList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
        hideAction.backgroundColor = UIColor.semanticColor(.background(.tertiary))
        actions.append(hideAction)
        if !alert.isRead {
            let readAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Mark as Read", comment: "Mark as Read")) { (action, indexPath) in
                alert.read()
                AppIconBadge.decrease()
                tableView.reloadRows(at: [indexPath], with: .right)
            }
            readAction.backgroundColor = UIColor.semanticColor(.background(.quinary))
            actions.append(readAction)
        }
        return actions
    }
    #endif
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let alert = alertList[indexPath.row]
        if alert.isRead == false {
            alert.read()
            AppIconBadge.decrease()
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        let alertVC = AlertDetailViewController.createViewController()
        alertVC.alert = alert
        let navController = BaseNavigationController(rootViewController: alertVC)
        navController.modalPresentationStyle = .fullScreen

        if #available(iOS 13.0, *) {
            navController.modalPresentationStyle = .fullScreen
        }
        
        present(navController, animated: true, completion: nil)
    }

    func noteNewMessage() {
        navigationItem.rightBarButtonItem?.showBadgeDot(withOffset: CGPoint(x: -7.0, y: 12.0))
    }

    private func refreshMessageIcon() {
        WaylensClientS.shared.fetchNotificationsUnreadCount { [weak self] (unreadCount) in
            if let unreadCount = unreadCount, unreadCount > 0 {
                self?.noteNewMessage()
            } else {
                self?.navigationItem.rightBarButtonItem?.hideBadgeDot()
            }
        }
    }
    
    func refreshSignBoard() {
        if alertList.count == 0 {
            if signBoard == nil {
                signBoard = HNSignBoard(frame: CGRect(origin: .zero, size: view.frame.size))
                view.addSubview(signBoard!)
                signBoard?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
            signBoard?.show(
                image: #imageLiteral(resourceName: "icon_notification"),
                title: NSLocalizedString("No Events", comment: "No Events"),
                detail: NSLocalizedString("Events from Secure360 4G will be here", comment: "Events from Secure360 4G will be here"),
                buttonTitle: nil
            )
        } else {
            signBoard?.hide()
        }
    }
    
    func refreshReadButton() {
        #if !FLEET
        if alertList.count > 0 {
            navigationItem.leftBarButtonItem = readAllButton
        } else {
            navigationItem.leftBarButtonItem = nil
        }
        #endif
    }
    
    private func refreshUploadingAlerts() {
        WaylensClientS.shared.fetchUploadingAlerts { [weak self] (uploadingAlerts) in
            guard let strongSelf = self else {
                return
            }
            guard !uploadingAlerts.isEmpty else { // done uploading
                WaylensClientS.shared.fetchAlerts(completion: { (result) in
                    if result.isSuccess {
                        let alerts = (result.value?["alerts"] as! [[String: Any]]).map({ AchtAlert(dict: $0)})
                        let recentUploadingAlerts = strongSelf.alertList.uploadingAlerts
                        let recentUploadedAlerts = alerts.filter({ (alert) -> Bool in
                            return recentUploadingAlerts.contains(where: {$0.alertID == alert.alertID})
                        })
                        
                        recentUploadedAlerts.forEach({ (uploadedAlert) in
                            if let index = strongSelf.alertList.indexOfAlert(uploadedAlert) {
                                strongSelf.alertList[index] = uploadedAlert
                                DispatchQueue.main.async {
                                    strongSelf.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.fade)

                                    if strongSelf.alertDetailViewController?.alert?.alertID == uploadedAlert.alertID {
                                        strongSelf.alertDetailViewController?.alert = uploadedAlert
                                    }
                                }
                            }
                        })
                        strongSelf.refresher?.stop()
                    }
                })
                return
            }
            
            uploadingAlerts.forEach({ (uploadingAlert) in
                if let index = strongSelf.alertList.indexOfAlert(uploadingAlert) {
                    strongSelf.alertList[index] = uploadingAlert
                    
                    DispatchQueue.main.async {
                        strongSelf.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.fade)
                    }
                }
            })
        }
    }
    
    @objc func refreshData() {
        WaylensClientS.shared.fetchAlerts(cursor: 0, count: 20) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.tableView.mj_header?.endRefreshing()
            if result.isSuccess {
                if result.value?["hasMore"] as? Bool ?? false {
                    strongSelf.tableView.mj_footer?.endRefreshing()
                } else {
                    strongSelf.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }

                #if FLEET
                let alerts = (result.value?["events"] as! [[String: Any]]).map({ AchtAlert(dict: $0) }).filter{ $0.eventType != .buffered }
                #else
                let alerts = (result.value?["alerts"] as! [[String: Any]]).map({ AchtAlert(dict: $0)})
                #endif

                strongSelf.alertList.removeAll()
                strongSelf.alertList.append(contentsOf: alerts)
                strongSelf.refreshReadButton()
                strongSelf.tableView.reloadData()
                strongSelf.togglePromotionDisplay()
                
                if let unreadCount = result.value?["unreadCount"] as? Int {
                    NSLog("doanvt - \(unreadCount)")  
//                    AppIconBadge.setNumber(unreadCount)
                }
                
                if strongSelf.alertList.hasUploadingAlerts {
                    if let refresher = strongSelf.refresher {
                        if !refresher.isWorking {
                            refresher.start()
                        }
                    } else {
                        strongSelf.refresher = Refresher(refreshInterval: 5.0, refreshClosure: {
                            strongSelf.refreshUploadingAlerts()
                        })
                        strongSelf.refresher?.start()
                    }
                } else {
                    strongSelf.refresher?.stop()
                }
            } else {
                HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Fetching events failed", comment: "Fetching events failed"), to: self?.navigationController)
                
                strongSelf.refresher?.stop()
            }
            self?.refreshSignBoard()
        }
    }
    
    @objc func fetchMoreData() {
        WaylensClientS.shared.fetchAlerts(cursor: alertList.count, count: 50) { [weak self] (result) in
            if result.isSuccess {
                if result.value?["hasMore"] as? Bool ?? false {
                    self?.tableView.mj_footer?.endRefreshing()
                } else {
                    self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }

                #if FLEET
                let alerts = (result.value?["events"] as! [[String: Any]]).map({ AchtAlert(dict: $0) }).filter{ $0.eventType != .buffered }
                #else
                let alerts = (result.value?["alerts"] as! [[String: Any]]).map({ AchtAlert(dict: $0) })
                #endif

                self?.alertList.append(contentsOf: alerts)
                self?.tableView.reloadData()
            } else {
                HNMessage.showError(message: result.error?.localizedDescription ??  NSLocalizedString("Fetching alerts failed", comment: "Fetching alerts failed"), to: self?.navigationController)
            }
        }
    }

    @objc func onReadAll() {
        let alert = UIAlertController(title: NSLocalizedString("Mark all as read?", comment: "Mark all as read?"), message: nil, preferredStyle: .actionSheetOrAlertOnPad)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .default, handler: { (_) in
            WaylensClientS.shared.readAllAlerts { [weak self] (result) in
                guard let this = self else {
                    return
                }
                if result.isSuccess {
                    for alert in this.alertList {
                        alert.isRead = true
                    }
                    this.tableView.reloadData()
                    AppIconBadge.reset()
                } else {
                    HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Mark all as read failed", comment: "Mark all as read failed"), to: this.navigationController)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
       present(alert, animated: true, completion: nil)
    }
    
    @objc func messageButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showMessage", sender: nil)
    }

    func showMessageViewController(_ selectedMessageID: Int64? = nil, animated: Bool = true) {
        let vc = MessageViewController.createViewController()
        vc.selectedMessageID = selectedMessageID
        navigationController?.pushViewController(vc, animated: animated)
    }

    @objc func onNotification() {
        refreshData()
    }
    
    @objc fileprivate func handleDeviceListChangedNotification() {
        // delay because need time to fetch supports4G state from camera
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
            self?.togglePromotionDisplay()
        }
    }
    
    @objc fileprivate func badgeNumberDidChange() {
//        navigationController?.tabBarItem.setBadgeNumber(AppIconBadge.number)
    }
    
    @objc fileprivate func appDidBecomeActive() {
//        if navigationController?.tabBarItem.badgeNumber != AppIconBadge.number {
//
//        }
    }
}

extension AlertListViewController {
    
    fileprivate var isPromotionDisplayed: Bool {
        return (presentedViewController is CameraPromotionViewController)
    }
    
    fileprivate func showPromotion() {
        if !isPromotionDisplayed {
            let promotionViewController = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "CameraPromotionViewController")
            definesPresentationContext = true
            promotionViewController.modalTransitionStyle = .coverVertical
            promotionViewController.modalPresentationStyle = .overCurrentContext
            present(promotionViewController, animated: true, completion: { [weak self] in
                self?.definesPresentationContext = false
            })
        }
    }
    
    fileprivate func hidePromotion() {
        if isPromotionDisplayed {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func togglePromotionDisplay() {
        if !UnifiedCameraManager.shared.has4gCamera && alertList.isEmpty {
            showPromotion()
        } else {
            hidePromotion()
        }
    }
    
}

fileprivate class Refresher {
    private var timer: Timer?
    private let refreshInterval: TimeInterval
    private let refreshClosure: () -> ()
    
    private(set) var isWorking: Bool = false
    
    init(refreshInterval: TimeInterval, refreshClosure: @escaping () -> ()) {
        self.refreshInterval = refreshInterval
        self.refreshClosure = refreshClosure
    }
    
    func start() {
        if timer != nil {
            stop()
        }

        timer = Timer.every(refreshInterval, { [weak self] in
            self?.refreshClosure()
        })
        isWorking = true
    }
    
    func stop() {
        guard isWorking else {
            return
        }
        
        isWorking = false
        timer?.invalidate()
        timer = nil
    }
    
}
