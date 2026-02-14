//
//  ComposingProfileInfoUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ComposingProfileInfoUseCase: UseCase {

    let actionDispatcher: ActionDispatcher
    let profileInfoType: ProfileInfoType

    public init(
        memberProfileInfoType: ProfileInfoType,
        actionDispatcher: ActionDispatcher
        ) {
        self.profileInfoType = memberProfileInfoType
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ProfileActions.composingProfileInfo(profileInfoType))
    }

}

protocol ComposingMemberProfileInfoUseCaseFactory {
    func makeComposingMemberProfileInfoUseCase(profileInfoType: ProfileInfoType) -> UseCase
}
