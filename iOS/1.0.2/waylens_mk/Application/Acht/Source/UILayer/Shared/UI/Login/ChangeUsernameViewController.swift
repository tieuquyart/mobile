//
//  ChangeUsernameViewController.swift
//  Acht
//
//  Created by Chester Shen on 11/2/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

class ChangeUsernameViewController: BaseTableViewController, UITextFieldDelegate {
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var usernameTextfield: HNInputField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var username:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.saveButton
        setupInputField(usernameTextfield)
        usernameTextfield.delegate = self
        usernameTextfield.addTarget(self, action: #selector(inputDidChange(textField:)), for: .editingChanged)
        saveButton.isEnabled = false
        title = NSLocalizedString("Name", comment: "Name")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextfield.text = username
        usernameTextfield.becomeFirstResponder()
    }
    
    @IBAction func onSave(_ sender: Any) {
        guard let name = usernameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        HNMessage.show(message: NSLocalizedString("Saving...", comment: "Saving..."))
        WaylensClientS.shared.updateProfile(name: name) { [weak self] (result) in
            if result.isSuccess {
                HNMessage.dismiss()
                self?.navigationController?.popViewController(animated: true)
            } else {
                HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Fail to save name", comment: "Fail to save name"))
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onSave(textField)
        return true
    }
    
    @objc func inputDidChange(textField: HNInputField) {
        saveButton.isEnabled = textField.text != username
    }
}


