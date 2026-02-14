//
//  ObserverForMaintenance.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import RxSwift

class ObserverForMaintenance: Observer {

    weak var eventResponder: ObserverForMaintenanceEventResponder? {
        willSet {
            if newValue == nil {
                stopObserving()
            }
        }
    }

    let state: Observable<MaintenanceViewControllerState>
    var stateSubscription: Disposable?
    var errorStateSubscription: Disposable?
    let disposeBag = DisposeBag()

    private var isObserving: Bool {
        if stateSubscription != nil {
            return true
        } else {
            return false
        }
    }

    init(state: Observable<MaintenanceViewControllerState>) {
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
        subscribeToErrorMessages()
    }

    func stopObserving() {
        unsubscribeFromState()
        unsubscribeFromErrorMessages()
    }

    func subscribeToState() {
        NotificationCenter.default.addObserver(self, selector: #selector(userSettingDidChange), name: NSNotification.Name.UserSetting.debugEnabledChange, object: nil)

        stateSubscription =
            state
                .distinctUntilChanged()
                .subscribe(onNext: { [weak self] newState in
                    self?.eventResponder?.received(newState: newState)
                })

        stateSubscription?.disposed(by: disposeBag)
    }

    func subscribeToErrorMessages() {
        errorStateSubscription =
            state
                .map { $0.errorsToPresent.first }
                .ignoreNil()
                .distinctUntilChanged()
                .subscribe(onNext: { [weak self] errorMessage in
                    self?.eventResponder?.received(newErrorMessage: errorMessage)
                })

        errorStateSubscription?.disposed(by: disposeBag)
    }

    func unsubscribeFromState() {
        stateSubscription?.dispose()
    }

    func unsubscribeFromErrorMessages() {
        errorStateSubscription?.dispose()
    }

}

//MARK: - Private

private extension ObserverForMaintenance {

    @objc func userSettingDidChange() {
        // Add delays to avoid error: Simultaneous accesses to 0xxxxxxxx, but modification requires exclusive access.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            _ = self?.state.map{ $0 }
                .subscribe(onNext: { newState in
                    self?.eventResponder?.received(newState: newState)
                })
        }
    }

}
