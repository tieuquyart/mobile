//
//  Constant.swift
//  Acht
//
//  Created by TranHoangThanh on 11/25/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate
import Combine

//typealias SUCCESS_CLORUSE = (() -> ())
//private var window: UIWindow!

extension UIAlertController {
    func present(animated: Bool, completion: (() -> Void)?) {
//        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.windowLevel = .alert + 1
        window?.makeKeyAndVisible()
        window?.rootViewController?.present(self, animated: animated, completion: completion)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        window = nil
    }
}
    

public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

enum ResponseError: Int {
    case SUCCESS_TWO_STEP = 101
    case REQUEST_VALIDATE_ERROR = 201
    case USER_NOT_FOUND = 221
    case INCORRECT_PASSWORD = 222
    case CONS_PASS_FAULTY = 223
    case CONS_OTP_FAULTY = 224
    case USER_ALREADY_EXISTED = 225
    case INCORRECT_OTP = 226
    case ROLE_ALREADY_EXISTED = 227
    case ROLE_HAS_USERS = 228
    case PERMISSION_EXCEEDED = 229
    case USER_NOT_BOUND_FLEET = 230
    case USER_NO_DATA_PERMISSION = 231
    case USER_LOCKED = 232
    case ROLE_NOT_FOUND = 233
    case ROLE_READONLY = 234
    case FLEET_ROLE_NOT_FOUND = 235
    case MALFORMED_NAME = 236
    case MALFORMED_ACCOUNT = 237
    case MALFORMED_EMAIL = 238
    case MALFORMED_PHONE = 239
    case MALFORMED_PASSWORD = 240
    case MALFORMED_ROLE = 248
    case NAME_REPEAT = 250
    case MALFORMED_DESCRIPTION = 249
    case MERCHANT_NOT_FOUND = 241
    case MERCHANT_CERT_NOT_FOUND = 242
    case MERCHANT_CODE_REPEATED = 243
    case MERCHANT_NOT_LOCKED = 244
    case MERCHANT_ALREADY_LOCKED = 245
    case MERCHANT_NOT_DELETABLE = 246
    case MERCHANT_SIGNATUREKEY_EMPTY = 247
    case SAVE_PICTURE_ERROR = 251
    case SIGNATURE_MISSING = 211
    case SIGNATURE_INCORRECT = 212
    case INVALID_MERCHANT_CODE = 213
    case MERCHANT_CODE_NOT_MATCHED = 214
    case MERCHANT_LOCKED = 215
    case INVALID_SESSIONID = 216
    case INVALID_SESSIONID_LENGTH = 217
    case PRINCIPAL_MISSING = 218
    case INVALID_PRINCIPLE = 219
    case SIGNATURE_TYPE_INCORRECT = 220
    case CAMERA_REPEAT_SN = 300
    case CAMERA_IS_BIND_VEHICLE = 301
    case CAMERA_NOT_EXIST = 302
    case CAMERA_IS_BIND_OTHER = 303
    case CAMERA_AWAKE_ERROR = 304
    case CAMERA_UNBIND_PHONE = 305
    case UPDATE_PHONE_ERROR = 306
    case NO_CAMERA_DATA = 307
    case PASSWORD_NOT_CORRECT = 308
    case UPDATE_SPEED_ERROR = 309
    case UPDATE_TIME_STATE_ERROR = 310
    case VEHICLES_REPEAT_PLATE_NO = 320
    case VEHICLES_REPEAT_VEHICLE_NO = 321
    case PLATE_NOT_FOUND = 322
    case VEHICLE_IS_BIND_DRIVER = 323
    case VEHICLE_IS_BIND_CAMERA = 324
    case DRIVER_REPEAT_EMPLOYEE_ID = 340
    case DRIVER_IS_BIND_VEHICLE = 341
    case DRIVER_NOT_EXIST = 342
    case DRIVER_IS_BIND_OTHER = 343
    case DRIVER_REPEAT_LICENSE = 344
    case DRIVER_INVALID_LICENSE_TYPE = 345
    case DRIVER_LICENSE_USED_BY_OTHER = 346
    case DRIVER_REPEAT_CCCD = 347
    case MALFORMED_EMPLOYEE_ID = 348
    case MALFORMED_DRIVER_LICENSE = 349
    case MALFORMED_CCCD = 350
    case ADD_DRIVER_ACCESS_CAMERA_FAIL = 805
    case INVALID_EVENT_CATEGORY = 400
    case FLEET_API_ERROR = 500
    case SETTINGS_RECORDCONFIG_ERROR = 401
    case SETTINGS_MARKEDCLIPDURATION_ACCEL_ERROR = 402
    case SETTINGS_MARKEDCLIPDURATION_MANUAL_ERROR = 407
    case SETTINGS_MARKEDCLIPDURATION_DMS_ERROR = 408
    case SETTING_INCORRECT = 403
    case FLEET_NO_CONFIG = 405
    case FLEET_NO_ACTIVE = 406
    case TRIP_SN_EXIST = 501
    case TRIP_NOT_EXIST = 502
    case SCHEDULE_TIME_ALREADY_EXIST = 520
    case FLEET_VERIFY_SIGN_FAIL = 600
    case TRIP_REQUEST_FAILED = 601
    case FLEET_NAME_REPEAT = 602
    case FLEET_BOUND_USER = 603
    case FLEET_NOT_EXIST = 604
    case FLEET_NOT_SUBSCRIBED = 605
    case FLEET_NOT_MATCHED = 606
    case ACCESSKEYID_REPEAT = 607
    case MALFORMED_ACCESSKEYID = 608
    case ACCESSKEYSECRET_REPEAT = 609
    case MALFORMED_ACCESSKEYSECRET = 610
    case SUBSCRIPTION_NOT_FOUND = 621
    case SUBSCRIPTION_STATUS_INCORRECT = 623
    case SUBSCRIPTION_SAVE_COVER_FAIL = 624
    case SUBSCRIPTION_COVER_NOT_FOUND = 625
    case SUBSCRIPTION_USED = 626
    case SUBSCRIPTION_OFF_SHELVES = 627
    case PAYMENT_NOT_FOUND = 641
    case PAYMENT_SAVE_RECEIPT_FAIL = 642
    case PAYMENT_RECEIPT_ABSENT = 643
    case PAYMENT_REMARK_EMPTY = 644
    case PAYMENT_UPDATE_FLEET_FAIL = 645
    case PAYMENT_STATUS_INCORRECT = 646
    case PAYMENT_TYPE_INCORRECT = 647
    case PAYMENT_FAILED = 648
    case PAYMENT_REPEAT = 649
    case PAYMENT_ONLINE_NOT_FOUND = 650
    case TRANSPORT_KEY_ERROR = 801
    case TRANSPORT_KEY_REPEAT = 802
    case TRANSPORT_KEY_NOT_UPLOADED = 803
    case TRANSPORT_KEY_INCORRECT_USER = 804
    case TASK_TEMPLATE_NOT_FOUND = 821
    case TASK_TEMPLATE_TRUNCATE_EXISTED = 822
    case TASK_TEMPLATE_ONLY_SUMMARY_DELETED = 823
    case TASK_TEMPLATE_PARSE_ERROR = 824
    case TASK_NAME_EXISTED = 825
    case TASK_NAME_NOT_FOUND = 826
    case TASK_TYPE_INCORRECT = 827
    case TASK_TEMPLATE_IN_USE = 828
    case DELAYED_TASK_EXISTED = 829
    case DELAYED_TASK_BUILD_FAILURE = 830
    case DELAYED_TASK_NOT_FOUND = 831
    case DELAYED_TASK_CACHE_MISSING = 832
    case INVALID_ID = 889
    case REQUEST_API_ERROR = 890
    case REQUEST_NAPAS_FAILED = 891
    case INVALID_STATUS = 893
    case SEND_MESSAGE_FAILED = 896
    case INVALID_SMS_CHANNEL = 897
    case SMS_VERIFY_FILED = 898
    case INVALID_PARAMS = 892
    case EXCEL_TITLE_NOT_MATCH = 894
    case EMPTY_FILE = 895
    case UNSUPPORTED_SERVICE = 899
    case NOT_SUPPORT_PLATFORM = 950
    case PUSH_ERROR = 951
    case NOTIFICATION_NOT_EXIST = 952
    case UPDATE_VERSION_MOBILE_ERROR = 953
    case DATETIME_ERROR = 954
    case INVALID_ACCESS_TOKEN = 980
    case EXPIRED_TOKEN = 981
    case NO_ACCESS_RIGHT = 982
    case MOVE_FILE_ERROR = 983
    case DELETE_FILE_ERROR = 984
    case EXTENSION_NOT_SUPPORT = 985
    case SCHEDULER_ERROR = 995
    case PROVIDER_ERROR = 996
    case SERVER_ERROR = 997
    case DATABASE_ERROR = 998
    case UNKNOWN_ERROR = 999
    case EMAIL_ERROR = 700
    case SEND_EMAIL_ERROR = 701
    case PHONE_REPEAT = 702
    case EMAIL_REPEAT = 703
    case FIRMWARE_ERROR = 705
    case UPLOAD_FIRMWARE_ERROR = 706
    case UPDATE_FIRMWARE_ERROR = 707
    case MALFORMED_DATETIME = 708
    case MALFORMED_BIRTH_DATE = 709
    case MALFORMED_DRIVING_YEARS = 710
    case DATA_NULL = 711
    
