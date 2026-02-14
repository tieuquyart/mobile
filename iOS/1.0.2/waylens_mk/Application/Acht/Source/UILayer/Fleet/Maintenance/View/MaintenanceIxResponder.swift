//
//  MaintenanceIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol MaintenanceIxResponder: class {
    func navigateTo(viewController: UIViewController.Type)
    func logout()
    func login()
}
