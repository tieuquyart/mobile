//
//  RecordConfigIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol RecordConfigIxResponder: class {
    func select(recordConfig: String, bitrateFactor: Int, forceCodec: Int)
}