    func title() -> String {
        switch self {
        case .SUCCESS_TWO_STEP:
            return ConstantMK.language(str: "SUCCESS_TWO_STEP".localizeMk())
        case .REQUEST_VALIDATE_ERROR:
            return ConstantMK.language(str: "REQUEST_VALIDATE_ERROR".localizeMk())
        case .USER_NOT_FOUND:
            return ConstantMK.language(str: "USER_NOT_FOUND".localizeMk())
        case .INCORRECT_PASSWORD:
            return ConstantMK.language(str: "INCORRECT_PASSWORD".localizeMk())
        case .CONS_PASS_FAULTY:
            return ConstantMK.language(str: "CONS_PASS_FAULTY".localizeMk())
        case .CONS_OTP_FAULTY:
            return ConstantMK.language(str: "CONS_OTP_FAULTY".localizeMk())
        case .USER_ALREADY_EXISTED:
            return ConstantMK.language(str: "USER_ALREADY_EXISTED".localizeMk())
        case .INCORRECT_OTP:
            return ConstantMK.language(str: "INCORRECT_OTP".localizeMk())
        case .ROLE_ALREADY_EXISTED:
            return ConstantMK.language(str: "ROLE_ALREADY_EXISTED".localizeMk())
        case .ROLE_HAS_USERS:
            return ConstantMK.language(str: "ROLE_HAS_USERS".localizeMk())
        case .PERMISSION_EXCEEDED:
            return ConstantMK.language(str: "PERMISSION_EXCEEDED".localizeMk())
        case .USER_NOT_BOUND_FLEET:
            return ConstantMK.language(str: "USER_NOT_BOUND_FLEET".localizeMk())
        case .USER_NO_DATA_PERMISSION:
            return ConstantMK.language(str: "USER_NO_DATA_PERMISSION".localizeMk())
        case .USER_LOCKED:
            return ConstantMK.language(str: "USER_LOCKED".localizeMk())
        case .ROLE_NOT_FOUND:
            return ConstantMK.language(str: "ROLE_NOT_FOUND".localizeMk())
        case .ROLE_READONLY:
            return ConstantMK.language(str: "ROLE_READONLY".localizeMk())
        case .FLEET_ROLE_NOT_FOUND:
            return ConstantMK.language(str: "FLEET_ROLE_NOT_FOUND".localizeMk())
        case .MALFORMED_NAME:
            return ConstantMK.language(str: "MALFORMED_NAME".localizeMk())
        case .MALFORMED_ACCOUNT:
            return ConstantMK.language(str: "MALFORMED_ACCOUNT".localizeMk())
        case .MALFORMED_EMAIL:
            return ConstantMK.language(str: "MALFORMED_EMAIL".localizeMk())
        case .MALFORMED_PHONE:
            return ConstantMK.language(str: "MALFORMED_PHONE".localizeMk())
        case .MALFORMED_PASSWORD:
            return ConstantMK.language(str: "MALFORMED_PASSWORD".localizeMk())
        case .MALFORMED_ROLE:
            return ConstantMK.language(str: "MALFORMED_ROLE".localizeMk())
        case .NAME_REPEAT:
            return ConstantMK.language(str: "NAME_REPEAT".localizeMk())
        case .MALFORMED_DESCRIPTION:
            return ConstantMK.language(str: "MALFORMED_DESCRIPTION".localizeMk())
        case .MERCHANT_NOT_FOUND:
            return ConstantMK.language(str: "MERCHANT_NOT_FOUND".localizeMk())
        case .MERCHANT_CERT_NOT_FOUND:
            return ConstantMK.language(str: "MERCHANT_CERT_NOT_FOUND".localizeMk())
        case .MERCHANT_CODE_REPEATED:
            return ConstantMK.language(str: "MERCHANT_CODE_REPEATED".localizeMk())
        case .MERCHANT_NOT_LOCKED:
            return ConstantMK.language(str: "MERCHANT_NOT_LOCKED".localizeMk())
        case .MERCHANT_ALREADY_LOCKED:
            return ConstantMK.language(str: "MERCHANT_ALREADY_LOCKED".localizeMk())
        case .MERCHANT_NOT_DELETABLE:
            return ConstantMK.language(str: "MERCHANT_NOT_DELETABLE".localizeMk())
        case .MERCHANT_SIGNATUREKEY_EMPTY:
            return ConstantMK.language(str: "MERCHANT_SIGNATUREKEY_EMPTY".localizeMk())
        case .SAVE_PICTURE_ERROR:
            return ConstantMK.language(str: "SAVE_PICTURE_ERROR".localizeMk())
        case .SIGNATURE_MISSING:
            return ConstantMK.language(str: "SIGNATURE_MISSING".localizeMk())
        case .SIGNATURE_INCORRECT:
            return ConstantMK.language(str: "SIGNATURE_INCORRECT".localizeMk())
        case .INVALID_MERCHANT_CODE:
            return ConstantMK.language(str: "INVALID_MERCHANT_CODE".localizeMk())
        case .MERCHANT_CODE_NOT_MATCHED:
            return ConstantMK.language(str: "MERCHANT_CODE_NOT_MATCHED".localizeMk())
        case .MERCHANT_LOCKED:
            return ConstantMK.language(str: "MERCHANT_LOCKED".localizeMk())
        case .INVALID_SESSIONID:
            return ConstantMK.language(str: "INVALID_SESSIONID".localizeMk())
        case .INVALID_SESSIONID_LENGTH:
            return ConstantMK.language(str: "INVALID_SESSIONID_LENGTH".localizeMk())
        case .PRINCIPAL_MISSING:
            return ConstantMK.language(str: "PRINCIPAL_MISSING".localizeMk())
        case .INVALID_PRINCIPLE:
            return ConstantMK.language(str: "INVALID_PRINCIPLE".localizeMk())
        case .SIGNATURE_TYPE_INCORRECT:
            return ConstantMK.language(str: "SIGNATURE_TYPE_INCORRECT".localizeMk())
        case .CAMERA_REPEAT_SN:
            return ConstantMK.language(str: "CAMERA_REPEAT_SN".localizeMk())
        case .CAMERA_IS_BIND_VEHICLE:
            return ConstantMK.language(str: "CAMERA_IS_BIND_VEHICLE".localizeMk())
        case .CAMERA_NOT_EXIST:
            return ConstantMK.language(str: "CAMERA_NOT_EXIST".localizeMk())
        case .CAMERA_IS_BIND_OTHER:
            return ConstantMK.language(str: "CAMERA_IS_BIND_OTHER".localizeMk())
        case .CAMERA_AWAKE_ERROR:
            return ConstantMK.language(str: "CAMERA_AWAKE_ERROR".localizeMk())
        case .CAMERA_UNBIND_PHONE:
            return ConstantMK.language(str: "CAMERA_UNBIND_PHONE".localizeMk())
        case .UPDATE_PHONE_ERROR:
            return ConstantMK.language(str: "UPDATE_PHONE_ERROR".localizeMk())
        case .NO_CAMERA_DATA:
            return ConstantMK.language(str: "NO_CAMERA_DATA".localizeMk())
        case .PASSWORD_NOT_CORRECT:
            return ConstantMK.language(str: "PASSWORD_NOT_CORRECT".localizeMk())
        case .UPDATE_SPEED_ERROR:
            return ConstantMK.language(str: "UPDATE_SPEED_ERROR".localizeMk())
        case .UPDATE_TIME_STATE_ERROR:
            return ConstantMK.language(str: "UPDATE_TIME_STATE_ERROR".localizeMk())
        case .VEHICLES_REPEAT_PLATE_NO:
            return ConstantMK.language(str: "VEHICLES_REPEAT_PLATE_NO".localizeMk())
        case .VEHICLES_REPEAT_VEHICLE_NO:
            return ConstantMK.language(str: "VEHICLES_REPEAT_VEHICLE_NO".localizeMk())
        case .PLATE_NOT_FOUND:
            return ConstantMK.language(str: "PLATE_NOT_FOUND".localizeMk())
        case .VEHICLE_IS_BIND_DRIVER:
            return ConstantMK.language(str: "VEHICLE_IS_BIND_DRIVER".localizeMk())
        case .VEHICLE_IS_BIND_CAMERA:
            return ConstantMK.language(str: "VEHICLE_IS_BIND_CAMERA".localizeMk())
        case .DRIVER_REPEAT_EMPLOYEE_ID:
            return ConstantMK.language(str: "DRIVER_REPEAT_EMPLOYEE_ID".localizeMk())
        case .DRIVER_IS_BIND_VEHICLE:
            return ConstantMK.language(str: "DRIVER_IS_BIND_VEHICLE".localizeMk())
        case .DRIVER_NOT_EXIST:
            return ConstantMK.language(str: "DRIVER_NOT_EXIST".localizeMk())
        case .DRIVER_IS_BIND_OTHER:
            return ConstantMK.language(str: "DRIVER_IS_BIND_OTHER".localizeMk())
        case .DRIVER_REPEAT_LICENSE:
            return ConstantMK.language(str: "DRIVER_REPEAT_LICENSE".localizeMk())
        case .DRIVER_INVALID_LICENSE_TYPE:
            return ConstantMK.language(str: "DRIVER_INVALID_LICENSE_TYPE".localizeMk())
        case .DRIVER_LICENSE_USED_BY_OTHER:
            return ConstantMK.language(str: "DRIVER_LICENSE_USED_BY_OTHER".localizeMk())
        case .DRIVER_REPEAT_CCCD:
            return ConstantMK.language(str: "DRIVER_REPEAT_CCCD".localizeMk())
        case .MALFORMED_EMPLOYEE_ID:
            return ConstantMK.language(str: "MALFORMED_EMPLOYEE_ID".localizeMk())
        case .MALFORMED_DRIVER_LICENSE:
            return ConstantMK.language(str: "MALFORMED_DRIVER_LICENSE".localizeMk())
        case .MALFORMED_CCCD:
            return ConstantMK.language(str: "MALFORMED_CCCD".localizeMk())
        case .ADD_DRIVER_ACCESS_CAMERA_FAIL:
            return ConstantMK.language(str: "ADD_DRIVER_ACCESS_CAMERA_FAIL".localizeMk())
        case .INVALID_EVENT_CATEGORY:
            return ConstantMK.language(str: "INVALID_EVENT_CATEGORY".localizeMk())
        case .FLEET_API_ERROR:
            return ConstantMK.language(str: "FLEET_API_ERROR".localizeMk())
        case .SETTINGS_RECORDCONFIG_ERROR:
            return ConstantMK.language(str: "SETTINGS_RECORDCONFIG_ERROR".localizeMk())
        case .SETTINGS_MARKEDCLIPDURATION_ACCEL_ERROR:
            return ConstantMK.language(str: "SETTINGS_MARKEDCLIPDURATION_ACCEL_ERROR".localizeMk())
        case .SETTINGS_MARKEDCLIPDURATION_MANUAL_ERROR:
            return ConstantMK.language(str: "SETTINGS_MARKEDCLIPDURATION_MANUAL_ERROR".localizeMk())
        case .SETTINGS_MARKEDCLIPDURATION_DMS_ERROR:
            return ConstantMK.language(str: "SETTINGS_MARKEDCLIPDURATION_DMS_ERROR".localizeMk())
        case .SETTING_INCORRECT:
            return ConstantMK.language(str: "SETTING_INCORRECT".localizeMk())
        case .FLEET_NO_CONFIG:
            return ConstantMK.language(str: "FLEET_NO_CONFIG".localizeMk())
        case .FLEET_NO_ACTIVE:
            return ConstantMK.language(str: "FLEET_NO_ACTIVE".localizeMk())
        case .TRIP_SN_EXIST:
            return ConstantMK.language(str: "TRIP_SN_EXIST".localizeMk())
        case .TRIP_NOT_EXIST:
            return ConstantMK.language(str: "TRIP_NOT_EXIST".localizeMk())
        case .SCHEDULE_TIME_ALREADY_EXIST:
            return ConstantMK.language(str: "SCHEDULE_TIME_ALREADY_EXIST".localizeMk())
        case .FLEET_VERIFY_SIGN_FAIL:
            return ConstantMK.language(str: "FLEET_VERIFY_SIGN_FAIL".localizeMk())
        case .TRIP_REQUEST_FAILED:
            return ConstantMK.language(str: "TRIP_REQUEST_FAILED".localizeMk())
        case .FLEET_NAME_REPEAT:
            return ConstantMK.language(str: "FLEET_NAME_REPEAT".localizeMk())
        case .FLEET_BOUND_USER:
            return ConstantMK.language(str: "FLEET_BOUND_USER".localizeMk())
        case .FLEET_NOT_EXIST:
            return ConstantMK.language(str: "FLEET_NOT_EXIST".localizeMk())
        case .FLEET_NOT_SUBSCRIBED:
            return ConstantMK.language(str: "FLEET_NOT_SUBSCRIBED".localizeMk())
        case .FLEET_NOT_MATCHED:
            return ConstantMK.language(str: "FLEET_NOT_MATCHED".localizeMk())
        case .ACCESSKEYID_REPEAT:
            return ConstantMK.language(str: "ACCESSKEYID_REPEAT".localizeMk())
        case .MALFORMED_ACCESSKEYID:
            return ConstantMK.language(str: "MALFORMED_ACCESSKEYID".localizeMk())
        case .ACCESSKEYSECRET_REPEAT:
            return ConstantMK.language(str: "ACCESSKEYSECRET_REPEAT".localizeMk())
        case .MALFORMED_ACCESSKEYSECRET:
            return ConstantMK.language(str: "MALFORMED_ACCESSKEYSECRET".localizeMk())
        case .SUBSCRIPTION_NOT_FOUND:
            return ConstantMK.language(str: "SUBSCRIPTION_NOT_FOUND".localizeMk())
        case .SUBSCRIPTION_STATUS_INCORRECT:
            return ConstantMK.language(str: "SUBSCRIPTION_STATUS_INCORRECT".localizeMk())
        case .SUBSCRIPTION_SAVE_COVER_FAIL:
            return ConstantMK.language(str: "SUBSCRIPTION_SAVE_COVER_FAIL".localizeMk())
        case .SUBSCRIPTION_COVER_NOT_FOUND:
            return ConstantMK.language(str: "SUBSCRIPTION_COVER_NOT_FOUND".localizeMk())
        case .SUBSCRIPTION_USED:
            return ConstantMK.language(str: "SUBSCRIPTION_USED".localizeMk())
        case .SUBSCRIPTION_OFF_SHELVES:
            return ConstantMK.language(str: "SUBSCRIPTION_OFF_SHELVES".localizeMk())
        case .PAYMENT_NOT_FOUND:
            return ConstantMK.language(str: "PAYMENT_NOT_FOUND".localizeMk())
        case .PAYMENT_SAVE_RECEIPT_FAIL:
            return ConstantMK.language(str: "PAYMENT_SAVE_RECEIPT_FAIL".localizeMk())
        case .PAYMENT_RECEIPT_ABSENT:
            return ConstantMK.language(str: "PAYMENT_RECEIPT_ABSENT".localizeMk())
        case .PAYMENT_REMARK_EMPTY:
            return ConstantMK.language(str: "PAYMENT_REMARK_EMPTY".localizeMk())
        case .PAYMENT_UPDATE_FLEET_FAIL:
            return ConstantMK.language(str: "PAYMENT_UPDATE_FLEET_FAIL".localizeMk())
        case .PAYMENT_STATUS_INCORRECT:
            return ConstantMK.language(str: "PAYMENT_STATUS_INCORRECT".localizeMk())
        case .PAYMENT_TYPE_INCORRECT:
            return ConstantMK.language(str: "PAYMENT_TYPE_INCORRECT".localizeMk())
        case .PAYMENT_FAILED:
            return ConstantMK.language(str: "PAYMENT_FAILED".localizeMk())
        case .PAYMENT_REPEAT:
            return ConstantMK.language(str: "PAYMENT_REPEAT".localizeMk())
        case .PAYMENT_ONLINE_NOT_FOUND:
            return ConstantMK.language(str: "PAYMENT_ONLINE_NOT_FOUND".localizeMk())
        case .TRANSPORT_KEY_ERROR:
            return ConstantMK.language(str: "TRANSPORT_KEY_ERROR".localizeMk())
        case .TRANSPORT_KEY_REPEAT:
            return ConstantMK.language(str: "TRANSPORT_KEY_REPEAT".localizeMk())
        case .TRANSPORT_KEY_NOT_UPLOADED:
            return ConstantMK.language(str: "TRANSPORT_KEY_NOT_UPLOADED".localizeMk())
        case .TRANSPORT_KEY_INCORRECT_USER:
            return ConstantMK.language(str: "TRANSPORT_KEY_INCORRECT_USER".localizeMk())
        case .TASK_TEMPLATE_NOT_FOUND:
            return ConstantMK.language(str: "TASK_TEMPLATE_NOT_FOUND".localizeMk())
        case .TASK_TEMPLATE_TRUNCATE_EXISTED:
            return ConstantMK.language(str: "TASK_TEMPLATE_TRUNCATE_EXISTED".localizeMk())
        case .TASK_TEMPLATE_ONLY_SUMMARY_DELETED:
            return ConstantMK.language(str: "TASK_TEMPLATE_ONLY_SUMMARY_DELETED".localizeMk())
        case .TASK_TEMPLATE_PARSE_ERROR:
            return ConstantMK.language(str: "TASK_TEMPLATE_PARSE_ERROR".localizeMk())
        case .TASK_NAME_EXISTED:
            return ConstantMK.language(str: "TASK_NAME_EXISTED".localizeMk())
        case .TASK_NAME_NOT_FOUND:
            return ConstantMK.language(str: "TASK_NAME_NOT_FOUND".localizeMk())
        case .TASK_TYPE_INCORRECT:
            return ConstantMK.language(str: "TASK_TYPE_INCORRECT".localizeMk())
        case .TASK_TEMPLATE_IN_USE:
            return ConstantMK.language(str: "TASK_TEMPLATE_IN_USE".localizeMk())
        case .DELAYED_TASK_EXISTED:
            return ConstantMK.language(str: "DELAYED_TASK_EXISTED".localizeMk())
        case .DELAYED_TASK_BUILD_FAILURE:
            return ConstantMK.language(str: "DELAYED_TASK_BUILD_FAILURE".localizeMk())
        case .DELAYED_TASK_NOT_FOUND:
            return ConstantMK.language(str: "DELAYED_TASK_NOT_FOUND".localizeMk())
        case .DELAYED_TASK_CACHE_MISSING:
            return ConstantMK.language(str: "DELAYED_TASK_CACHE_MISSING".localizeMk())
        case .INVALID_ID:
            return ConstantMK.language(str: "INVALID_ID".localizeMk())
        case .REQUEST_API_ERROR:
            return ConstantMK.language(str: "REQUEST_API_ERROR".localizeMk())
        case .REQUEST_NAPAS_FAILED:
            return ConstantMK.language(str: "REQUEST_NAPAS_FAILED".localizeMk())
        case .INVALID_STATUS:
            return ConstantMK.language(str: "INVALID_STATUS".localizeMk())
        case .SEND_MESSAGE_FAILED:
            return ConstantMK.language(str: "SEND_MESSAGE_FAILED".localizeMk())
        case .INVALID_SMS_CHANNEL:
            return ConstantMK.language(str: "INVALID_SMS_CHANNEL".localizeMk())
        case .SMS_VERIFY_FILED:
            return ConstantMK.language(str: "SMS_VERIFY_FILED".localizeMk())
        case .INVALID_PARAMS:
            return ConstantMK.language(str: "INVALID_PARAMS".localizeMk())
        case .EXCEL_TITLE_NOT_MATCH:
            return ConstantMK.language(str: "EXCEL_TITLE_NOT_MATCH".localizeMk())
        case .EMPTY_FILE:
            return ConstantMK.language(str: "EMPTY_FILE".localizeMk())
        case .UNSUPPORTED_SERVICE:
            return ConstantMK.language(str: "UNSUPPORTED_SERVICE".localizeMk())
        case .NOT_SUPPORT_PLATFORM:
            return ConstantMK.language(str: "NOT_SUPPORT_PLATFORM".localizeMk())
        case .PUSH_ERROR:
            return ConstantMK.language(str: "PUSH_ERROR".localizeMk())
        case .NOTIFICATION_NOT_EXIST:
            return ConstantMK.language(str: "NOTIFICATION_NOT_EXIST".localizeMk())
        case .UPDATE_VERSION_MOBILE_ERROR:
            return ConstantMK.language(str: "UPDATE_VERSION_MOBILE_ERROR".localizeMk())
        case .DATETIME_ERROR:
            return ConstantMK.language(str: "DATETIME_ERROR".localizeMk())
        case .INVALID_ACCESS_TOKEN:
            return ConstantMK.language(str: "INVALID_ACCESS_TOKEN".localizeMk())
        case .EXPIRED_TOKEN:
            return ConstantMK.language(str: "EXPIRED_TOKEN".localizeMk())
        case .NO_ACCESS_RIGHT:
            return ConstantMK.language(str: "NO_ACCESS_RIGHT".localizeMk())
        case .MOVE_FILE_ERROR:
            return ConstantMK.language(str: "MOVE_FILE_ERROR".localizeMk())
        case .DELETE_FILE_ERROR:
            return ConstantMK.language(str: "DELETE_FILE_ERROR".localizeMk())
        case .EXTENSION_NOT_SUPPORT:
            return ConstantMK.language(str: "EXTENSION_NOT_SUPPORT".localizeMk())
        case .SCHEDULER_ERROR:
            return ConstantMK.language(str: "SCHEDULER_ERROR".localizeMk())
        case .PROVIDER_ERROR:
            return ConstantMK.language(str: "PROVIDER_ERROR".localizeMk())
        case .SERVER_ERROR:
            return ConstantMK.language(str: "SERVER_ERROR".localizeMk())
        case .DATABASE_ERROR:
            return ConstantMK.language(str: "DATABASE_ERROR".localizeMk())
        case .UNKNOWN_ERROR:
            return ConstantMK.language(str: "UNKNOWN_ERROR".localizeMk())
        case .EMAIL_ERROR:
            return ConstantMK.language(str: "EMAIL_ERROR".localizeMk())
        case .SEND_EMAIL_ERROR:
            return ConstantMK.language(str: "SEND_EMAIL_ERROR".localizeMk())
        case .PHONE_REPEAT:
            return ConstantMK.language(str: "PHONE_REPEAT".localizeMk())
        case .EMAIL_REPEAT:
            return ConstantMK.language(str: "EMAIL_REPEAT".localizeMk())
        case .FIRMWARE_ERROR:
            return ConstantMK.language(str: "FIRMWARE_ERROR".localizeMk())
        case .UPLOAD_FIRMWARE_ERROR:
            return ConstantMK.language(str: "UPLOAD_FIRMWARE_ERROR".localizeMk())
        case .UPDATE_FIRMWARE_ERROR:
            return ConstantMK.language(str: "UPDATE_FIRMWARE_ERROR".localizeMk())
        case .MALFORMED_DATETIME:
            return ConstantMK.language(str: "MALFORMED_DATETIME".localizeMk())
        case .MALFORMED_BIRTH_DATE:
            return ConstantMK.language(str: "MALFORMED_BIRTH_DATE".localizeMk())
        case .MALFORMED_DRIVING_YEARS:
            return ConstantMK.language(str: "MALFORMED_DRIVING_YEARS".localizeMk())
        case .DATA_NULL:
            return ConstantMK.language(str: "DATA_NULL".localizeMk())
        }
    }
    
}



