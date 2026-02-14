//
//  ExcelViewController.swift
//  demoDownloadFile
//
//  Created by TranHoangThanh on 9/5/22.
//

import UIKit
import WebKit

class ExcelViewController: UIViewController {

    var link : URL!
    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
     //   let link = URL(string: str)!
        let request = URLRequest(url: link)
        webView.load(request)

        // Do any additional setup after loading the view.
    }



}
