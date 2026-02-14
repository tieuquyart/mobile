//
//  BaseVC.swift
//  NFCPassportReaderApp
//
//  Created by TranHoangThanh on 4/29/21.
//  Copyright © 2021 Andy Qua. All rights reserved.
//

import UIKit
import Network
import SnapKit
class BaseVC : UIViewController {
    
    
    var uiView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        layout()
        setUI()

      
    }
    
   
    func showProgress(){
        SVProgressHUD.show()
    }
    
    func hideProgress(){
        SVProgressHUD.dismiss()
    }
    
    deinit {
    }
    @objc func setText() {
        setUI() 
    }
    func setUI() {
        
    }
    
    private func layout() {
    }
    
    func setTitleNav(_ title : String) {
    }
    
    
    
    func setupBackground() {
       
    }
    
    
    
    func initHeader(_ text: String) {
        
        
    }
    
    
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushVCNo(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func popVC() {
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Show Alert thông báo cơ bản
    func showAlert (_ errorStr : String) {
        let alert = UIAlertController(title: "", message: errorStr, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        //b3 present
        present(alert, animated: true, completion: nil)
    }
    
    func showErr(_ title : String , message : String , completion : @escaping SUCCESS_CLORUSE) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            completion()
        }))
        //b3 present
        present(alert, animated: true, completion: nil)
    }
    
    func backVC(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func gotoSetting(){
        
    }
    
}