extension String {

    func validatePhone() -> Bool {
//        let PHONE_REGEX = "(84|0[3|5|7|8|9])+([0-9]{8})"
        let PHONE_REGEX = "^[+]?[0-9]{10,13}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: self)
        return result
    }
    
    func containsOnlyLetters() -> Bool {
       for chr in self {
          if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
             return false
          }
       }
       return true
    }
    func matchsIn(regexString: String) -> Bool {
            do { let regex = try NSRegularExpression(pattern: regexString, options: [])
                 return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.utf8.count)) != nil
            } catch { return false }
        }
}

let providerSecret = "MKVisionK2CePwUjJcV2Wyf8RxIWqkJ6"

struct ConstantMK {
    static let bgColorLogin = "F5F5F5"
    static let blueButton = "165FCE"
    static let bgTabar = "FFFFFF"
    static let highlightIconTabbar = "165FCE"
    static let grayLabel = "9DA1A7"
    static let greenLabel = "7DC065"
    static let borderGrayColor = "EEEEEE"
    static let redBGColor = "F3E4E5"
    static let redTextColor = "E4636B"
    static let greenBG = "E6F9EF"
    static let grayBG = "F5F5F5"
    static let purpleBG = "F5EDFD"
    static let purpleText = "9E57E5"
//    static let bg_main_color = "F5F5F5"
    static let bg_main_color = "FFFFFF"
    static var vehicleItemList : [VehicleItemModel] = []
    static var isShowUpdate = false
    static var isUseMOC = false
    static var locationHN = CLLocationCoordinate2D(latitude: 21.028333, longitude: 105.853333)
    
