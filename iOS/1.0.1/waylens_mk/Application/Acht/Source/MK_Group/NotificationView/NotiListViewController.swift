//
//  NotiListViewController.swift
//  Fleet
//
//  Created by TranHoangThanh on 8/11/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import DropDown
import SVProgressHUD

class NotiListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var listNoti : [NotiItem] = []
    var searchNoti = [NotiItem]()
    var searching = false
    var categorySearch = "ALL"
    
    
    @IBOutlet weak var btnShowListNoti: ButtonShowView!
    
    @IBOutlet weak var viewContainerShowList: UIView!
    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initHeader(text: "Danh sách thông báo", leftButton: true)
        tableView.register(UINib(nibName: "CellNotification", bundle: nil), forCellReuseIdentifier: "CellNotification")
        tableView.dataSource = self
        tableView.delegate = self
        btnShowListNoti.delegate = self
        getListNotifi()
        unread_total()
        self.btnShowListNoti.infoLabel.text = NSLocalizedString("ALL", comment: "ALL")
        self.categorys = [getStringFromCategory("ALL"),
                          getStringFromCategory("ACCOUNT"),
                          getStringFromCategory("PAYMENT"),
                          getStringFromCategory("DRVN"),
                          getStringFromCategory("DMS"),
//                          getStringFromCategory("FORWARD_COLLISION"),
                          getStringFromCategory("ACCELERATOR"),
                          getStringFromCategory("HEADWAY_MONITORING"),
//                          getStringFromCategory("MANUAL"),
//                          getStringFromCategory("PARKING_HIT"),
//                          getStringFromCategory("SYSTEM"),
                          getStringFromCategory("IGNITION")]
        setupChooseDropDown()
        
        self.tableView.setPullRefreshActionT(self, refreshAction: #selector(didPullRefresh), loadMoreAction: #selector(didLoadMore))
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(didPullRefresh), name: Notification.Name.ReloadNotiList.reload, object: nil)
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    let chooseDropDown = DropDown()
    
    var categorys : [String]  = []
    
    func getStringFromCategory(_ val : String) -> String {
        
        switch (val){
            
        case "HEADWAY_MONITORING":
            return NSLocalizedString("HEADWAY_MONITORING", comment: "HEADWAY_MONITORING")
            // return context.getString(R.string.driver_managemant);
        case "ACCELERATOR":
            return NSLocalizedString("ACCELERATOR", comment: "ACCELERATOR")
//        case "MANUAL":
//            return NSLocalizedString("MANUAL", comment: "MANUAL")
//        case "PARKING_HIT":
//            return NSLocalizedString("PARKING_HIT", comment: "PARKING_HIT")
            //return context.getString(R.string.parking_hit);
        case "DMS":
            return NSLocalizedString("DMS", comment: "DMS")
//        case "SYSTEM":
//            return NSLocalizedString("SYSTEM", comment: "SYSTEM")
            //   return context.getString(R.string.system);
        case "IGNITION":
            return NSLocalizedString("IGNITION", comment: "IGNITION")
        case "DRVN":
            return NSLocalizedString("DRVN", comment: "DRVN")
        case "PAYMENT":
            return NSLocalizedString("PAYMENT", comment: "PAYMENT")
        case "ACCOUNT":
            return NSLocalizedString("ACCOUNT", comment: "ACCOUNT")
//        case "FORWARD_COLLISION":
//            return NSLocalizedString("FORWARD_COLLISION", comment: "FORWARD_COLLISION")
        case "ALL":
            return NSLocalizedString("ALL", comment: "ALL")
        default:
            return val;
        }
        
    }
    
    func getCategoryFromString(_ val : String) -> String {
        
        switch (val){
            
        case NSLocalizedString("HEADWAY_MONITORING", comment: "HEADWAY_MONITORING"):
            return "HEADWAY_MONITORING"
            // return context.getString(R.string.driver_managemant);
        case NSLocalizedString("ACCELERATOR", comment: "ACCELERATOR"):
            return "ACCELERATOR"
//        case NSLocalizedString("MANUAL", comment: "MANUAL"):
//            return "MANUAL"
//        case NSLocalizedString("PARKING_HIT", comment: "PARKING_HIT"):
//            return "PARKING_HIT"
        case NSLocalizedString("DMS", comment: "DMS"):
            return "DMS"
//        case NSLocalizedString("SYSTEM", comment: "SYSTEM"):
//            return "SYSTEM"
        case NSLocalizedString("IGNITION", comment: "IGNITION"):
            return "IGNITION"
        case NSLocalizedString("DRVN", comment: "DRVN"):
            return "DRVN"
        case NSLocalizedString("PAYMENT", comment: "PAYMENT"):
            return "PAYMENT"
        case NSLocalizedString("ACCOUNT", comment: "ACCOUNT"):
            return "ACCOUNT"
//        case NSLocalizedString("FORWARD_COLLISION", comment: "FORWARD_COLLISION"):
//            return "FORWARD_COLLISION"
        case NSLocalizedString("ALL", comment: "ALL"):
            return "ALL"
        default:
            return "ALL";
        }
        
    }
    
    func setupChooseDropDown() {
        
        chooseDropDown.anchorView = btnShowListNoti
        
        chooseDropDown.direction = .bottom
        
        chooseDropDown.bottomOffset = CGPoint(x: 40, y: btnShowListNoti.viewBorder.bounds.height)
        
   
        chooseDropDown.dataSource = categorys
       
        
        chooseDropDown.selectionAction = { [weak self] (index , searchText) in
           
            
            self?.btnShowListNoti.infoLabel.text = searchText
            self?.categorySearch = self?.getCategoryFromString(searchText) ?? ""
            
            
            if self?.categorySearch == "ALL" {
                self?.getListNotifi()
            } else {
                
                self?.getNotiWithCategory(category: self?.categorySearch ?? "")
            }
        }
    }
    var index = 0
    var total = 0;
    
    @objc func reloadList(){
        refreshWithCurrentIndex(true)
    }
    
    @objc func didPullRefresh() {
        print("didPullRefresh")
        unread_total()
        refreshWithCurrentIndex(false)
        self.tableView.mj_header?.endRefreshing()
    }
    
    func refreshWithCurrentIndex(_ with: Bool){
        if with {
            if categorySearch == "ALL"{
                getMoreNotifi(index: index)
            }else{
                getMoteNotiWithCategory(category: self.categorySearch, index: index)
            }
        }else{
            index = 0
            if categorySearch == "ALL"{
                getListNotifi()
            }else{
                getNotiWithCategory(category: self.categorySearch)
            }
        }
    }
    
    @objc func didLoadMore(){
        print("didLoadMore")
        if index < total - 1 {
            index += 1
            if categorySearch == "ALL"{
                getMoreNotifi(index: index)
            }else{
                getMoteNotiWithCategory(category: self.categorySearch, index: index)
            }
            self.tableView.mj_footer?.endRefreshing()
        }
    }
    
    func unread_total() {
        print("unread_total: start call")
        let currentDate = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let toDate = df.string(from: currentDate)
        
        let date3Day = NSCalendar.current.date(byAdding: .day, value: -3, to: Date())!
        let fromDate = df.string(from: date3Day)
        
        print("unread: from: \(String(describing: fromDate)) -- to:\(toDate)")
        
        
        NotificationServiceMK.shared.user_notification_unread_total(fromTime: fromDate, toTime: toDate) { (result) in
            
            print("unread_total: \(result)")
            switch result {
            case .success(let value):
                
                ConstantMK.parseJson(dict: value, handler: { success, msg in
                    if !success {
                        if let mess = value["message"] as? String {
                            if mess == "Invalid access token." {
                                self.presentInvalidAccessToken()
                            }
                        }
                    }else{
                        if let unreadCount  = value["data"] as? Int {
                            self.title = "Danh sách thông báo (\(unreadCount))"
                            print("unread_total: set layout finish")
                        }else{
                            self.title = "Danh sách thông báo"
                        }

                    }
                })
                
            case .failure(let err):
                
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }
        }
        
    }
    
    func getNotiWithCategory(category: String){
        self.showProgress()
        NotificationServiceMK.shared.user_notification_page_category(category: category, index: 0, size: 10, completion: {result in
            self.hideProgress()
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value){success, msg in
                    if success{
                        if let datas = value["data"] as? JSON {
                            
                            if let contents = datas["content"] as? [JSON] {
                                
                                if let infoData = try? JSONSerialization.data(withJSONObject: contents, options: []){
                                    
                                    do {

                                        let items = try JSONDecoder().decode([NotiItem].self, from: infoData)

                                        self.listNoti = items
                                        self.tableView.reloadData()

                                    } catch let err {
                                        print("err get noti ",err)
                                    }
                                }
                            }
                            
                            if let totalPage = datas["totalPages"] as? Int{
                                self.total = totalPage
                            }
                                
                            if let currentPage = datas["number"] as? Int{
                                self.index = currentPage;
                            }
                        }
                    }else{
                        if msg == "Invalid access token." {
                            self.presentInvalidAccessToken()
                        } else {
                            let alert = UIAlertController(title: ConstantMK.language(str: "Alert".localizeMk()) , message: ConstantMK.language(str: msg), preferredStyle: UIAlertController.Style.alert)
                            
                            // add the actions (buttons)
                            let ok = UIAlertAction(title: ConstantMK.language(str: "confirm"), style: .default, handler: { _ in
//                                self.navigationController?.popViewController(animated: true)
                            })
                            
                            alert.addAction(ok)
                            
                            
                            // show the alert
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }

            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            
            }
        })
        
    }
    
    func getMoteNotiWithCategory(category: String, index : Int){
        self.showProgress()
        NotificationServiceMK.shared.user_notification_page_category(category: category, index: index, size: 10, completion: {result in
            self.hideProgress()
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value){success, msg in
                    if success{
                        if let datas = value["data"] as? JSON {
                            
                            if let contents = datas["content"] as? [JSON] {
                                
                                if let infoData = try? JSONSerialization.data(withJSONObject: contents, options: []){
                                    
                                    do {

                                        let items = try JSONDecoder().decode([NotiItem].self, from: infoData)

                                        self.listNoti.append(contentsOf: items)
                                        self.tableView.reloadData()

                                    } catch let err {
                                        print("err get noti ",err)
                                    }
                                }
                            }
                            
                            if let totalPage = datas["totalPages"] as? Int{
                                self.total = totalPage
                            }
                                
                            if let currentPage = datas["number"] as? Int{
                                self.index = currentPage;
                            }
                        }
                    }else{
                        if msg == "Invalid access token." {
                            self.presentInvalidAccessToken()
                        } else {
                            let alert = UIAlertController(title: ConstantMK.language(str: "Alert".localizeMk()) , message: ConstantMK.language(str: msg), preferredStyle: UIAlertController.Style.alert)
                            
                            // add the actions (buttons)
                            let ok = UIAlertAction(title: ConstantMK.language(str: "confirm"), style: .default, handler: { _ in
                                self.navigationController?.popViewController(animated: true)
                            })
                            
                            alert.addAction(ok)
                            
                            
                            // show the alert
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
                
            }
        })
    }
    
    
    func getListNotifi() {
        self.showProgress()
        NotificationServiceMK.shared.user_notification_page(index: 0, size: 10, completion: { result in
            self.hideProgress()
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value){success, msg in
                    if success{
                        if let datas = value["data"] as? JSON {
                            
                            if let contents = datas["content"] as? [JSON] {
                                
                                if let infoData = try? JSONSerialization.data(withJSONObject: contents, options: []){
                                    
                                    do {

                                        let items = try JSONDecoder().decode([NotiItem].self, from: infoData)

                                        self.listNoti = items
                                        self.tableView.reloadData()

                                    } catch let err {
                                        print("err get noti ",err)
                                    }
                                }
                            }
                            
                            if let totalPage = datas["totalPages"] as? Int{
                                self.total = totalPage
                            }
                                
                            if let currentPage = datas["number"] as? Int{
                                self.index = currentPage;
                            }
                        }
                    }else{
                        if msg == "Invalid access token." {
                            self.presentInvalidAccessToken()
                        } else {
                            let alert = UIAlertController(title: ConstantMK.language(str: "Alert".localizeMk()) , message: ConstantMK.language(str: msg), preferredStyle: UIAlertController.Style.alert)
                            
                            // add the actions (buttons)
                            let ok = UIAlertAction(title: ConstantMK.language(str: "confirm"), style: .default, handler: { _ in
                                self.navigationController?.popViewController(animated: true)
                            })
                            
                            alert.addAction(ok)
                            
                            
                            // show the alert
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }

            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            
            }
        })
    }
    
    
    
    func getMoreNotifi(index : Int) {
        self.showProgress()
        NotificationServiceMK.shared.user_notification_page(index: index, size: 10, completion: { result in
            self.hideProgress()
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value){success, msg in
                    if success{
                        if let datas = value["data"] as? JSON {
                            
                            if let contents = datas["content"] as? [JSON] {
                                
                                if let infoData = try? JSONSerialization.data(withJSONObject: contents, options: []){
                                    
                                    do {

                                        let items = try JSONDecoder().decode([NotiItem].self, from: infoData)

                                        self.listNoti.append(contentsOf: items)
                                        self.tableView.reloadData()

                                    } catch let err {
                                        print("err get noti ",err)
                                    }
                                }
                            }
                            
                            if let totalPage = datas["totalPages"] as? Int{
                                self.total = totalPage
                            }
                                
                            if let currentPage = datas["number"] as? Int{
                                self.index = currentPage;
                            }
                        }
                    }else{
                        if msg == "Invalid access token." {
                            self.presentInvalidAccessToken()
                        } else {
                            let alert = UIAlertController(title: ConstantMK.language(str: "Alert".localizeMk()) , message: ConstantMK.language(str: msg), preferredStyle: UIAlertController.Style.alert)
                            
                            // add the actions (buttons)
                            let ok = UIAlertAction(title: ConstantMK.language(str: "confirm"), style: .default, handler: { _ in
                                self.navigationController?.popViewController(animated: true)
                            })
                            
                            alert.addAction(ok)
                            
                            
                            // show the alert
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
                
            }
        })
    }

}

extension NotiListViewController : UITableViewDataSource , UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searching ? searchNoti.count : listNoti.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellNotification", for: indexPath) as! CellNotification
        let item = searching ? searchNoti[indexPath.row] :  listNoti[indexPath.row]
        cell.config(model: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = searching ? searchNoti[indexPath.row] :  listNoti[indexPath.row]
        
        if let url = item.url  , url != ""  {
            if let id = item.clipId, id != "" {
                let controller  = PlayVideoEventViewController(notiBean: item)
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                let vc = NotiDetailController(nibName: "NotiDetailController", bundle: nil)
                vc.model = item
                vc.isVideo = true
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
              
        } else {
            
            let vc = NotiDetailController(nibName: "NotiDetailController", bundle: nil)
            vc.model = item
            vc.isVideo = false
            self.navigationController?.pushViewController(vc, animated: true)
          
        }
        
        
       
        
    }
    
    
}



extension NotiListViewController : ButtonShowViewDelegate {
    func showView() {
        chooseDropDown.show()
    }
    
}
