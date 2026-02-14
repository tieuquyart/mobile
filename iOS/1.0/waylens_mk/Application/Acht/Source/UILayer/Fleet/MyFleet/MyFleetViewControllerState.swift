//
//  MyFleetViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

//public struct MyFleetViewControllerState: ReSwift.StateType, Equatable {
////    public var userProfile: UserProfile
////
////    init() {
////        if let userProfile = UserSetting.current.userProfile {
////            self.userProfile = userProfile
////        } else {
////            let json = """
////                {
////                "createTime": 1572862019488,
////                "email": "example@waylens.com",
////                "fleetName": "Waylens Fleet",
////                "isVerified": true,
////                "logoUrl": "",
////                "roles": [
////                "Admin"
////                ],
////                "tzDatabase": "Asia/Shanghai",
////                "userName": "Waylens User"
////                }
////                """.data(using: .utf8)!
////
////            self.userProfile = try! JSONDecoder().decode(UserProfile.self, from: json)
////        }
////    }
////
//
//   var userProfile: UserMK
//
//    init() {
//        if let userProfile = UserSetting.current.userMK{
//            self.userProfile = userProfile
//        } else {
//            let json = """
//                {
//                        "id": 7,
//                        "avatar": "/images/user.png",
//                        "userName": "thanh_mobile",
//                        "realName": "thanh_ios",
//                        "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0aGFuaF9tb2JpbGUiLCJpYXQiOjE2MzkzNzkyNjd9.hy-Fh_O7Nly1VnB7wCCWfHoaa_ply3_5m-5pQyXXPFg",
//                        "twoStepEnabled": false,
//                        "lastLogin": "2021-12-13T13:59:34",
//                        "lastFaultyLogin": "2021-12-13T14:07:26",
//                        "createTime": "2021-12-08T15:51:55",
//                        "updateTime": "2021-12-08T15:54:07",
//                        "roleIds": [
//                            1,
//                            2
//                        ],
//                        "roleIdString": "1:2",
//                        "roleNames": [
//                            "admin",
//                            "user"
//                        ]
//                    }
//                """.data(using: .utf8)!
//
//            self.userProfile = try! JSONDecoder().decode(UserMK.self, from: json)
//        }
//    }
//}


public struct MyFleetViewControllerState: ReSwift.StateType, Equatable {
//    public var userProfile: UserProfile
//
//    init() {
//        if let userProfile = UserSetting.current.userProfile {
//            self.userProfile = userProfile
//        } else {
//            let json = """
//                {
//                "createTime": 1572862019488,
//                "email": "example@waylens.com",
//                "fleetName": "Waylens Fleet",
//                "isVerified": true,
//                "logoUrl": "",
//                "roles": [
//                "Admin"
//                ],
//                "tzDatabase": "Asia/Shanghai",
//                "userName": "Waylens User"
//                }
//                """.data(using: .utf8)!
//
//            self.userProfile = try! JSONDecoder().decode(UserProfile.self, from: json)
//        }
//    }
//
    
   var userProfile: UserProfile

    init() {
        if let userProfile = UserSetting.current.userProfile {
            self.userProfile = userProfile
        } else {
            let json = """
                {
                        "id": 7,
                        "avatar": "/images/user.png",
                        "userName": "thanh_mobile",
                        "realName": "thanh_ios",
                        "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0aGFuaF9tb2JpbGUiLCJpYXQiOjE2MzkzNzkyNjd9.hy-Fh_O7Nly1VnB7wCCWfHoaa_ply3_5m-5pQyXXPFg",
                        "twoStepEnabled": false,
                        "lastLogin": "2021-12-13T13:59:34",
                        "lastFaultyLogin": "2021-12-13T14:07:26",
                        "createTime": "2021-12-08T15:51:55",
                        "updateTime": "2021-12-08T15:54:07",
                        "roleIds": [
                            1,
                            2
                        ],
                        "roleIdString": "1:2",
                        "roleNames": [
                            "admin",
                            "user"
                        ]
                    }
                """.data(using: .utf8)!

            self.userProfile = try! JSONDecoder().decode(UserProfile.self, from: json)
        }
    }
}
