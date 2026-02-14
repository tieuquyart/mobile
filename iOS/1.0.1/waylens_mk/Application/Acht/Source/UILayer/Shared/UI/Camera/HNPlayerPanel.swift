//
//  HNPlayerPanel.swift
//  Acht
//
//  Created by Chester Shen on 6/15/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensVideoSDK

@objc enum HNViewMode: Int {
    case frontBack = 0
    case panorama = 1
    case raw = 2
    
    var displayNameForExport: String {
        switch self {
        case .frontBack:
            return NSLocalizedString("Split Screen", comment: "Split Screen")
        case .panorama:
            return NSLocalizedString("Full Screen", comment: "Full Screen")
        case .raw:
            return NSLocalizedString("Original", comment: "Original")
        }
    }
}

extension HNViewMode {
    var renderMode: WLVideoRenderMode {
        switch self {
        case .frontBack:
            return .split
        case .panorama:
            return .immersive(direction: nil)
        case .raw:
            return .original
        }
    }
}

enum HNPlaySource {
    case none
    case localLive
    case remoteLive
    case localPlayback
    case remotePlayback
    case offline
    
    var isLive: Bool {
        return self == .localLive || self == .remoteLive
    }
    
    var isPlayback: Bool {
        return self == .localPlayback || self == .remotePlayback
    }
}

enum HNPlayState {
    case unloaded
    case stopped
    case playing
    case paused
    case buffering
    case seeking
    case completed
    case error
}

public enum HNVideoResolution: Int, CustomStringConvertible {
    case hd
    case sd
    case spliced
    case frontHD
    case incabinHD
    case dms

    case stream0
    case stream1
    case stream2
    case stream3

    case unknown

    public var description: String {
        switch self {
        case .sd:
            return "SD"
        case .hd:
            return "HD"
        case .frontHD:
            return NSLocalizedString("Road", comment: "Road")
        case .incabinHD:
            return NSLocalizedString("Cabin", comment: "Cabin")
        case .dms:
            return NSLocalizedString("Driver", comment: "Driver")
        case .spliced:
            return NSLocalizedString("Combined", comment: "Combined")

        case .stream0:
            return "Stream0"
        case .stream1:
            return "Stream1"
        case .stream2:
            return "Stream2"
        case .stream3:
            return "Stream3"
        case .unknown:
            return NSLocalizedString("Unknown", comment: "Unknown")
        }
    }

    public var longDescription: String {
        switch self {
        case .sd:
            return "SD"
        case .hd:
            return "HD"
        case .frontHD:
            return NSLocalizedString("Road Facing", comment: "Road Facing")
        case .incabinHD:
            return NSLocalizedString("Cabin Facing", comment: "Cabin Facing")
        case .dms:
            return NSLocalizedString("Driver Facing", comment: "Driver Facing")
        case .spliced:
            return NSLocalizedString("Combined View", comment: "Combined View")

        case .stream0:
            return "Stream0"
        case .stream1:
            return "Stream1"
        case .stream2:
            return "Stream2"
        case .stream3:
            return "Stream3"
        case .unknown:
            return "Unknown"
        }
    }

    public static func parse(_ streamDescrs: [String]) -> [HNVideoResolution] {
        var streamResolutions: [HNVideoResolution] = []

        for (i, descr) in streamDescrs.enumerated() {
            if descr.hasPrefix("SD") || descr.hasPrefix("STREAMING") {
                streamResolutions.append(.spliced)
                continue
            } else if descr.hasPrefix("DMS") {
                streamResolutions.append(.dms)
                continue
            } else if descr.hasPrefix("FRONT_HD") {
                streamResolutions.append(.frontHD)
                continue
            } else if descr.hasPrefix("INCABIN_HD") {
                streamResolutions.append(.incabinHD)
                continue
            } else {
                if streamDescrs.count <= 2 {
                    switch i {
                    case 0:
                        streamResolutions.append(.hd)
                    default:
                        streamResolutions.append(.sd)
                    }
                } else {
                    switch i {
                    case 0:
                        streamResolutions.append(.stream0)
                    case 1:
                        streamResolutions.append(.stream1)
                    case 2:
                        streamResolutions.append(.stream2)
                    case 3:
                        streamResolutions.append(.stream3)
                    default:
                        streamResolutions.append(.stream3)
                    }
                }
            }
        }

        return streamResolutions
    }

    /*
    public init?(stringValue: String) {
        if stringValue.hasPrefix("SD") || stringValue.hasPrefix("STREAMING") {
            self = .spliced
        } else if stringValue.hasPrefix("DMS") {
            self = .dms
        } else if stringValue.hasPrefix("FRONT_HD") {
            self = .frontHD
        } else if stringValue.hasPrefix("INCABIN_HD") {
            self = .incabinHD
        } else {
            switch stringValue {
            case "stream0":
                self = .stream0
            case "stream1":
                self = .stream1
            case "stream2":
                self = .stream2
            case "stream3":
                self = .stream3
            default:
                return nil
            }
        }
    }
 */
}

protocol HNPlayerPanelDelegate : NSObjectProtocol {
    func onFullScreen(_ full : Bool)
    func onPlay(_ play: Bool)
    func playerDidChange(_ state: HNPlayState)
    func playerDidChange(source: HNPlaySource)
    func onSnapshot()
    func onHighlight()
    func onHighlightCard()
    func showControls(show:Bool, duration: TimeInterval)
    func onViewMode(_ viewMode: HNViewMode)
    func onResolution(_ resolution: HNVideoResolution, index: Int)
    func onSeekingBegan()
    func onSeeking()
    func onSeekingEnded()
    func onDMSFace()

    #if !FLEET
    func onMicButtonTouchStateChange(_ micButton: UIButton)
    #endif
}

extension HNPlayerPanelDelegate {
    func onPlay(_ play: Bool){
        // leaving this empty
    }
    
    func playerDidChange(_ state: HNPlayState) {
        // leaving this empty
    }
    
    func playerDidChange(source: HNPlaySource) {
        
    }
    
    func onSnapshot() {
        
    }
    
    func onHighlight() {
        
    }
    
    func onHighlightCard() {}
    
    func showControls(show:Bool, duration: TimeInterval) {
        
    }
    
    func onViewMode(_ viewMode: HNViewMode) {}
    func onFullScreen(_ full: Bool) {}
    func onResolution(_ resolution: HNVideoResolution, index: Int) {}
    func onSeekingBegan() {}
    func onSeeking() {}
    func onSeekingEnded() {}
    func onDMSFace() {}
    func onMicButtonTouchStateChange(_ micButton: UIButton) {}
}
