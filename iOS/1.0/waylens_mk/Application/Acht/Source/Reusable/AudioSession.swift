//
//  AudioSession.swift
//  Acht
//
//  Created by forkon on 2019/7/26.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class AudioSession {

    func activePlayAndRecordDuckOthers() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: [AVAudioSession.CategoryOptions.duckOthers, AVAudioSession.CategoryOptions.defaultToSpeaker])
            try audioSession.setActive(true, options: [])
        } catch {
            print("VoiceController setup audio session error: \(error.localizedDescription)")
        }
    }

}
