//
//  NotificationListViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class NotificationListViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: NotificationListUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let loadNotificationListUseCaseFactory: LoadNotificationListUseCaseFactory
    private let applyDataFilterUseCaseFactory: ApplyDataFilterUseCaseFactory
    private let markNotificationsAsReadUseCaseFactory: MarkNotificationsAsReadUseCaseFactory

    init(
        observer: Observer,
        userInterface: NotificationListUserInterfaceView,
        loadNotificationListUseCaseFactory: LoadNotificationListUseCaseFactory,
        applyDataFilterUseCaseFactory: ApplyDataFilterUseCaseFactory,
        markNotificationsAsReadUseCaseFactory: MarkNotificationsAsReadUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.loadNotificationListUseCaseFactory = loadNotificationListUseCaseFactory
        self.applyDataFilterUseCaseFactory = applyDataFilterUseCaseFactory
        self.markNotificationsAsReadUseCaseFactory = markNotificationsAsReadUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Alerts", comment: "Alerts")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))

        observer.startObserving()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadNotificationListUseCaseFactory.makeLoadNotificationListUseCase().start()
    }

}

//MARK: - Private

private extension NotificationListViewController {

}

extension NotificationListViewController: NotificationListIxResponder {

    func select(indexPath: IndexPath) {

    }

    func showDetail(of event: DriverTimelineEvent) {
        if let driverID = event.driverID, let eventContent = event.content as? DriverTimelineCameraEventContent {
            HNMessage.show()
            WaylensClientS.shared.fetchEventDetail(driverID, clipID: eventContent.clipID) { [weak self] (result) in
                guard let strongSelf = self else {
                    return
                }

                switch result {
                case .success(let value):
                    HNMessage.dismiss()

                    if let data = value["data"] as? JSON {
                        if let eventData = try? JSONSerialization.data(withJSONObject: data, options: []),
                           let event = try? JSONDecoder().decode(Event.self, from: eventData){
                            let eventVC = EventDetailViewController(event: event)
                            strongSelf.navigationController?.pushViewController(eventVC, animated: true)
                        }
                    }
                case .failure(let error):
                    HNMessage.showError(message: error?.localizedDescription ?? NSLocalizedString("Unknown Error", comment: "Unknown Error"))
                }
            }
        }
    }

    func applyDataFilter(_ dataFilter: DataFilter) {
        applyDataFilterUseCaseFactory.makeApplyDataFilterUseCase(dataFilter: dataFilter).start()
    }

}

extension NotificationListViewController: ObserverForNotificationListEventResponder {

    func received(newState: NotificationListViewControllerState) {
        if !newState.dataSource.items.isEmpty {
            let notificationIDs = newState.dataSource.items.filter{!$0.isRead}.compactMap{$0.notificationID}

            if !notificationIDs.isEmpty {
                markNotificationsAsReadUseCaseFactory.makeMarkNotificationsAsReadUseCase(notificationIDs) { (success) in
                    if success {
                        AppIconBadge.setNumber(0)
                    }
                }
                .start()
            }
        }

        userInterface.render(newState: newState)
    }

    func received(newErrorMessage: ErrorMessage) {
        alert(title: newErrorMessage.title, message: newErrorMessage.message, action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { [weak self] (action) in
                self?.makeFinishedPresentingErrorUseCase(newErrorMessage).start()
            })
        })
    }
}

protocol NotificationListViewControllerFactory {

}
