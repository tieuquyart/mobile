//
//  UpdateMemberProfileUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

//class UpdateMemberProfileUseCase: MemberUseCase {
//
//    public override func start() {
//        actionDispatcher.dispatch(ActivityIndicatingAction(state: .updating))
//
//        if member.roles.contains(.driver) {
//            WaylensClientS.shared.request(
//                .editDriverProfile(
//                    driverID: member.driverID!,
//                    name: member.name,
//                    phoneNumber: member.phoneNumber,
//                    email: member.email
//                )
//            ) { (result) in
//                switch result {
//                case .success(_):
//                    self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneUpdating))
//                case .failure(let error):
//                    if error?.code != 4008 { // Ignore email error, because we cannot change email if it was existed.
//                        let errorDescription: String = error?.localizedDescription ?? ""
//                        let message = ErrorMessage(title: NSLocalizedString("Failed to Update", comment: "Failed to Update"), message: errorDescription)
//                        self.actionDispatcher.dispatch(MemberActions.failedToProcess(errorMessage: message))
//                    } else {
//                        self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneUpdating))
//                    }
//                }
//            }
//        } else {
//            WaylensClientS.shared.request(
//                .editMemberNotDriverProfile(
//                    email: member.email!,
//                    name: member.name,
//                    phoneNumber: member.phoneNumber,
//                    role: member.roles.stringArrayValue
//                )
//            ) { (result) in
//                switch result {
//                case .success(_):
//                    self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneUpdating))
//                case .failure(let error):
//                    let errorDescription: String = error?.localizedDescription ?? ""
//                    let message = ErrorMessage(title: NSLocalizedString("Failed to Update", comment: "Failed to Update"), message: errorDescription)
//                    self.actionDispatcher.dispatch(MemberActions.failedToProcess(errorMessage: message))
//                }
//            }
//
//        }
//    }
//
//}

class UpdateMemberProfileUseCase: MemberUseCase {

    public override func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .updating))

        let api : UserAPI = UserService.shared
        
        api.update_Users(id: member.get_id(), realName: member.getName(), userName: member.get_userName(), completion: { (result) in
            switch result {
                           case .success(_):
                               self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneUpdating))
                           case .failure(let error):
                               if error?.code != 4008 { // Ignore email error, because we cannot change email if it was existed.
                                   let errorDescription: String = error?.localizedDescription ?? ""
                                   let message = ErrorMessage(title: NSLocalizedString("Failed to Update", comment: "Failed to Update"), message: errorDescription)
                                   self.actionDispatcher.dispatch(MemberActions.failedToProcess(errorMessage: message))
                               } else {
                                   self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneUpdating))
                               }
                           }
        })
        
//        api.add_Users(realName: member.getName(), userName: member.get_userName(), completion: { (result) in
//            switch result {
//            case .success(_):
//                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneSaving))
//            case .failure(let error):
//                let errorDescription: String = error?.localizedDescription ?? ""
//                let message = ErrorMessage(title: NSLocalizedString("Failed to Save", comment: "Failed to Save"), message: errorDescription)
//                self.actionDispatcher.dispatch(MemberActions.failedToProcess(errorMessage: message))
//            }
//
//        })
    }

}

protocol UpdateMemberProfileUseCaseFactory {
    func makeUpdateMemberProfileUseCase() -> UseCase
}
