//
//  PersonnelManagementRepository.swift
//  Fleet
//
//  Created by forkon on 2019/11/8.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import PromiseKit


//class PersonnelManagementRepository {
//
//    public func loadMemberList(completion: @escaping ([FleetMember]?, Error?) -> Void) {
//        let dispatchGroup = DispatchGroup()
//        var memberPool: [FleetMember] = []
//
//        var error: Error? = nil
//
//        dispatchGroup.enter()
//        WaylensClientS.shared.fetchDriverInfoList { (result) in
//            switch result {
//            case .success(let value):
//                if let driverInfos = value["driverInfos"] as? [[String : Any]] {
//                    memberPool.append(contentsOf: driverInfos.compactMap{try? JSONDecoder().decode(FleetMember.self, from: $0.jsonData ?? Data())})
//                }
//            case .failure(let err):
//                error = err
//            }
//
//            dispatchGroup.leave()
//        }
//
//        dispatchGroup.enter()
//        WaylensClientS.shared.fetchUserNotDriverInfoList { (result) in
//            switch result {
//            case .success(let value):
//                if let userInfos = value["userInfos"] as? [[String : Any]] {
//                    memberPool.append(contentsOf: userInfos.compactMap{try? JSONDecoder().decode(FleetMember.self, from: $0.jsonData ?? Data())})
//                }
//            case .failure(let err):
//                error = err
//            }
//
//            dispatchGroup.leave()
//        }
//
//        dispatchGroup.notify(queue: DispatchQueue.main) {
//            if error != nil {
//                completion(nil, error)
//            } else {
//                memberPool.sort{$0.name < $1.name}
//                memberPool.sort{$0.roles.rawValue < $1.roles.rawValue}
//                memberPool.sort{$0.isOwner && !$1.isOwner}
//                completion(memberPool, nil)
//            }
//
//            memberPool.removeAll()
//        }
//    }
//
//}



class PersonnelManagementRepository {
    
    public func loadMemberList(completion: @escaping ([FleetMember]?, Error?) -> Void) {
     //   let dispatchGroup = DispatchGroup()
        var memberPool: [FleetMember] = []
        
       
        
        let api : UserAPI = UserService.shared
        api.all_Users(completion: { (result) in
            switch result {
            case .success(let value):
                if let success = value["success"] as? Bool {
                    if success {
                        if let data = value["data"] as? [[String : Any]] {
                            
                            if let userProfileJsonData = try? JSONSerialization.data(withJSONObject: data, options: []) {
                                do {
                                    let userProfile = try JSONDecoder().decode([FleetMember].self, from: userProfileJsonData)
                                    memberPool =  userProfile
                                    completion(memberPool, nil)
                                } catch let err {
                                    
                                    completion(nil, err)
                                }
                                
                             
                            }
                            
                        }
                    } else {
                        if let message = value["message"] as? String {
                            let err = MyError(msg: message)
                            completion(nil, err)
                        }
                        
                    }
                }
               
            case .failure(let err):
                completion(nil, err)
            }
        })
        
        
        
//        if let userProfileJsonData = try? JSONSerialization.data(withJSONObject: result, options: []),
//            let userProfile = try? JSONDecoder().decode(UserProfile.self, from: userProfileJsonData) {
//            UserSetting.current.userProfile = userProfile
//            keychain[waylensKeychainKeyToken] = userProfile.token
//            keychain[waylensKeychainKeyUserName] = userProfile.userName
//            UserSetting.shared.isLoggedIn = true
//            UserSetting.current.fleetTimeZone = TimeZone.current
//        }
        //        dispatchGroup.enter()
        //        WaylensClientS.shared.fetchDriverInfoList { (result) in
        //            switch result {
        //            case .success(let value):
        //                if let driverInfos = value["driverInfos"] as? [[String : Any]] {
        //                    memberPool.append(contentsOf: driverInfos.compactMap{try? JSONDecoder().decode(FleetMember.self, from: $0.jsonData ?? Data())})
        //                }
        //            case .failure(let err):
        //                error = err
        //            }
        //
        //            dispatchGroup.leave()
        //        }
        //
        //        dispatchGroup.enter()
        //        WaylensClientS.shared.fetchUserNotDriverInfoList { (result) in
        //            switch result {
        //            case .success(let value):
        //                if let userInfos = value["userInfos"] as? [[String : Any]] {
        //                    memberPool.append(contentsOf: userInfos.compactMap{try? JSONDecoder().decode(FleetMember.self, from: $0.jsonData ?? Data())})
        //                }
        //            case .failure(let err):
        //                error = err
        //            }
        //
        //            dispatchGroup.leave()
        //        }
        //
        //        dispatchGroup.notify(queue: DispatchQueue.main) {
        //            if error != nil {
        //                completion(nil, error)
        //            } else {
        //                memberPool.sort{$0.name < $1.name}
        //                memberPool.sort{$0.roles.rawValue < $1.roles.rawValue}
        //                memberPool.sort{$0.isOwner && !$1.isOwner}
        //                completion(memberPool, nil)
        //            }
        //
        //            memberPool.removeAll()
        //        }
    }
    
}


public struct MyError: Error {
    let msg: String

}

extension MyError: LocalizedError {
    public var errorDescription: String? {
            return NSLocalizedString(msg, comment: "")
    }
}
