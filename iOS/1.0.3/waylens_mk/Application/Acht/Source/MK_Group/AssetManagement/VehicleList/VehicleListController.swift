//
//  VehicleListController.swift
//  Acht
//
//  Created by TranHoangThanh on 1/12/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import DropDown

protocol VehicleListControllerDelegate : AnyObject {
    func showView(model : VehicleItemModel)
}


private extension VehicleListController {
    func add(viewController : UIViewController , asChildViewController childController : UIViewController , direction : UIView.AnimationOptions) -> Void {
        viewController.addChild(childController)
        UIView.transition(with: viewController.view, duration: 0.3, options: direction, animations: {
            [viewController] in
            viewController.view.addSubview(childController.view)
        }, completion: nil)
        childController.view.frame = viewController.view.bounds
        childController.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        childController.didMove(toParent: viewController)
    }
    
    func remove(asChildViewController childController: UIViewController) -> Void {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
    
    func setBorderView(_ view :UIView){
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
        view.backgroundColor = UIColor.white
        view.layer.masksToBounds = true
    }
}

class VehicleListController: BaseViewController, UITextFieldDelegate {


    @IBOutlet weak var searchContent: UIView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnClearText: UIButton!
  
    var searching = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate : VehicleListControllerDelegate?
    
    var listVehicle = [VehicleItemModel]()
    var searchVehicle = [VehicleItemModel]()
    
    init() {
        super.init(nibName: "VehicleListController", bundle: nil)
        title = "Xe"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // view.backgroundColor = .red
        //title = "Danh sách phương tiện"
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "DriverCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DriverCollectionViewCell")
        getListVehicle()
    
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
            searchVehicle.removeAll()
            btnClearText.isHidden = true
            self.collectionView.reloadData()
        } else {
            searching = true
            btnClearText.isHidden = false
            searchVehicle = listVehicle.filter({ val in
                if let name = val.plateNo {
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
        searchVehicle.removeAll()
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
       
    
    let chooseMoreDropDown = DropDown()
    
    func customizeDropDown(view : UIView , model : VehicleItemModel) {
        
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
        chooseMoreDropDown.width = view.frame.width
        let height = (chooseMoreDropDown.anchorView?.plainView.bounds.height)! - 60
//        print("hooseMoreDropDown.anchorView?.plainView.bounds.height", height)
        chooseMoreDropDown.bottomOffset = CGPoint(x: 0, y:height)
        chooseMoreDropDown.topOffset = CGPoint(x: 0, y: -(height))
        chooseMoreDropDown.direction = .any
        chooseMoreDropDown.dataSource = ["Chỉnh Sửa", "Xóa","Phân công tài xế",model.cameraSn != nil ? "Đổi camera" : "Thêm camera"]

        chooseMoreDropDown.cellNib = UINib(nibName: "MyCell", bundle: nil)
        
        chooseMoreDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
//            MyCell
            guard let cell = cell as? MyCell else { return }
//
//            // Setup your custom UI components
            cell.logoImageView.image = UIImage(named: "logo_\((index + 1) % 10)")
        }
        self.chooseMoreDropDown.show()
        
        
        chooseMoreDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            switch index {
            case 0:
                self.editVC(model)
                break
            case 1:
                self.remove(model)
                break
            case 2 :
                self.showViewDriver(model: model)
                break
            case 3 :
                self.showView(model: model)
                break
            default:
                break
            }
        }

    }
    
    func showView(model : VehicleItemModel) {
        let controller = EditCameraController(nibName: "EditCameraController", bundle: nil)
        controller.model = model
        controller.delegate = self
        self.add(viewController: self, asChildViewController: controller, direction: .allowAnimatedContent)
    }
    
    func showViewDriver(model : VehicleItemModel) {
        let controller = EditDriverController(nibName: "EditDriverController", bundle: nil)
        controller.model = model
        controller.delegate = self
        self.add(viewController: self, asChildViewController: controller, direction: .allowAnimatedContent)
    }
    
    func  removeVehicle(id : Int) {
        
        VehicleService.shared.delete(id : id , completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                print(value.description)
                if let data = value["data"] as? Bool {
                    if data {
                        self?.didPullRefresh()
                    }
                }
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }
        })
    }
    
