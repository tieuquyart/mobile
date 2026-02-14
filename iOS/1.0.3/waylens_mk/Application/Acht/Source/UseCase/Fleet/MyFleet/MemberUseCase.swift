//
//  MemberUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

protocol MemberUseCaseProtocol: UseCase {
    var actionDispatcher: ActionDispatcher { get }
    var member: FleetMember { get }

    init(
        member: FleetMember,
        actionDispatcher: ActionDispatcher
    )
}

class MemberUseCase: MemberUseCaseProtocol {
    let actionDispatcher: ActionDispatcher
    internal let member: FleetMember

    required init(
        member: FleetMember,
        actionDispatcher: ActionDispatcher
        ) {
        self.actionDispatcher = actionDispatcher
        self.member = member
    }

    func start() {

    }
}
