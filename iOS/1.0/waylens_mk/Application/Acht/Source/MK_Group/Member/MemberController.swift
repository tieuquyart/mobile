//
//  MemberController.swift
//  Acht
//
//  Created by TranHoangThanh on 2/17/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

struct MemberInfo {
    let title : String
    var value : String
    var isShow : Bool = true
}
class MemberController: BaseViewController {
    
    var  member: FleetMember!
    
    @IBOutlet weak var tableView: UITableView!
    
    var items : [MemberInfo] = []
    var editMode = false {
        didSet {
            if editButton.title == "Finish" && isChange {
                updateProfile()
            }
          
        }
    }
    
    var editButton: UIBarButtonItem!
    var indexValue : Int = 0
    var isChange : Bool = false
    
    @IBOutlet weak var deleteButton: UIButton!
    func updateProfile() {
        api.update_Users(id: member.get_id(), realName: member.getName(), userName: member.get_userName(), completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: {success, msg in
                    if success {
                        self?.showAlertEdit()
                    } else {
                        self?.showErrorResponse(msg: msg)
                    }
                })
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Update", comment: "Failed to Update"), to: self?.navigationController)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = member.name
        items = [
            MemberInfo(title: "User Name", value: member.name),
            MemberInfo(title: "Name", value: member.realName),
            MemberInfo(title: "Role", value: member.get_role())
        ]
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CellMember", bundle: nil), forCellReuseIdentifier: "CellMember")
        tableView.tableFooterView = UIView()
        self.editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        navigationItem.rightBarButtonItem = self.editButton
        deleteButton.layer.cornerRadius = 5
    }
    
    @objc func editTapped() {
        self.editMode.toggle()
        if editMode {
            for i in 0..<items.count {
                items[i].isShow = false
            }
            self.tableView.reloadData()
        } else {
            for i in 0..<items.count {
                items[i].isShow = true
            }
            self.tableView.reloadData()
        }
        self.editButton.title = self.editMode ? "Finish" : "Edit"
        
    }
    
    let api : UserAPI = UserService()
    
    func removeMember() {
        self.alert(message: NSLocalizedString("Are you sure to remove this member?", comment: "Are you sure to remove this member?"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .destructive, handler: { [weak self] (action) in
                self?.deleteUser()
            })
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Yes"), style: .cancel, handler: { (action) in
            })
        }
    }
    
    
    func showAlertEdit() {
        let alert = UIAlertController(title: nil, message: "Edit Success", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {  [weak self] action in
            self?.navigationController?.popViewController(animated: false)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertDelete() {
        let alert = UIAlertController(title: nil, message: "Delete Success", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {  [weak self] action in
            self?.navigationController?.popViewController(animated: false)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    func deleteUser() {
        api.remove_Users(id: member.get_id(), completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: {success, msg in
                    if success {
                        self?.showAlertDelete()
                    } else {
                        self?.showErrorResponse(msg: msg)
                    }
                })
            case .failure(let error):
                HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Failed to Remove", comment: "Failed to Remove"), to: self?.navigationController)
            }
        })
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        removeMember()
    }
    
//    func showAlert() {
//        let alert = UIAlertController(title: nil, message: "Success", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {  [weak self] action in
//            self?.navigationController?.popViewController(animated: false)
//        }))
//        present(alert, animated: true, completion: nil)
//    }
    
    
}

extension MemberController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellMember", for: indexPath) as! CellMember
        let item = items[indexPath.row]
        cell.config(value: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if editMode {
            let item = items[indexPath.row]
            if item.title == "Role" {
                let viewController  = RoleListViewController()
                viewController.userId = member.get_id()
                viewController.roleName = member.roleNames
                indexValue = indexPath.row
                viewController.delegate = self
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                let vc = MemberDetailInfoController()
                vc.infoText = items[indexPath.row].value
                indexValue = indexPath.row
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
}

extension MemberController : RoleListViewControllerDelegate {
    func pass(value : String) {
        var item = items[indexValue]
        item.value = value
        items[indexValue] = item
        self.tableView.reloadData()
    }
}

extension MemberController : PassDataMemberDelegate {
    func passData(_ value: String) {
        var item = items[indexValue]
        if (item.value != value) {
            item.value = value
            items[indexValue] = item
            if indexValue == 1 {
                member.realName = value
            } else if indexValue == 0 {
                member.name = value
            }
            self.tableView.reloadData()
            self.isChange = true
        }
      
    }
}
