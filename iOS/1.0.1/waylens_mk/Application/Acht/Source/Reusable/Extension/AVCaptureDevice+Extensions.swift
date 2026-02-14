//
//  AVCaptureDevice+Extensions.swift
//  Acht
//
//  Created by forkon on 2020/6/22.
//  Copyright © 2020 waylens. All rights reserved.
//

extension AVCaptureDevice {

    public static var has4KCamera: Bool {
        return availableDevices.first(where: {$0.supportsSessionPreset(AVCaptureSession.Preset.hd4K3840x2160)}) != nil
    }

    public static var highestResolutionSupported: CMVideoDimensions? {
        var maxDimensions: CMVideoDimensions?

        availableDevices.forEach { (device) in
            device.formats.forEach { (format) in
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)

                if maxDimensions == nil {
                    maxDimensions = dimensions
                }
                else {
                    if dimensions.width > maxDimensions!.width {
                        maxDimensions = dimensions
                    }
                }
            }
        }

        return maxDimensions
    }

    private static var availableDevices: [AVCaptureDevice] {
        let availableDeviceTypes: [AVCaptureDevice.DeviceType] = {
            var deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInTelephotoCamera, .builtInWideAngleCamera]
            // 10.2
            if #available(iOS 10.2, *) {
                deviceTypes.append(.builtInDualCamera)
                if #available(iOS 11.1, *) {
                    deviceTypes.append(.builtInTrueDepthCamera)

                    if #available(iOS 13.0, *) {
                        deviceTypes.append(.builtInTripleCamera)
                        deviceTypes.append(.builtInDualWideCamera)
                        deviceTypes.append(.builtInUltraWideCamera)
                    }
                }
            }
            return deviceTypes
        }()

        let session = AVCaptureDevice.DiscoverySession(deviceTypes: availableDeviceTypes, mediaType: .video, position: .back)
        return session.devices
    }

}
