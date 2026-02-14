//
//  ObserverForAddNewVehicle.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import RxSwift

class ObserverForAddNewVehicle: Observer {

    weak var eventResponder: ObserverForAddNewVehicleEventResponder? {
        willSet {
            if newValue == nil {
                stopObserving()
            }
        }
    }

    let state: Observable<AddNewVehicleViewControllerState>
    var stateSubscription: Disposable?
    var errorStateSubscription: Disposable?
    var selectedDriverSubscription: Disposable?
    var vehicleProfileSubscription: Disposable?
    let disposeBag = DisposeBag()

    private var isObserving: Bool {
        if stateSubscription != nil {
            return true
        } else {
            return false
        }
    }

    init(state: Observable<AddNewVehicleViewControllerState>) {
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
        subscribeToSelectedDriver()
        subscribeToVehicleProfile()
        subscribeToErrorMessages()
    }

    func stopObserving() {
        unsubscribeFromState()
        unsubscribeToSelectedDriver()
        unsubscribeToVehicleProfile()
        unsubscribeFromErrorMessages()
    }

    func subscribeToState() {
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

    func subscribeToSelectedDriver() {
        selectedDriverSubscription =
            state
                .map { $0.selectedDriver }
                .distinctUntilChanged()
                .subscribe(onNext: { [weak self] newSelectedDriver in
                    self?.eventResponder?.received(newSelectedDriver: newSelectedDriver)
                })

        selectedDriverSubscription?.disposed(by: disposeBag)
    }

    func subscribeToVehicleProfile() {
        vehicleProfileSubscription =
            state
                .map { $0.vehicleProfile }
                .distinctUntilChanged()
                .subscribe(onNext: { [weak self] newVehicleProfile in
                    self?.eventResponder?.received(newVehicleProfile: newVehicleProfile)
                })

        vehicleProfileSubscription?.disposed(by: disposeBag)
    }

    func unsubscribeFromState() {
        stateSubscription?.dispose()
    }

    func unsubscribeFromErrorMessages() {
        errorStateSubscription?.dispose()
    }

    func unsubscribeToSelectedDriver() {
        selectedDriverSubscription?.dispose()
    }

    func unsubscribeToVehicleProfile() {
        vehicleProfileSubscription?.dispose()
    }

}
