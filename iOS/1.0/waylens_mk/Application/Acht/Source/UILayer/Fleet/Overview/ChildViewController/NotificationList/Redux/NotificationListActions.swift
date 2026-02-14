//
//  NotificationListActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum NotificationListActions: Action {
    case loadNotificationList([DriverTimelineEvent])
}

struct NotificationListFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