    static func language(str : String) -> String {
        return NSLocalizedString(str, comment: str)
    }
    
    static var tokenFCM : String?
    
    
    static func getVehicleWithPlateNo(str : String?) -> VehicleItemModel?{
        for item in ConstantMK.vehicleItemList{
            if str == item.plateNo {
                return item
            }
        }
        return nil
    }
    
    static func initConfig(){
    }
    
    static func deinitConfig(){
    }
    
    static func drivingTimeToDate(value : String) ->  Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: value)!
        return date
    }
    
    
    static func fixTimeLabel(time : String) -> String {
//        let date = drivingTimeToDate(value: time)
//        return date.toString(format: .isoDate)
        
        
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: time)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = tempLocale // reset the locale
        let dateString = dateFormatter.string(from: date)
        print("EXACT_DATE : \(dateString)")
        return dateString
    }
    
    
    
    static func okButton() -> String {
         return language(str: "OK")
    }
    static func cancelButton() -> String {
        return language(str: "Cancel")
    }
    
    static func borderButton( _ items : [UIButton]) {
        items.forEach { btn in
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 8
            btn.layer.masksToBounds = true
        }
    }
    
    static func borderTF( _ items : [UITextField]) {
        items.forEach { tf in
            tf.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
            tf.layer.borderColor = UIColor.lightGray.cgColor
            tf.layer.borderWidth = 1
            tf.layer.cornerRadius = 8
            tf.layer.masksToBounds = true
        }
    }
    
    static func parseJson(dict : JSON , handler : @escaping (Bool, String, Int) -> ()) {
        var code = dict["code"] as? String
        if let success = dict["success"] as? Bool {
            if success{
                handler(success,"", Int("\(code ?? "")") ?? 0)
            }else{
                if let msg = dict["message"] as? String{
                    handler(false,msg, Int("\(code ?? "")") ?? 0)
                }else{
                    handler(false,"failure", Int("\(code ?? "")") ?? 0)
                }
            }
        } else {
            
            if let mess = dict["message"] as? String {
                handler(false,mess, Int("\(code ?? "")") ?? 0)
            }else{
                handler(false,"failure", Int("\(code ?? "")") ?? 0)
            }
            
        }
        
    }
    static var statusBarHeight: CGFloat {
        var height : CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first(where: \.isKeyWindow)
            height = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            height = UIApplication.shared.statusBarFrame.height
        }
        
        return height
    }
    
}

