//
//  AddNewView.swift
//  Fleet
//
//  Created by forkon on 2019/12/11.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class AddNewView: UITableViewCell {
    typealias TapHandler = () -> ()

    private var tapHandler: TapHandler

    var title: String? {
        set {
            textLabel?.text = newValue
        }
        get {
            return textLabel?.text
        }
    }

    init(tapHandler: @escaping TapHandler) {
        self.tapHandler = tapHandler
        super.init(style: .default, reuseIdentifier: nil)

        frame.size = CGSize(width: 300.0, height: 60.0)
        imageView?.tintColor = UIColor.semanticColor(.tint(.primary))
        imageView?.image = #imageLiteral(resourceName: "icon_settings_add")
        textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        backgroundColor = UIColor.white

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private

private extension AddNewView {

    @objc func tapAction() {
        tapHandler()
    }

}
