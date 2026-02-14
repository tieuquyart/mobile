//
//  Observers.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import RxSwift

class ObserverForMyFleet: Observer {

    weak var eventResponder: ObserverForMyFleetEventResponder? {
        willSet {
            if newValue == nil {
                stopObserving()
            }
        }
    }

    let state: Observable<MyFleetViewControllerState>
    var stateSubscription: Disposable?
    let disposeBag = DisposeBag()

    private var isObserving: Bool {
        if stateSubscription != nil {
            return true
        } else {
            return false
        }
    }

    // MARK: - Methods
    init(state: Observable<MyFleetViewControllerState>) {
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
        NotificationCenter.default.removeObserver(self)
        unsubscribeFromState()
    }

    func subscribeToState() {
        NotificationCenter.default.addObserver(self, selector: #selector(userSettingDidChange), name: NSNotification.Name.UserSetting.userProfileChange, object: nil)

        stateSubscription =
            state
                .map{$0.userProfile}
                .distinctUntilChanged()
                .subscribe(onNext: { [weak self] newProfile in
                    //change by thanh
                   self?.eventResponder?.received(newUserProfile: newProfile)
                })

        stateSubscription?.disposed(by: disposeBag)
    }

    func unsubscribeFromState() {
        stateSubscription?.dispose()
    }

}

//MARK: - Private

private extension ObserverForMyFleet {

    @objc func userSettingDidChange() {
//        if let userProfile = UserSetting.current.userProfile {
//            eventResponder?.received(newUserProfile: userProfile)
//        }
        
        if let userProfile = UserSetting.current.userProfile {
            eventResponder?.received(newUserProfile: userProfile)
        }
    }

}