    func editVC(_ model : VehicleItemModel){
        let vc = AddVehicleController()
        vc.isAddVehicle = false
        if let brand = model.brand , let plateNo = model.plateNo , let type = model.type , let vehicleNo = model.vehicleNo {
            vc.model = ParamVehicle(brand: brand, plateNo: plateNo, type: type, vehicleNo: vehicleNo)
            vc.id = model.id
            vc.isAddVehicle = false
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
      
    }
    
    
    func remove(_ model : VehicleItemModel) {
        self.alert(message: NSLocalizedString("Are you sure to remove this Vehicle?", comment: "Are you sure to remove this Vehicle?"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .destructive, handler: { [weak self] (action) in
                if let id = model.id {
                    self?.removeVehicle(id: id)
                }
              
                
            })
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Yes"), style: .cancel, handler: { (action) in
            })
        }
    }
    
    
    @objc func didPullRefresh() {
        print("didPullRefresh")
        index = 1
        getListVehicle()
        self.collectionView.mj_header?.endRefreshing()
    }
    
    var index = 1
    @objc func didLoadMore() {
        print("didLoadMore")
        index += 1
        getMoreVehicle(current: index)
        self.collectionView.mj_footer?.endRefreshing()
    
        
    }
    
   
    func getListVehicle() {
        
        let parameters: [String : Any] = [
                      "current" : 1,
                      "size" : 10,
                  ]
        
        VehicleService.shared.vehicle_by_page(param: parameters, completion: { (result) in
        
            switch result {
                
            case .success(let value):
                if let data = value["data"] as? JSON {
                    if let vehicleInfos = data["records"] as? [JSON] {
                        if let infoData = try? JSONSerialization.data(withJSONObject: vehicleInfos, options: []){
                            do {
                                var items = try JSONDecoder().decode([VehicleItemModel].self, from: infoData)
                                let new = VehicleItemModel()
                                items.insert(new, at: 0)
                                self.listVehicle.removeAll()
                                self.listVehicle = items
                                ConstantMK.vehicleItemList = self.listVehicle
                                self.collectionView.reloadData()
                            } catch let err {
                                print("err get VehicleProfile",err)
                            }
                        }
                    }
                }
               
            case .failure(let err):
            
              HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }

        })
        
    }
    
    func getMoreVehicle(current : Int) {
        
        let parameters: [String : Any] = [
                      "current" : current,
                      "size" : 10,
                  ]
        
        VehicleService.shared.vehicle_by_page(param: parameters, completion: { (result) in
        
            switch result {
                
            case .success(let value):
                if let data = value["data"] as? JSON {
                    if let vehicleInfos = data["records"] as? [JSON] {
                        if let infoData = try? JSONSerialization.data(withJSONObject: vehicleInfos, options: []){
                            do {
                                let itemsMore = try JSONDecoder().decode([VehicleItemModel].self, from: infoData)
                                
                                if !itemsMore.isEmpty {
                                    self.listVehicle.append(contentsOf: itemsMore)
                                    ConstantMK.vehicleItemList = self.listVehicle
                                    self.collectionView.reloadData()
                                }
                            
                            } catch let err {
                                print("err get VehicleProfile",err)
                            }
                        }
                    }
                }
               
            case .failure(let err):
            
              HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }

        })
        
    }
    
    

 


}


extension VehicleListController : UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searching ? searchVehicle.count:  listVehicle.count
    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = searching ? searchVehicle[indexPath.row] :  listVehicle[indexPath.row]
//        let vc = VehicleDetailController()
//        vc.delegate = self
//        vc.model = item
//        self.navigationController?.pushViewController(vc, animated: true)
//
//    }
//
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell  {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DriverCollectionViewCell", for: indexPath) as! DriverCollectionViewCell
        
        let item =  searching ? searchVehicle[indexPath.row] : listVehicle[indexPath.row]
        cell.delegate = self
        cell.config(item: item)
        return cell
    }
    

    
}


extension  VehicleListController : DriverCollectionViewCellDelegate {
    func tapMoreCamera(view: UIView, item: CameraItemModel) {
        
    }
    
    func tapMoreVehicle(view: UIView, item: VehicleItemModel) {
        self.customizeDropDown(view: view , model : item)
    }
    
    func tapAdd() {
        let vc = AddVehicleController()
        vc.delegate = self
        vc.isAddVehicle = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
  
    func  tapMoreDriver(view : UIView , item : DriverItemModel) {
        
    }
}
extension VehicleListController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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

extension VehicleListController : AddVehicleControllerDelegate {
    func reloadData() {
        self.getListVehicle() 
    }
}

extension VehicleListController {
    func alert(_ model : VehicleItemModel) {
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: { action in
            self.editVC(model)
        }))
                        
        alert.addAction(UIAlertAction(title: "Edit Camera", style: UIAlertAction.Style.default, handler: { action in
            self.delegate?.showView(model : model)
        }))
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

