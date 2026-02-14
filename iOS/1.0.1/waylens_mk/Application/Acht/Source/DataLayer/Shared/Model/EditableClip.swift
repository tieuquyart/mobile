//
//  EditableClip.swift
//  Acht
//
//  Created by Chester Shen on 3/15/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

class EditableClip: BasicClip {
    var originalClip: HNClip
    var clipID: Int64 { return originalClip.clipID }
    var startDate: Date { return originalClip.startDate.addingTimeInterval(offset) }
    var videoType: HNVideoType { return originalClip.videoType }
    var offset: TimeInterval
    var duration: TimeInterval
    var facedown: Bool { return originalClip.facedown }
    var needDewarp: Bool
    var location: WLLocation? { return originalClip.location }
    
    init(_ clip: HNClip, offset: TimeInterval=0, duration: TimeInterval=0) {
        self.offset = offset
        self.duration = duration > 0 ? duration : clip.duration
        originalClip = clip
        self.needDewarp = clip.needDewarp
    }
}
