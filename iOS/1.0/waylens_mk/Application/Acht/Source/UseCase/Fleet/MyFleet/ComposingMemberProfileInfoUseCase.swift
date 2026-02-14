//
//  ComposingMemberProfileInfoUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ComposingProfileInfoUseCase: UseCase {

    let actionDispatcher: ActionDispatcher
    let memberProfileInfoType: ProfileInfoType

    public init(
        memberProfileInfoType: ProfileInfoType,
        actionDispatcher: ActionDispatcher
        ) {
        self.memberProfileInfoType = memberProfileInfoType
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(MemberActions.composingMemberProfileInfo(memberProfileInfoType))
    }

}

protocol ComposingMemberProfileInfoUseCaseFactory {
    func makeComposingMemberProfileInfoUseCase(memberProfileInfoType: ProfileInfoType) -> UseCase
}