//7DC065


extension PaddingLabel {
    
    func borderGrayMK() {
        //Setting the border
              layer.borderWidth = 1
              layer.borderColor = UIColor.blue.cgColor
              
              //Setting the round (optional)
              layer.masksToBounds = true
              layer.cornerRadius = frame.height / 2
          
              //Setting the padding label
              edgeInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
       
    }
    
    func backGroundGrayMK(){
        textColor = .white
        layer.backgroundColor = UIColor.lightGray.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = frame.height / 2
        edgeInset = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
    }
    
    
}
extension String {
    
    func fixTimeLabel() -> String {
//        let date = drivingTimeToDate(value: time)
//        return date.toString(format: .isoDate)
        if self.isEmpty {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: self)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = tempLocale // reset the locale
        let dateString = dateFormatter.string(from: date)
        print("EXACT_DATE : \(dateString)")
        return dateString
    }
}





class PaddingLabel: UILabel {

    var edgeInset: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: edgeInset.top, left: edgeInset.left, bottom: edgeInset.bottom, right: edgeInset.right)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + edgeInset.left + edgeInset.right, height: size.height + edgeInset.top + edgeInset.bottom)
    }
}


extension UIImage
{
  func resizedImage(Size sizeImage: CGSize) -> UIImage?
  {
      let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: sizeImage.width, height: sizeImage.height))
      UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
      self.draw(in: frame)
      let resizedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      self.withRenderingMode(.alwaysOriginal)
      return resizedImage
  }
}




