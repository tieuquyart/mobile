//
//  MemberActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum MemberActions: Action {
    case loadMemberProfile
    case beginEditingMemberProfile
    case doneEditingMemberProfile
    case saveNewMember
    case failedToProcess(errorMessage: ErrorMessage)
    case transferFleet
}

struct MemberFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
