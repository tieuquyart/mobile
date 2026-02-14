//
//  ObserverForMyFleetSettings.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import RxSwift

class ObserverForMyFleetSettings: Observer {

    weak var eventResponder: ObserverForMyFleetSettingsEventResponder? {
        willSet {
            if newValue == nil {
                stopObserving()
            }
        }
    }

    let state: MyFleetSettingsViewControllerState
    var stateSubscription: Disposable?
    let disposeBag = DisposeBag()

    private var isObserving: Bool {
        if stateSubscription != nil {
            return true
        } else {
            return false
        }
    }

    init(state: MyFleetSettingsViewControllerState) {
        self.state = state
    }

    func startObserving() {
        assert(self.eventResponder != nil)

        guard let _ = self.eventResponder else {
            return
        }

        if isObserving {
            return
        }

        subscribeToState()
    }

    func stopObserving() {
        unsubscribeFromState()
    }

    func subscribeToState() {
        NotificationCenter.default.addObserver(self, selector: #selector(userSettingDidChange), name: NSNotification.Name.UserSetting.debugEnabledChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userSettingDidChange), name: NSNotification.Name.UserSetting.userProfileChange, object: nil)

        eventResponder?.transitionToNew(state: state)
    }

    func unsubscribeFromState() {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Private

private extension ObserverForMyFleetSettings {

    @objc func userSettingDidChange() {
        eventResponder?.transitionToNew(state: state)
    }

}