import UIKit

extension CAShapeLayer {
func drawRoundedRect(rect: CGRect, andColor color: UIColor, filled: Bool) {
    fillColor = filled ? color.cgColor : UIColor.white.cgColor
    strokeColor = color.cgColor
    path = UIBezierPath(roundedRect: rect, cornerRadius: 7).cgPath
}
}

private var handle: UInt8 = 0;

extension UIBarButtonItem {
private var badgeLayer: CAShapeLayer? {
    if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
        return b as? CAShapeLayer
    } else {
        return nil
    }
}

func setBadge(text: String?, withOffsetFromTopRight offset: CGPoint = CGPoint.zero, andColor color:UIColor = UIColor.red, andFilled filled: Bool = true, andFontSize fontSize: CGFloat = 10)
{
    badgeLayer?.removeFromSuperlayer()

    if (text == nil || text == "") {
        return
    }

    addBadge(text: text!, withOffset: offset, andColor: color, andFilled: filled)
}

private func addBadge(text: String, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true, andFontSize fontSize: CGFloat = 10)
{
    guard let view = self.value(forKey: "view") as? UIView else { return }

    var font = UIFont(name: "BeVietnamPro-Bold", size: fontSize)!

     if #available(iOS 9.0, *) { font = UIFont(name: "BeVietnamPro-Regular", size: fontSize)! }
    let badgeSize = text.size(withAttributes: [NSAttributedString.Key.font: font])

    // Initialize Badge
    let badge = CAShapeLayer()

    let height = badgeSize.height + 2;
    var width = badgeSize.width + 6 /* padding */

    //make sure we have at least a circle
    if (width < height) {
        width = height
    }

    //x position is offset from right-hand side
    let x = view.frame.width - width + offset.x

    let badgeFrame = CGRect(origin: CGPoint(x: x + 2 , y: offset.y), size: CGSize(width: width, height: height))

    badge.drawRoundedRect(rect: badgeFrame, andColor: color, filled: filled)
    badge.lineWidth = 1
    badge.strokeColor = UIColor.color(fromHex: ConstantMK.blueButton).cgColor
    view.layer.addSublayer(badge)

    // Initialiaze Badge's label
    let label = CATextLayer()
    label.string = text
    label.alignmentMode = CATextLayerAlignmentMode.center
    label.font = font
    label.fontSize = fontSize
   

    label.frame = CGRect(origin: CGPoint(x: x + 2 , y: offset.y - 1), size: CGSize(width: width, height: height))
    label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
    label.backgroundColor = UIColor.clear.cgColor
    label.contentsScale = UIScreen.main.scale
    badge.addSublayer(label)

    // Save Badge as UIBarButtonItem property
    objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

 func removeBadge() {
    badgeLayer?.removeFromSuperlayer()
}
}


