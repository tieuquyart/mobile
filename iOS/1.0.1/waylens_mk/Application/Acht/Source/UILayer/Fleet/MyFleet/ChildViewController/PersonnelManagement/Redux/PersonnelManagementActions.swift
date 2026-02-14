//
//  PersonnelManagementActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum PersonnelManagementActions: Action {
    case loadMembers([FleetMember])
}

struct PersonnelManagementFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
