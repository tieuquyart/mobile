//
//  MemberDetailInfoController.swift
//  Acht
//
//  Created by TranHoangThanh on 2/17/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

protocol PassDataMemberDelegate : AnyObject {
    func passData(_ value : String)
}
class MemberDetailInfoController: UIViewController {

    @IBOutlet weak var infoTextField: UITextField!
    var infoText : String!
    var doneButton: UIBarButtonItem!
    weak var delegate : PassDataMemberDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        infoTextField.text = infoText
        
        self.doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        
        navigationItem.rightBarButtonItem = self.doneButton
      
    }
    
    @objc func doneTapped() {
        let textNew = infoTextField.text
        if textNew != infoText {
            self.delegate?.passData(textNew ?? "")
        } else {
            self.delegate?.passData(infoText)
        }
        self.navigationController?.popViewController(animated: true)
           
    }
    



}