extension CALayer {


    func innerBorder(borderOffset: CGFloat = 24, borderColor: UIColor = UIColor.blue, borderWidth: CGFloat = 2) {
        let innerBorder = CALayer()
        innerBorder.frame = CGRect(x: borderOffset, y: borderOffset, width: frame.size.width - 2 * borderOffset, height: frame.size.height - 2 * borderOffset)
        innerBorder.borderColor = borderColor.cgColor
        innerBorder.borderWidth = borderWidth
        innerBorder.name = "innerBorder"
        insertSublayer(innerBorder, at: 0)
    }
}




extension UIButton {
    func addRightIcon(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)

        let length = CGFloat(15)
        titleEdgeInsets.right += length

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.titleLabel!.trailingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: length),
            imageView.heightAnchor.constraint(equalToConstant: length)
        ])
    }
    
    func addLeftIcon(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)

        let length = CGFloat(15)
        titleEdgeInsets.left += length

        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: self.titleLabel!.leadingAnchor, constant: -10),
            imageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: length),
            imageView.heightAnchor.constraint(equalToConstant: length)
        ])
    }
}



extension Bundle {

    var appName: String {
        return infoDictionary?["CFBundleName"] as! String
    }

    var bundleId: String {
        return bundleIdentifier!
    }

    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }

}
