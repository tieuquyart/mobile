//
//  SaveNewMemberUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

//class SaveNewMemberUseCase: MemberUseCase {
//
//    public override func start() {
//        actionDispatcher.dispatch(ActivityIndicatingAction(state: .saving))
//
//        if member.roles.contains(.driver) {
//            WaylensClientS.shared.request(
//                .addNewDriver(
//                    email: member.email,
//                    name: member.name,
//                    phoneNumber: member.phoneNumber
//                )
//            ) { (result) in
//                switch result {
//                case .success(_):
//                    self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSaving))
//                case .failure(let error):
//                    let errorDescription: String = error?.localizedDescription ?? ""
//                    let message = ErrorMessage(title: NSLocalizedString("Failed to Save", comment: "Failed to Save"), message: errorDescription)
//                    self.actionDispatcher.dispatch(MemberActions.failedToProcess(errorMessage: message))
//                }
//            }
//
//        } else {
//            assert(member.email != nil, "Email is required when create not-driver member!")
//            WaylensClientS.shared.request(
//                .addNewMemberNotDriver(
//                    email: member.email!,
//                    name: member.name,
//                    phoneNumber: member.phoneNumber,
//                    role: member.roles.stringArrayValue
//                )
//            ) { (result) in
//                switch result {
//                case .success(_):
//                    self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSaving))
//                case .failure(let error):
//                    let errorDescription: String = error?.localizedDescription ?? ""
//                    let message = ErrorMessage(title: NSLocalizedString("Failed to Save", comment: "Failed to Save"), message: errorDescription)
//                    self.actionDispatcher.dispatch(MemberActions.failedToProcess(errorMessage: message))
//                }
//            }
//        }
//    }
//
//}

class SaveNewMemberUseCase: MemberUseCase {
    
    public override func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .saving))
        
        let api : UserAPI = UserService.shared
        
        api.add_Users(realName: member.getName(), userName: member.get_userName(), completion: { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSaving))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Save", comment: "Failed to Save"), message: errorDescription)
                self.actionDispatcher.dispatch(MemberActions.failedToProcess(errorMessage: message))
            }
            
        })
        
        //
        //        if member.roles.contains(.driver) {
        //            WaylensClientS.shared.request(
        //                .addNewDriver(
        //                    email: member.email,
        //                    name: member.name,
        //                    phoneNumber: member.phoneNumber
        //                )
        //            ) { (result) in
        //                switch result {
        //                case .success(_):
        //                    self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSaving))
        //                case .failure(let error):
        //                    let errorDescription: String = error?.localizedDescription ?? ""
        //                    let message = ErrorMessage(title: NSLocalizedString("Failed to Save", comment: "Failed to Save"), message: errorDescription)
        //                    self.actionDispatcher.dispatch(MemberActions.failedToProcess(errorMessage: message))
        //                }
        //            }
        //
        //        } else {
        //            assert(member.email != nil, "Email is required when create not-driver member!")
        //            WaylensClientS.shared.request(
        //                .addNewMemberNotDriver(
        //                    email: member.email!,
        //                    name: member.name,
        //                    phoneNumber: member.phoneNumber,
        //                    role: member.roles.stringArrayValue
        //                )
        //            ) { (result) in
        //                switch result {
        //                case .success(_):
        //                    self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSaving))
        //                case .failure(let error):
        //                    let errorDescription: String = error?.localizedDescription ?? ""
        //                    let message = ErrorMessage(title: NSLocalizedString("Failed to Save", comment: "Failed to Save"), message: errorDescription)
        //                    self.actionDispatcher.dispatch(MemberActions.failedToProcess(errorMessage: message))
        //                }
        //            }
        //        }
    }
    
}
protocol SaveNewMemberUseCaseFactory {
    func makeSaveNewMemberUseCase() -> UseCase
}
