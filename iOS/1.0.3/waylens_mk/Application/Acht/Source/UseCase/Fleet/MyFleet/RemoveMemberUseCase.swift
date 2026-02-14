//
//  RemoveMemberUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class RemoveMemberUseCase: MemberUseCase {
    
    public override func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .removing))
        let api : UserAPI = UserService()
        
        
        api.remove_Users(id: member.get_id(), completion: { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneRemoving))
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Remove", comment: "Failed to Remove"), message: errorDescription)
                self.actionDispatcher.dispatch(MemberActions.failedToProcess(errorMessage: message))
            }
            
        })
    
    }
    
}

protocol RemoveMemberUseCaseFactory {
    func makeRemoveMemberUseCase() -> UseCase
}
