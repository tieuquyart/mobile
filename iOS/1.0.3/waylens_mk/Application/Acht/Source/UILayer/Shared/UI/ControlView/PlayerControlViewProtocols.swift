//
//  PlayerControlViewProtocols.swift
//  Acht
//
//  Created by forkon on 2018/9/27.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit

protocol HNPlayerControlProtocol: AnyObject {
    /// declare the property as weak in the conforming type
    var player: PlayerPanel? {set get}
    
    func updateUI()
    func showControlView()
    func hideControlView()
    func hideDMSFaceButton(hide: Bool)

    func showResolutionButton(_ show: Bool, streams : Int)
    func showViewModeButton(_ show: Bool)
}

protocol RecordingStateToggleable: AnyObject {
    var recordingSwitch: UISwitch! {set get}
}

protocol TransferRateDisplayable: AnyObject {
    var transferRateLabel: UILabel! {set get}
}

protocol Highlightable: AnyObject {
    var highlightButton: UIButton! {set get}
    var highlightCard: HighlightCard! {set get}
}

protocol TimeLineViewRequirable: AnyObject {
    func addTimeLineView(_ timeLineView: CameraTimeLineHorizontalView)
    func removeTimeLineView()
}

protocol PlayTimeDisplayable: AnyObject {
    var timeLabel: UILabel! {set get}
}

protocol TimePointInfoDisplayable: AnyObject {
    var timePointInfoHUD: MultilineTextHUD! {set get}
}

protocol PlayerViewModeToggleable: AnyObject {
    var viewModeButton: UIButton! {set get}
}
