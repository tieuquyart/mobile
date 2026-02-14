//
//  WLError.swift
//  Acht
//
//  Created by Chester Shen on 8/3/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation

struct WLError: Error {
    let code: Int
    var msg: String
    var asAPIError: WLAPIError? {
        return WLAPIError(rawValue: code)
    }
    var localizedDescription: String {
        return asAPIError?.message ?? msg
    }
}

enum WLAPIError: Int {
    case networkError = -1
    #if FLEET
    case jsonFormatError = 4000
    #else
    case jsonFormatError = 1
    #endif
    case unsupportedParameters = 2
    case md5ValidationError = 3
    case thirdPartyAccessDenied = 21
    case notVerified = 22
    case authFailed = 23
    case notAuthed = 24
    case accountAlreadyBoundToCredentials = 26
    case accountAlreadyLinkedToSocialProvider = 27
    case accountNotLinkedToSocialProvider = 28
    case usernameExisted = 30
    case emailExisted = 31
    case emailNotExisted = 32
    case invalidEmail = 33
    case invalidUsername = 34
    case invalidPassword = 36
    case alreadyVerified = 37
    #if FLEET
    case incorrectUsernameOrPassword = 3999
    case exceedMaxRetryLimit = 4004
    case notReachMinRetryInterval = 4003
    case expiredVerificationToken = 4005
    case wrongVerificationToken = 4006
    #else
    case exceedMaxRetryLimit = 39
    case notReachMinRetryInterval = 40
    case expiredVerificationToken = 41
    case wrongVerificationToken = 42
    #endif
    case wrongAccountOrPassword = 43
    case wrongCameraPassword = 200
    case deviceBoundToAnotherUser = 201
    case cameraNotExist = 202
    case deviceBoundToSelf = 203
    case illegalCamraName = 204
    case deviceNotBound = 205
    case cameraOffline = 250
    case cannotContactServer = 252
    case reportNoSignal = 254
    case noIccid = 255
    case notApprovedSim = 301
    case notOriginalSim = 302
    
    var message: String? {
        switch self {
        case .networkError:
            return NSLocalizedString("Network not available", comment: "Network not available")
        case .jsonFormatError:
            return NSLocalizedString("Server temporarily down", comment: "Server temporarily down")
        case .unsupportedParameters, .md5ValidationError, .thirdPartyAccessDenied:
            return nil
        case .notVerified:
            return NSLocalizedString("Account not verified", comment: "Account not verified")
        case .authFailed:
            return NSLocalizedString("You have been logged out", comment: "You have been logged out")
        case .notAuthed:
            return NSLocalizedString("Camera is not added to this account. Please add the camera first", comment: "You are not the owner of the device")
        case .usernameExisted:
            return NSLocalizedString("Username already taken, please choose another username", comment: "Username already taken, please choose another username")
        case .emailExisted:
            return NSLocalizedString("Email already registered, please try another email or log in", comment: "Email already registered, please try another email or log in")
        case .emailNotExisted:
            return NSLocalizedString("email_not_exist", comment: "Email does not exist, check the email and try again")
        case .invalidEmail:
            return NSLocalizedString("Email Invalid, check the email and try again", comment: "Email Invalid, check the email and try again")
        case .invalidUsername:
            return NSLocalizedString("Username invalid, please try again", comment: "Username invalid, please try again")
        case .invalidPassword:
            return NSLocalizedString("Password is invalid, please try again", comment: "Password is invalid, please try again")
            #if FLEET
        case .incorrectUsernameOrPassword:
            return NSLocalizedString("Username or password is incorrect, please try again.", comment: "Username or password is incorrect, please try again.")
            #endif
        case .alreadyVerified:
            return NSLocalizedString("Account is already verified. Please try to login again", comment: "Account is already verified. Please try to login again")
        case .exceedMaxRetryLimit:
            return NSLocalizedString("Too many verification emails have been sent, please check your email again, including spam or junk folders", comment: "Too many verification emails have been sent, please check your email again, including spam or junk folders")
        case .notReachMinRetryInterval:
            return NSLocalizedString("We've just sent a verification email, please wait 5 minutes, check your email and try again", comment: "We've just sent a verification email, please wait 5 minutes, check your email and try again")
        case .expiredVerificationToken:
            return NSLocalizedString("Verification code expired, please verify again", comment: "Verification code expired, please verify again")
        case .wrongVerificationToken:
            return NSLocalizedString("Please input correct verification code", comment: "Please input correct verification code")
        case .wrongAccountOrPassword:
            return NSLocalizedString("Incorrect email or password", comment: "Incorrect email or password")
        case .wrongCameraPassword:
            return NSLocalizedString("Camera password incorrect, please contact support", comment: "Camera password incorrect, please contact support")
        case .deviceBoundToAnotherUser:
            return NSLocalizedString("device_bound_to_another_user_message", comment: "The camera is already added to another account, remove it first.")
        case .cameraNotExist:
            return NSLocalizedString("Error 202, please contact support", comment: "Error 202, please contact support")
        case .deviceBoundToSelf:
            return nil
        case .illegalCamraName:
            return nil
        case .deviceNotBound:
            return NSLocalizedString("Camera is not added to this account. Please add the camera first", comment: "Camera is not added to this account. Please add the camera first")
        case .cameraOffline:
            return NSLocalizedString("The camera is offline", comment: "The camera is offline")
        case .reportNoSignal:
            return nil
        case .cannotContactServer:
            return NSLocalizedString("Poor connection with the camera. Please try again later", comment: "Poor connection with the camera. Please try again later")
        case .noIccid:
            return WLCopy.simCardNotReported
        case .notApprovedSim:
            return WLCopy.simCardNotSupported
        case .notOriginalSim:
            return WLCopy.simCardNotSupported
        default:
            return nil
        }
    }
}
