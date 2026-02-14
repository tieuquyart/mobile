//
//  VoiceController.swift
//  Acht
//
//  Created by forkon on 2019/7/26.
//  Copyright © 2019 waylens. All rights reserved.
//

import WaylensPiedPiper
import WaylensFoundation

#if IOS_SIMULATOR

typealias VoiceControllerStatus = WOWZStatus

protocol VoiceControllerDelegate: class {
}

class WOWZStatus : NSObject {

    enum WOWZState {
        case idle
        case starting
        case running
        case stopping
        case ready
        case buffering
    }
    enum WOWZEvent {
        case idle
        case starting
        case running
        case stopping
        case ready
    }
    var state : WOWZState?
    var event : WOWZEvent?

    var isIdle = true
}

class VoiceController: NSObject {

    weak var delegate: VoiceControllerDelegate?

    var status = WOWZStatus()

    init?(licenseKey: String) {
        super.init()
    }

    func startStreaming(with camera: UnifiedCamera) -> Future<Void> {
        let promise = Promise<Void>()
        return promise.future
    }

    func endStreaming(with camera: UnifiedCamera) {
    }
}

#else

import WowzaGoCoderSDK

typealias VoiceControllerStatus = WOWZStatus

protocol VoiceControllerDelegate: class {
    func voiceController(_ voiceController: VoiceController, statusDidChange newStatus: VoiceControllerStatus, error: Error?)
}

extension VoiceControllerDelegate {

    func voiceController(_ voiceController: VoiceController, statusDidChange newStatus: VoiceControllerStatus, error: Error?) {}

}

enum VoiceControllerError: Error {
    case recordPermissionDenied
    case networkError
    case apiError

    var localizedDescription: String {
        switch self {
        case .recordPermissionDenied:
            return NSLocalizedString("Please allow Fleet App to access your microphone from device menu:\n \"Settings\"->\"Privacy\"->\"Microphone\"", comment: "")
        case .networkError:
            return NSLocalizedString("Please check network connection.", comment: "")
        case .apiError:
            return NSLocalizedString("Cannot connect this camera, maybe it's offline, please try it later.", comment: "")
        }
    }
}

class VoiceController: NSObject {
    private typealias AudioStreamController = WowzaGoCoder

    private var audioStreamController: AudioStreamController

    private(set) var audioSessionManager: AudioSessionManager = AudioSessionManager()
    weak var delegate: VoiceControllerDelegate?

    var isStreaming: Bool {
        return audioStreamController.isStreaming
    }

    var status: WOWZStatus {
        return audioStreamController.status
    }

    init?(licenseKey: String) {
        let error = AudioStreamController.registerLicenseKey(licenseKey)

        if error != nil {
            Log.error("\(error?.localizedDescription ?? "AudioStreamController failed to register license key")")
            return nil
        } else {
            if let audioStreamController = AudioStreamController.sharedInstance() {
                AudioStreamController.setLogLevel(WowzaGoCoderLogLevel.error)
                audioStreamController.audioSessionOptions = []
                self.audioStreamController = audioStreamController
            } else {
                Log.error("Failed to create AudioStreamController")
                return nil
            }
        }

        super.init()

        setup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setup() {
        let broadcastConfig = audioStreamController.config

        broadcastConfig.videoEnabled = false
        broadcastConfig.audioEnabled = true

        broadcastConfig.audioChannels = 1
        broadcastConfig.audioSampleRate = 24000
        broadcastConfig.audioBitrate = 16000

        audioStreamController.config = broadcastConfig

        GoCoderBroadcastManagerTweaker.tweak()
    }

    func startStreaming(with camera: UnifiedCamera) -> Future<Void> {
        let promise = Promise<Void>()

        if audioStreamController.status.state == .running {
            audioStreamController.endStreaming(self)
        }

        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            if granted {
                WaylensClientS.shared.startAudioBroadcast(camera.sn) { [weak self] (result) in
                    guard let strongSelf = self else {
                        return
                    }

                    switch result {
                    case .success(let value):
                        guard let pushInfo = value["pushInfo"] as? [String : Any],
                            let urlString = pushInfo["url"] as? String,
                            let userName = pushInfo["userName"] as? String,
                            let password = pushInfo["password"] as? String else {
                            Log.error("Cannot start audio broadcast: API Error.")
                            promise.fail(VoiceControllerError.apiError)
                            return
                        }

                        guard let url = URL(string: urlString),
                            let host = url.host,
                            let port = url.port,
                            url.pathComponents.count >= 3 else {
                                Log.error("Cannot start audio broadcast: url is invalid.")
                                promise.fail(VoiceControllerError.apiError)
                                return
                        }

                        let goCoderBroadcastConfig = strongSelf.audioStreamController.config

                        goCoderBroadcastConfig.hostAddress = host
                        goCoderBroadcastConfig.portNumber = UInt(port)
                        goCoderBroadcastConfig.applicationName = url.pathComponents[1]
                        goCoderBroadcastConfig.streamName = url.pathComponents[2]
                        goCoderBroadcastConfig.username = userName
                        goCoderBroadcastConfig.password = password

                        strongSelf.audioStreamController.config = goCoderBroadcastConfig

                        let configValidationError = strongSelf.audioStreamController.config.validateForBroadcast()
                        if (configValidationError != nil) {
                            Log.error("\(configValidationError?.localizedDescription ?? "AudioStreamController invalid config")")
                            promise.fail(VoiceControllerError.apiError)
                        } else {
                            strongSelf.audioStreamController.startStreaming(self)
                            strongSelf.audioSessionManager.activePlayAndRecordDuckOthers()

                            promise.succeed(())
                        }
                    case .failure(_):
                        promise.fail(VoiceControllerError.networkError)
                    }

                }
            } else {
                promise.fail(VoiceControllerError.recordPermissionDenied)
            }
        }

        return promise.future
    }

    func endStreaming(with camera: UnifiedCamera) {
        audioStreamController.endStreaming(self)
        audioSessionManager.restorePreviousCategoryAndOptions()

        WaylensClientS.shared.stopAudioBroadcast(camera.sn, completion: nil)
    }

}

extension VoiceController: WOWZStatusCallback {

    @objc func onWOWZStatus(_ status: WOWZStatus!) {
        delegate?.voiceController(self, statusDidChange: status, error: nil)
    }

    @objc func onWOWZError(_ status: WOWZStatus!) {
        delegate?.voiceController(self, statusDidChange: status, error: status.error)
    }

}

#endif
