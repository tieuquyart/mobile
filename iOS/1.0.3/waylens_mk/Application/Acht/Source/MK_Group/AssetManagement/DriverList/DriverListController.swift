//
//  DriverListController.swift
//  Acht
//
//  Created by TranHoangThanh on 2/9/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
//import XLPagerTabStrip
import DropDown
enum VerticalLocation: String {
    case bottom
    case top
}

private extension DriverListController{
    func setBorderView(_ view :UIView){
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
        view.backgroundColor = UIColor.white
        view.layer.masksToBounds = true
    }
}

class DriverListController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchContent: UIView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnClearText: UIButton!
   
    
    var searching = false
    
    var timer: Timer?
    //  @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var listDriver = [DriverItemModel]()
    var searchDriver = [DriverItemModel]()
    init() {
        super.init(nibName: "DriverListController", bundle: nil)
        title = "Tài xế"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        
        collectionView.register(UINib(nibName: "DriverCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DriverCollectionViewCell")
        
        
        
        getListDriver()
        // Do any additional setup after loading the view.
        
        self.collectionView.setPullRefreshActionT(self, refreshAction: #selector(didPullRefresh), loadMoreAction: #selector(didLoadMore))
        tfSearch.placeholder = NSLocalizedString("search", comment: "search")
        setBorderView(searchContent)
        searchContent.addShadow(offset: CGSize(width: 3, height: 4))
        btnClearText.setTitle("", for: .normal)
        btnClearText.isHidden = true
        
        tfSearch.addTarget(self, action: #selector(tfSearchDidChange(_:)), for: .editingChanged)
        tfSearch.delegate = self
    }
    
    @objc func tfSearchDidChange(_ textField: UITextField) {
        let searchText = textField.text
        
        if searchText.isEmpty || searchText == "" {
            searching = false
            searchDriver.removeAll()
            btnClearText.isHidden = true
            self.collectionView.reloadData()
        } else {
            searching = true
            btnClearText.isHidden = false
            searchDriver = listDriver.filter({ val in
                if let name = val.name {
                    return name.range(of: searchText!, options: .caseInsensitive) != nil
                } else {
                    return false
                }
                
            })

        }
        self.collectionView.reloadData()
    }
    
    @IBAction func clearTextSearch(sender: UIButton){
        searching = false
        tfSearch.text = ""
        searchDriver.removeAll()
        self.tfSearch.endEditing(true)
        self.collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            self.btnClearText.isHidden = true
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfSearch.resignFirstResponder()
        tfSearchDidChange(textField)
        return true
    }
    
    
    @objc func didPullRefresh() {
        print("didPullRefresh")
        index = 1
        getListDriver()
        self.collectionView.mj_header?.endRefreshing()
    }
    
    var index = 1
    
    @objc func didLoadMore() {
        print("didLoadMore")
        index += 1
        getMoreDriver(current: index)
        self.collectionView.mj_footer?.endRefreshing()
        
    }
    
    func getMoreDriver(current: Int) {
        
        let parameters: [String : Any] = [
            "current" : current,
            "size" : 10,
        ]
        
        DriverService.shared.driver_by_page(pr :  parameters , completion: { (result) in
            switch result {
            case .success(let value):
                
                ConstantMK.parseJson(dict: value){ success, msg, code in
                    if success {
                        
                        if let data = value["data"] as? JSON {
                            if let vehicleInfos = data["records"] as? [JSON] {
                                if let infoData = try? JSONSerialization.data(withJSONObject: vehicleInfos, options: []){
                                    do {
                                        
                                        let itemsMore = try JSONDecoder().decode([DriverItemModel].self, from: infoData)
                                        
                                        if !itemsMore.isEmpty {
                                            self.listDriver.append(contentsOf: itemsMore)
                                            self.collectionView.reloadData()
                                        }
                                        
                                    } catch let err {
                                        print("err get Driver",err)
                                    }
                                }
                            }
                        }
                    }else{
                        self.showErrorResponse(code: code)
                    }
                }
             
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }
        })
        
    }
    
    func getListDriver() {
        let parameters: [String : Any] = [
            "current" : 1,
            "size" : 10,
        ]
        DriverService.shared.driver_by_page(pr :  parameters , completion: { (result) in
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: {success, msg, code in
                    if success{
                        if let data = value["data"] as? JSON {
                            if let vehicleInfos = data["records"] as? [JSON] {
                                if let infoData = try? JSONSerialization.data(withJSONObject: vehicleInfos, options: []){
                                    do {
                                        var items = try JSONDecoder().decode([DriverItemModel].self, from: infoData)
                                        let new = DriverItemModel()
                                        items.insert(new, at: 0)
                                        self.listDriver.removeAll()
                                        self.listDriver = items
                                        self.collectionView.reloadData()
                                    } catch let err {
                                        print("err get Driver",err)
                                    }
                                }
                            }
                        }
                    }else{
                        self.showErrorResponse(code: code)
                    }
                })
                
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }
        })
        
        
    }
    
    
    
    let chooseMoreDropDown = DropDown()
    func customizeDropDown(view : UIView , model : DriverItemModel) {
        
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
        chooseMoreDropDown.anchorView = view
        chooseMoreDropDown.width = view.frame.width * 0.9
        let height = (chooseMoreDropDown.anchorView?.plainView.bounds.height)! - 60
//        print("hooseMoreDropDown.anchorView?.plainView.bounds.height", height)
        chooseMoreDropDown.bottomOffset = CGPoint(x: 0, y:height)
        chooseMoreDropDown.topOffset = CGPoint(x: 0, y: -(height))
        chooseMoreDropDown.direction = .any
        chooseMoreDropDown.dataSource = ["Chi tiết", "Chỉnh Sửa", "Xóa"]
        
        chooseMoreDropDown.cellNib = UINib(nibName: "MyCell", bundle: nil)
        
        chooseMoreDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            //            MyCell
            guard let cell = cell as? MyCell else { return }
            //
            //            // Setup your custom UI components
            cell.logoImageView.image = UIImage(named: "logo_\(index % 10)")
            if index == 2 {
                appearance.textColor = UIColor.red
            }
        }
        self.chooseMoreDropDown.show()
        
        
        chooseMoreDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            switch index {
            case 0:
                let vc = DriverDetailController()
                vc.delegate = self
                vc.model = model
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case 1:
                self.editVC(model)
                break
            case 2:
                self.remove(model)
                break
            default:
                break
            }
        }
        
    }
    
    func editVC(_ model : DriverItemModel){
        let vc = AddDriverController()
        vc.isAddDrive = false
        vc.model = ParamDriver(birthDate: model.birthDate ?? "", drivingYears: model.drivingYears ?? "" , employeeId: model.employeeId ?? "" , gender: model.gender ?? 0 , idNumber: model.idNumber ?? "", license: model.license ?? "" , licenseType: model.licenseType ?? "" , name: model.name ?? "" , phoneNo: model.phoneNo ?? "")
        vc.id = model.id
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func remove(_ model : DriverItemModel) {
        
        self.alert(message: NSLocalizedString("Are you sure to remove this Driver?", comment: "Are you sure to remove this Driver?"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .destructive, handler: { [weak self] (action) in
                
                self?.removeDriver(id : model.id ?? 0)
                
            })
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Yes"), style: .cancel, handler: { (action) in
            })
        }
    }
    func  removeDriver(id : Int) {
        
        DriverService.shared.delete(id : id , completion: { [weak self] (result) in
            if let strongSelf = self {
                switch result {
                case .success(let value):
                    print("value ta", value.description)
                    
                    ConstantMK.parseJson(dict: value, handler: {success, msg, code in
                        if let data = value["data"] as? Bool {
                            
                            if data {
                                strongSelf.didPullRefresh()
                            }
                            
                            strongSelf.toastMessage(message: msg)
                            
                        }else {
                            strongSelf.showErrorResponse(code: code)
                        }
                    })
                case .failure(let error):
                    HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
                }
            }
            
        })
    }
    
}

extension DriverListController : UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searching ? searchDriver.count: listDriver.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DriverCollectionViewCell", for: indexPath) as! DriverCollectionViewCell
        
        let item = searching ? searchDriver[indexPath.row] : listDriver[indexPath.row]
        cell.delegate = self
        cell.configDriver(item: item)
        
        return cell
    }
    
    
}

extension DriverListController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = (view.frame.width - 32) / 2
//        return .init(width: width, height: width / 2 )
        let width = collectionView.frame.width / 2
        let height = width / 2
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 0, right: 0)
    }
  
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DriverListController : AddVehicleControllerDelegate {
    func reloadData() {
        self.getListDriver()
    }
}


extension DriverListController : DriverCollectionViewCellDelegate {
    func tapMoreCamera(view: UIView, item: CameraItemModel) {
        
    }
    
    func tapMoreVehicle(view: UIView, item: VehicleItemModel) {
        
    }
    
    func tapAdd() {
        let vc = AddDriverController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func  tapMoreDriver(view : UIView , item : DriverItemModel) {
        self.customizeDropDown(view: view , model : item)
    }
}

