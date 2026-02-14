//
//  LocationPickerViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class LocationPickerViewController: UINavigationController {

    // MARK: - Methods
    init(contentViewController: LocationPickerContentViewController) {
        super.init(rootViewController: contentViewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @available(*, unavailable, message: "Loading nibless view controllers from a nib is unsupported in favor of initializer dependency injection.")
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable, message: "Loading nibless view controllers from a nib is unsupported in favor of initializer dependency injection.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("Loading nibless view controllers from a nib is unsupported in favor of initializer dependency injection.")
    }
}

