//
//  AudioSession.swift
//  Acht
//
//  Created by forkon on 2019/7/26.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation

class AudioSessionManager: NSObject {
    private var previousCategory: AVAudioSession.Category?
    private var previousCategoryOptions: AVAudioSession.CategoryOptions?

    private(set) var currentCategory: AVAudioSession.Category?
    private(set) var currentCategoryOptions: AVAudioSession.CategoryOptions?

    override init() {
        super.init()
    }

    deinit {
    }

    func activePlayAndRecordDuckOthers() {
        activeCategoryAndOptions { () -> (AVAudioSession.Category, AVAudioSession.CategoryOptions) in
            return (AVAudioSession.Category.playAndRecord, [])
        }
    }

    func activeSessionForDmsCameraCalibration() {
        activeCategoryAndOptions { () -> (AVAudioSession.Category, AVAudioSession.CategoryOptions) in
            return (AVAudioSession.Category.playback, [AVAudioSession.CategoryOptions.allowBluetooth])
        }
    }

    func restorePreviousCategoryAndOptions() {
        guard let previousCategory = previousCategory, let previousCategoryOptions = previousCategoryOptions else {
            return
        }

        activeCategoryAndOptions { () -> (AVAudioSession.Category, AVAudioSession.CategoryOptions) in
            return (previousCategory, previousCategoryOptions)
        }

        self.previousCategory = nil
        self.previousCategoryOptions = nil
        self.currentCategory = nil
        self.currentCategoryOptions = nil
    }

    func blockChangeCategoryToNotPlayAndRecord() {
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.category != currentCategory || audioSession.categoryOptions != currentCategoryOptions  {
            if let currentCategory = currentCategory, let currentCategoryOptions = currentCategoryOptions {
                activeCategoryAndOptions { () -> (AVAudioSession.Category, AVAudioSession.CategoryOptions) in
                    return (currentCategory, currentCategoryOptions)
                }
            }
        }
    }

}

private extension AudioSessionManager {

    func activeCategoryAndOptions(with configClosure: () -> (AVAudioSession.Category, AVAudioSession.CategoryOptions)) {
        do {
            let audioSession = AVAudioSession.sharedInstance()

            let previousCategory = audioSession.category
            let previousCategoryOptions = audioSession.categoryOptions

            try audioSession.setCategory(configClosure().0, options: configClosure().1)
            try audioSession.setActive(true, options: [])

            self.previousCategory = previousCategory
            self.previousCategoryOptions = previousCategoryOptions
            self.currentCategory = configClosure().0
            self.currentCategoryOptions = configClosure().1
        } catch {
            Log.error("AudioSessionManager setup audio session error: \(error.localizedDescription)")
        }
    }

}
