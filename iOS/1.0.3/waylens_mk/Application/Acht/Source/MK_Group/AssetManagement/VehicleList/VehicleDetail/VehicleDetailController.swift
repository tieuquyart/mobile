//
//  VehicleDetailController.swift
//  Acht
//
//  Created by TranHoangThanh on 1/18/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class VehicleDetailController: BaseViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var plateNumberLabel: UILabel!
    @IBOutlet weak var employeeLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var cameraSnLabel: UILabel!
    @IBOutlet weak var vehicleBrandLabel: UILabel!
    @IBOutlet weak var vehicleTypeLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var outView : UIView!
    
    var model : VehicleItemModel!
    weak var delegate : AddVehicleControllerDelegate?
    
    var isEdit = true
    
    @IBOutlet weak var viewBtn: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        self.editBtn.backgroundColor = UIColor.color(fromHex: ConstantMK.blueButton )
        self.viewBtn.isHidden = true
        
        deleteBtn.setTitle(NSLocalizedString("Delete", comment: "Delete"), for: .normal)
        editBtn.setTitle(NSLocalizedString("Edit", comment: "Edit"), for: .normal)
        ConstantMK.borderButton([editBtn,deleteBtn])
        
        setBorderView()
        
        applyTheme()
    }
    
    func setBorderView() {
        outView.layer.cornerRadius = 8
//        outView.layer.masksToBounds = true
        outView.addShadow(offset: CGSize(width: 3, height: 4))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initHeader(text: NSLocalizedString("Thông tin xe", comment: "Thông tin xe"), leftButton: false)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBack))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
        
        applyTheme()
    }
    
    override func applyTheme() {
        super.applyTheme()
        self.view.backgroundColor = UIColor.white
    }
    
    @objc func leftBack(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func configUI() {
        idLabel.text = "\(model.id ?? 0)"
        plateNumberLabel.text = model.plateNo
        titleLabel.text = model.plateNo
        employeeLabel.text = model.employeeId
        driverLabel.text = model.driverName
        cameraSnLabel.text = model.cameraSn
        vehicleBrandLabel.text = model.brand
        vehicleTypeLabel.text = model.type
        capacityLabel.text = model.capacity
    }
    
    @IBAction func assignDriverButton(_ sender: Any) {
        self.showViewDriver(model: model)
    }
    @IBAction func editButton(_ sender: Any) {
        self.editVC(self.model)
        
    }
    @IBAction func editCamera(_ sender: Any) {
        self.showView(model: model)
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        self.remove(model)
    }
    
    func showViewDriver(model : VehicleItemModel) {
        let controller = EditDriverController(nibName: "EditDriverController", bundle: nil)
        controller.model = model
        controller.delegate = self
        self.add(viewController: self, asChildViewController: controller, direction: .allowAnimatedContent)
    }
    
    func showView(model : VehicleItemModel) {
        let controller = EditCameraController(nibName: "EditCameraController", bundle: nil)
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
                        self?.reloadData()
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
    
    
}

extension VehicleDetailController : AddVehicleControllerDelegate {
    func reloadData() {
        self.delegate?.reloadData()
        self.navigationController?.popViewController(animated: false)
    }
}



private extension VehicleDetailController {
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
}
