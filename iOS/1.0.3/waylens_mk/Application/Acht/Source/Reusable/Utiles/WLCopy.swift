//
//  WLCopy.swift
//  Acht
//
//  Created by Chester Shen on 10/27/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation

struct WLCopy {
    // account
    static let emailTip = NSLocalizedString("email_tip", comment: "Please enter valid email address")
    static let passwordTip = NSLocalizedString("password_tip", comment: "Password must contain at least 8 characters, including both letters and numbers.")
    static let confirmPassowrdTip = NSLocalizedString("passowrd_not_match_tip", comment: "Password does not match")
    // sd card
    static let sdcardNotDetected = NSLocalizedString("sd_card_not_detected", comment: "No SD card inserted.")
    static let sdcardReady = NSLocalizedString("sd_card_ready", comment: "SD card is installed and functioning.")
    static let sdcardCapacityTooLow = NSLocalizedString("sd_card_capacity_too_low", comment: "SD card capacity too low. Use an SD card with at least 16 GB.")
    static let sdcardError = NSLocalizedString("SD card unreadable. Formatting may fix it.", comment: "SD card unreadable. Formatting may fix it.")
    static let sdcardFormatRecommended = NSLocalizedString("sd_card_format_recommended", comment: "SD card not optimized. Format the SD card to optimize it.")
    static let sdcardStateUnknown = NSLocalizedString("sd_card_state_unknown", comment: "SD card state unknown.")
    // record
    static let recordError = NSLocalizedString("record_error", comment: "Record error occurred.")
    static let recordStopped = NSLocalizedString("record_stopped", comment: "Monitoring and recording stopped.")
    // Login
    static let loginTip = NSLocalizedString("login_tip", comment: "Log in to enable more features.")
    static let bindTip = NSLocalizedString("This camera has not been added to your account.", comment: "This camera has not been added to your account.")
    // Plan
    static let noPlan = NSLocalizedString("no_data_plan", comment: "Subscribe to a data plan to enable 4G features.")
    // SIM card
    static let simCardNotDetected = NSLocalizedString("sim_card_not_detected", comment: "SIM card not inserted. Please insert the supplied SIM card and plug in the cable.")
    static let simCardNotReported = NSLocalizedString("sim_card_not_reported", comment: "SIM card not reported. Please make sure the SIM card is inserted, then reconnect the camera via Wi-Fi")
    static let simCardNotSupported = NSLocalizedString("sim_card_not_supported", comment: "SIM card not supported. Please use the supplied SIM card for Secure360.")
}

