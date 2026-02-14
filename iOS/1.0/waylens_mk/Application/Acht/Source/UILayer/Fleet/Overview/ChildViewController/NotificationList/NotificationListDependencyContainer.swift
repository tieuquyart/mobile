//
//  NotificationListDependencyContainer.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class NotificationListDependencyContainer {

    let stateStore: ReSwift.Store<NotificationListViewControllerState> = {
        return ReSwift.Store(reducer: Reducers.NotificationListReducer, state: NotificationListViewControllerState())
    }()

    var actionDispatcher: ActionDispatcher {
        return stateStore as ActionDispatcher
    }

    init() {

    }

    func makeNotificationListViewController() -> NotificationListViewController {
        let stateObservable = makeNotificationListViewControllerStateObservable()
        let observer = ObserverForNotificationList(state: stateObservable)
        let userInterface = NotificationListRootView()
        let viewController = NotificationListViewController(
            observer: observer,
            userInterface: userInterface,
            loadNotificationListUseCaseFactory: self,
            applyDataFilterUseCaseFactory: self,
            markNotificationsAsReadUseCaseFactory: self,
            makeFinishedPresentingErrorUseCase: makeFinishedPresentingErrorUseCase
        )
        observer.eventResponder = viewController
        userInterface.ixResponder = viewController
        return viewController
    }

}

//MARK: - Private

private extension NotificationListDependencyContainer {

    func makeNotificationListViewControllerStateObservable() -> Observable<NotificationListViewControllerState> {
        return stateStore.makeObservable()
    }

}

//MARK: - View Controller Factory

extension NotificationListDependencyContainer: NotificationListViewControllerFactory {


}

//MARK: - Use Case

extension NotificationListDependencyContainer {

    func makeFinishedPresentingErrorUseCase(
        errorMessage: ErrorMessage
        ) -> UseCase {
        let actionDispatcher = self.actionDispatcher

        let useCase = FinishedPresentingErrorUseCase<NotificationListFinishedPresentingErrorAction>(errorMessage: errorMessage, actionDispatcher: actionDispatcher)
        return useCase
    }

}

extension NotificationListDependencyContainer: LoadNotificationListUseCaseFactory {

    func makeLoadNotificationListUseCase() -> UseCase {
        return LoadNotificationListUseCase(
            dateRange: DateRange.rangeUsingInNotificationList,
            actionDispatcher: actionDispatcher
        )
    }

}

extension NotificationListDependencyContainer: ApplyDataFilterUseCaseFactory {

    func makeApplyDataFilterUseCase(dataFilter: DataFilter) -> UseCase {
        return ApplyDataFilterUseCase(dataFilter: dataFilter, actionDispatcher: actionDispatcher)
    }

}

extension NotificationListDependencyContainer: MarkNotificationsAsReadUseCaseFactory {

    func makeMarkNotificationsAsReadUseCase(_ notificationIDs: [String], completion: @escaping (Bool) -> Void) -> UseCase {
        return MarkNotificationsAsReadUseCase(notificationIDs: notificationIDs, completion: completion)
    }

}
