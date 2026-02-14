//
//  WLVideoDefinition.swift
//  WaylensVideoSDK
//
//  Created by forkon on 2020/7/16.
//  Copyright © 2020 Waylens. All rights reserved.
//

import CoreGraphics
import GPUImage

public enum WLVideoRenderMode: Equatable {
    /// Split the screen up and down to present the images in front and back of the camera.
    case split
    /// Focus on a selected view angle.
    case immersive(direction: Direction?)
    case ball
    /// Show original video directly.
    case original

    public static func == (lhs: WLVideoRenderMode, rhs: WLVideoRenderMode) -> Bool {
        switch (lhs, rhs) {
        case (.split, .split):
            return true
        case (.original, .original):
            return true
        case (.immersive(let leftDirection), .immersive(let rightDirection)):
            return leftDirection == rightDirection
        default:
            return false
        }
    }
}

public struct WLVideoDewarpParams: Equatable {
    /// Tell how to render the video.
    public var renderMode: WLVideoRenderMode

    /// Rotate the picture by 180 degrees.
    ///
    /// Ignored if `renderMode` is `WLVideoRenderMode.original`.
    public var rotate180Degrees: Bool

    /// Show timestamp in video.
    ///
    /// Ignored if `renderMode` is `WLVideoRenderMode.original`.
    public var showTimeStamp: Bool

    /// Show GPS info in video.
    ///
    /// Ignored if `renderMode` is `WLVideoRenderMode.original`, or `showTimeStamp` is false.
    public var showGPS: Bool

    public init(
        renderMode: WLVideoRenderMode,
        rotate180Degrees: Bool,
        showTimeStamp: Bool,
        showGPS: Bool
    ) {
        self.renderMode = renderMode
        self.rotate180Degrees = rotate180Degrees
        self.showTimeStamp = showTimeStamp
        self.showGPS = showGPS
    }
}

extension WLVideoDewarpParams: CustomStringConvertible {

    public var description: String {
        return
            """
            WLVideoDewarpParams:
            - Render Mode: \(renderMode)
            - Rotate 180 Degrees: \(rotate180Degrees)
            - Show Time Stamp: \(showTimeStamp)
            - Show GPS: \(showGPS)
            """
    }

}

public class Direction: Equatable {
    var currentScale: CGFloat
    var centerLatitude: CGFloat
    var centerLongitude: CGFloat
    var facedown: Bool
    
    init() {
        currentScale = 1
        centerLatitude = 0
        centerLongitude = 180
        facedown = false
    }

    public static func == (lhs: Direction, rhs: Direction) -> Bool {
        return lhs.currentScale == rhs.currentScale &&
            lhs.centerLatitude == rhs.centerLatitude &&
            lhs.centerLongitude == rhs.centerLongitude &&
            lhs.facedown == rhs.facedown
    }
}
