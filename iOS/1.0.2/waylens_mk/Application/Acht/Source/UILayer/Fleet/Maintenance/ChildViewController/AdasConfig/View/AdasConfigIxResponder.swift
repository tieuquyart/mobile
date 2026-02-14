//
//  AdasConfigIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol AdasConfigIxResponder: AnyObject {
    func configAdas(value: String?, for key: AnyKeyPath)
}
