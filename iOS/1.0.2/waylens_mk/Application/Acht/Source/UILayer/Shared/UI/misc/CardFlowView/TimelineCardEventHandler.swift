//
//  TimelineCardEventHandler.swift
//  Acht
//
//  Created by forkon on 2019/10/15.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

public class CardFlowViewCardEventHandler: NSObject {

    public typealias SelectBlock = ((TimelineCardItem) -> Void)
    
    public var selectBlock: SelectBlock? = nil

}
