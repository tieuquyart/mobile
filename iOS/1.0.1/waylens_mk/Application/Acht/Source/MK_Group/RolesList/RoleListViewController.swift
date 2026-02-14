//
//  RoleListViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 1/28/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

protocol RoleListViewControllerDelegate : AnyObject {
    func pass(value : String)
}

class RoleListViewController: UIViewController {

    var items : [RoleItemModel] = []
    var roleName : [String] = []
    var userId : Int = 0
    var indexPathClicked : Int?
    var roleSelected : Int?
    var role : String = ""
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate : RoleListViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
    
          self.tableView.dataSource = self
          self.tableView.delegate = self
          self.tableView.register(UINib(nibName: "RoleTableViewCell", bundle: nil), forCellReuseIdentifier: "RoleTableViewCell")
          getRole()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func cancelBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func okBtn(_ sender: Any) {
        setRoleIndex()
    }
    
    func showAlert() {
        let alert = UIAlertController(title: nil, message: "Success", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {  [weak self] action in
            self?.navigationController?.popViewController(animated: false)
            self?.delegate?.pass(value: self!.role)
        }))
        present(alert, animated: true, completion: nil)
    }
    func setRoleIndex() {
       
        let param = ParamUserRole(selectedRoles: [roleSelected!], userId: userId)
        
        RolesService.shared.updateUserRole(param: param, completion: {  [weak self] (result) in
            switch result {
            case .success(let value):
                if let success = value["success"] as? Bool {
                    if success {
                        self?.showAlert()
                    } else {
                        if let message = value["message"] as? String {
                            self?.showAlert(title: "Alert", message: message)
                        }
                    }
                   
                }
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }
        })
    }
    func getRole() {
        RolesService.shared.getAll(completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                print(value.description)
                if let data = value["data"] as? [JSON] {
                    if let infoData = try? JSONSerialization.data(withJSONObject: data, options: []){
                        do {
                            let items = try JSONDecoder().decode([RoleItemModel].self, from: infoData)
                            self?.items = items
                            self?.tableView.reloadData()
                        } catch let err {
                            print("err get VehicleProfile",err)
                        }
                    }
                }
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self?.navigationController)
            }
        })
    }


}

extension RoleListViewController : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoleTableViewCell", for: indexPath) as! RoleTableViewCell
        let item = items[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item = items[indexPath.row]
        item.isCheck = true
        self.roleSelected = item.id
        self.role = item.roleName
        items[indexPath.row] = item
        if let indexPathOld = self.indexPathClicked  {
            items[indexPathOld].isCheck  = false
        }
        indexPathClicked = indexPath.row
        self.tableView.reloadData()
       
    }

}
