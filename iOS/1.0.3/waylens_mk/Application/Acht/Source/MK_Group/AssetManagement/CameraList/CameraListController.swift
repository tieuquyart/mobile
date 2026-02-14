//
//  CameraListController.swift
//  Acht
//
//  Created by TranHoangThanh on 1/12/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
//import XLPagerTabStrip
import MJRefresh
import DropDown



class CameraListController: BaseViewController, UITextFieldDelegate {
    @IBOutlet weak var searchContent: UIView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnClearText: UIButton!
  
    @IBOutlet weak var collectionView: UICollectionView!
    
    var cameras : [CameraItemModel] = []
    var searchCamera = [CameraItemModel]()
    var searching = false
    
    
    
    init() {
        super.init(nibName: "CameraListController", bundle: nil)
        title = "Camera"
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // title = "Danh sách Camera"
        //view.backgroundColor = .yellow
        collectionView.dataSource = self
        collectionView.delegate = self
        //   tableView.tableFooterView = UIView()
        
        collectionView.register(UINib(nibName: "DriverCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DriverCollectionViewCell")
        
        
        getListCamera()
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
            searchCamera.removeAll()
            btnClearText.isHidden = true
            self.collectionView.reloadData()
        } else {
            searching = true
            btnClearText.isHidden = false
            searchCamera = cameras.filter({ val in
                if let name = val.sn {
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
        searchCamera.removeAll()
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
    
    
    var index = 1
    @objc func didPullRefresh() {
        print("didPullRefresh")
        index = 1
        getListCamera()
        self.collectionView.mj_header?.endRefreshing()
    }
    
    @objc func didLoadMore() {
        print("didLoadMore")
        index += 1
        getMoreCamera(current: index)
        self.collectionView.mj_footer?.endRefreshing()
    
        
    }
    
    func getMoreCamera(current: Int) {
        
        let parameters: [String : Any] = [
                      "current" : current,
                      "size" : 10,
                  ]
        
        CameraService.shared.pageInfo(pr :  parameters , completion: { (result) in
         switch result {
            case .success(let value):
             ConstantMK.parseJson(dict: value, handler: {success, msg, code in
                 if success{
                     if let data = value["data"] as? JSON {
                         if let vehicleInfos = data["records"] as? [JSON] {
                             if let infoData = try? JSONSerialization.data(withJSONObject: vehicleInfos, options: []){
                                 do {
                                     let itemsMore = try JSONDecoder().decode([CameraItemModel].self, from: infoData)
                                     if !itemsMore.isEmpty {
                                         self.cameras.append(contentsOf: itemsMore)
                                         self.collectionView.reloadData()
                                     }
                 
                                 } catch let err {
                                     print("err get Camera",err)
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
    
    
    func getListCamera() {
        let parameters: [String : Any] = [
                        "current" : 1,
                        "size" : 10,
                     ]
        
        CameraService.shared.pageInfo(pr :  parameters ,  completion: { (result) in
          switch result {
            case .success(let value):
              ConstantMK.parseJson(dict: value, handler: {success, msg, code in
                  if success{
                      if let data = value["data"] as? JSON {
                          if let vehicleInfos = data["records"] as? [JSON] {
                              if let infoData = try? JSONSerialization.data(withJSONObject: vehicleInfos, options: []){
                                  do {
                                      var items = try JSONDecoder().decode([CameraItemModel].self, from: infoData)
                                      let new = CameraItemModel()
                                      items.insert(new, at: 0)
                                      self.cameras.removeAll()
                                      self.cameras = items
                                      self.collectionView.reloadData()
                                  } catch let err {
                                      print("err get Camera",err)
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
    func customizeDropDown(view : UIView , model : CameraItemModel) {
        
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
        
        chooseMoreDropDown.cellNib = UINib(nibName: "MyCell", bundle: nil)
        
        if model.status == 0 {
            chooseMoreDropDown.dataSource = ["Chi tiết", "Chỉnh sửa", "Kích hoạt", "Xóa"]
            
            
            chooseMoreDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                //            MyCell
                guard let cell = cell as? MyCell else { return }
                if index == 3 {
                    cell.logoImageView.image = UIImage(named: "logo_2")
                }else if index == 2{
                    cell.logoImageView.image = UIImage(named: "logo_1")
                }else{
                    cell.logoImageView.image = UIImage(named: "logo_\(index % 10)")
                }
            }
        }else{
            
            chooseMoreDropDown.dataSource = ["Chi tiết", "Xóa"]
            
            
            chooseMoreDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                //            MyCell
                guard let cell = cell as? MyCell else { return }
                if index == 1{
                    cell.logoImageView.image = UIImage(named: "logo_2")
                }else {
                    cell.logoImageView.image = UIImage(named: "logo_0")
                }
            }
        }
        self.chooseMoreDropDown.show()
        
        
        chooseMoreDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            if model.status == 0 {
                switch index {
                case 0:
                    let vc = CameraDetailController()
                    vc.delegate = self
                    vc.item = model
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case 1:
                    self.editVC(model)
                    break
                case 2:
                    self.waitingCamera(model)
                    break
                case 3:
                    self.remove(model)
                    break
                default:
                    break
                }
            }else{
                switch index {
                case 0:
                    let vc = CameraDetailController()
                    vc.delegate = self
                    vc.item = model
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case 1:
                    self.remove(model)
                    break
                default:
                    break
                }
            }
        }
        
    }
    
    func waitingCamera(_ model : CameraItemModel) {
        self.alert(message: NSLocalizedString("Xác nhận đăng ký camera?", comment: "Xác nhận đăng ký camera?"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .destructive, handler: { [weak self] (action) in
                self?.waitingRegistration(id: model.id ?? 0)
            })
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Yes"), style: .cancel, handler: { (action) in
            })
        }
    }
    
    func waitingRegistration(id : Int) {

        CameraService.shared.register(id : id , completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                //print(value.description)
                ConstantMK.parseJson(dict: value, handler: {success, msg, code in
                    if success {
                        self?.alert(title: "Thông báo", message: "Thành công")
                    } else {
                        self?.showErrorResponse(code: code)
                    }
                })
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }

        })
    }
    
    func editVC(_ item : CameraItemModel) {
        let vc = AddCameraViewController()
        vc.isAddCamera = false
        vc.model = ParamAddCamera(sn: item.sn ?? "", password: item.password ?? "" , phone: item.phone ?? "", installationDate: item.installationDate ?? "")
        vc.id = item.id
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func removeCamera(id : Int) {
        
        CameraService.shared.delete(id : id , completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                //print(value.description)
                ConstantMK.parseJson(dict: value, handler: {success, msg, code in
                    if success {
                        self?.back()
                    } else {
                        self?.showErrorResponse(code: code)
                    }
                })
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }
            
        })
    }
    func remove(_ model : CameraItemModel) {
        self.alert(message: NSLocalizedString("Are you sure to remove this Camera?", comment: "Are you sure to remove this Camera?"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .destructive, handler: { [weak self] (action) in
                self?.removeCamera(id: model.id ?? 0)
            })
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Yes"), style: .cancel, handler: { (action) in
            })
        }
    }
    
    


}




extension CameraListController :  UICollectionViewDelegate , UICollectionViewDataSource  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
        return searching ? searchCamera.count: cameras.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DriverCollectionViewCell", for: indexPath) as! DriverCollectionViewCell
        let item = searching ? searchCamera[indexPath.row] : cameras[indexPath.row]
        cell.delegate = self
        cell.configCamera(item: item)
        
        return cell
    }
   
    
}


extension CameraListController : DriverCollectionViewCellDelegate {
    func tapMoreCamera(view: UIView, item: CameraItemModel) {
        self.customizeDropDown(view: view , model : item)
    }
    
    func tapMoreVehicle(view: UIView, item: VehicleItemModel) {
        
    }
    
    func tapAdd() {
        let vc = AddCameraViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func  tapMoreDriver(view : UIView , item : DriverItemModel) {
     
    }
}

extension CameraListController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2
        let height = width / 2;
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

extension CameraListController :  AddVehicleControllerDelegate {
    func reloadData() {
        self.getListCamera()
    }
}


extension CameraListController  {
    func alert(_ model : CameraItemModel) {
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
         alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
            self.remove(model)
         }))
        
         alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
         self.present(alert, animated: true, completion: nil)
    }

    func back() {
        let alert = UIAlertController(title: nil, message: "Success", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
}


private extension CameraListController{
    func setBorderView(_ view :UIView){
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
        view.backgroundColor = UIColor.white
        view.layer.masksToBounds = true
    }
}

