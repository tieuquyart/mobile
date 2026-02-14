//
//  MyFleetUserProfileViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class MyFleetUserProfileViewController: BaseViewController {
    private let userProfile: UserProfile
    private let userInterface: MyFleetUserProfileUserInterfaceView

    init(
        userProfile:  UserProfile,
        userInterface: MyFleetUserProfileUserInterfaceView
    ) {
        self.userProfile = userProfile
        self.userInterface = userInterface
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.navigationController?.navigationItem.backBarButtonItem?.tintColor = .black
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        userInterface.render(userProfile: userProfile)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.tintColor = .black
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: animated)
        
        self.hideNavigationBar(animated: animated)
        
        title = "Thông tin tài khoản".localizeMk()
        
        self.showNavigationBar(animated: animated)
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.color(fromHex: ConstantMK.bg_main_color)
    }
}

extension MyFleetUserProfileViewController: MyFleetUserProfileIxResponder {

    func logout() {
        presentLogOutConfirmation()
    }

    func changePassword() {
        //show change passpord
        AppViewControllerManager.showChangePassword()
    }
    
    func alertWithTF(title: String, message: String) {
        //Step : 1
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        //Step : 2
        alert.addAction (UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0]
            let textField2 = alert.textFields![1]
            if textField.text != "" {
                //Read textfield data
                print(textField.text!)
                print("TF 1 : \(textField.text!)")
            } else {
                self.showAlert(title: "Error", message: "Can nhap du thong tin")
                print("TF 1 is Empty...")
            }
            if textField2.text != "" {
                //Read textfield data
                print(textField2.text!)
                print("TF 2 : \(textField2.text!)")
            } else {
                self.showAlert(title: "Error", message: "Can nhap du thong tin")
                print("TF 2 is Empty...")
            }
        })

        //Step : 3
        //For first TF
        alert.addTextField { (textField) in
            textField.placeholder = "Old Password"
            textField.textColor = .red
        }
        //For second TF
        alert.addTextField { (textField) in
            textField.placeholder = "New Password"
            textField.textColor = .blue
        }

        //Cancel action
      alert.addAction(UIAlertAction(title: "Cancel", style: .default) { (alertAction) in })
       self.present(alert, animated:true, completion: nil)

    }
}

extension MyFleetUserProfileViewController: ObserverForMyFleetUserProfileEventResponder {

}
