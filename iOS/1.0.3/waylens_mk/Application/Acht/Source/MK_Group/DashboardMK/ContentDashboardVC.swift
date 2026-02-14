//
//  ContentDashboardVC.swift
//  Acht
//
//  Created by TranHoangThanh on 8/30/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit

class ContentDashboardVC : UIViewController {
    convenience init(index: Int) {
        self.init(title: "View \(index)", content: "\(index)")
    }

    convenience init(title: String) {
        self.init(title: title, content: title)
    }

    init(title: String, content: String) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = title

        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "BeVietnamPro-Thin", size: 50)
        label.textColor = UIColor(red: 95 / 255, green: 102 / 255, blue: 108 / 255, alpha: 1)
        label.textAlignment = .center
        label.text = content
        label.sizeToFit()

        view.addSubview(label)
       // view.constrainToEdges(label)
        view.backgroundColor = .white
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



