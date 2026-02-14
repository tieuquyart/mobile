//
//  CardFlowViewCardEventHandler.swift
//  Acht
//
//  Created by forkon on 2019/10/15.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

public class CardFlowViewCardEventHandler<ItemType> {

    public typealias SelectBlock = ((ItemType) -> Void)
    
    public var selectBlock: SelectBlock? = nil

}
