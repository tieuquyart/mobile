//
//  LoadNotificationListUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class LoadNotificationListUseCase: UseCase {
    let actionDispatcher: ActionDispatcher
    private let dateRange: DateRange

    public init(dateRange: DateRange, actionDispatcher: ActionDispatcher) {
        self.dateRange = dateRange
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .loading))
        
        let registrationId = JPush.shared().registrationID ?? ""
        
        NotificationServiceMK.shared.bindPushDevice(device: "ios", registrationId: registrationId, completion: { (result) in
            print("result",result)
        })
//        print("notificationId thanh",registrationId)
        
//        let startTime = dateRange.from.toString(format: .isoDate)
//        
//        let endTime = dateRange.to.toString(format: .isoDate)
//        
//        NotificationServiceMK.shared.user_notification_list(notificationId: registrationId , markRead: "", fromTime: startTime, toTime: endTime) { (result) in
//            print("result notification",result)
//        }

        

//        WaylensClientS.shared.request(
//            .notificationList(
//                from: Int64(dateRange.from.millisecondsSince1970),
//                to: Int64(dateRange.to.millisecondsSince1970)
//            )
//        ) { (result) in
//            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))
//
//            switch result {
//            case .success(let respose):
//                var notifications: [DriverTimelineEvent] = []
//                if let notificationDicts = respose["notifications"] as? [[String : Any]] {
//                    notificationDicts.forEach({ (notificationDict) in
//                        if let notification = try? JSONDecoder().decode(DriverTimelineEvent.self, from: notificationDict.jsonData ?? Data()) {
//                            notifications.append(notification)
//                        }
//                    })
//                }
//
//                notifications.sort{$0.time > $1.time}
//
//                self.actionDispatcher.dispatch(NotificationListActions.loadNotificationList(notifications))
//            case .failure(let error):
//                let errorDescription: String = error?.localizedDescription ?? ""
//                let message = ErrorMessage(title: NSLocalizedString("Failed to Load", comment: "Failed to Load"), message: errorDescription)
//                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
//            }
//        }
    }

}

protocol LoadNotificationListUseCaseFactory {
    func makeLoadNotificationListUseCase() -> UseCase
}
