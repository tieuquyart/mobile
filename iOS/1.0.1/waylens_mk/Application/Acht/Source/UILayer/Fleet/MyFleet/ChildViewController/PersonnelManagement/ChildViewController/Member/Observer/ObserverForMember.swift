//
//  ObserverForMember.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import RxSwift

class ObserverForMember: Observer {

    weak var eventResponder: ObserverForMemberEventResponder? {
        willSet {
            if newValue == nil {
                stopObserving()
            }
        }
    }

    let state: Observable<MemberViewControllerState>
    var profileStateSubscription: Disposable?
    var errorStateSubscription: Disposable?
    let disposeBag = DisposeBag()

    private var isObserving: Bool {
        if profileStateSubscription != nil {
            return true
        } else {
            return false
        }
    }

    init(state: Observable<MemberViewControllerState>) {
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

        subscribeToProfileState()
        subscribeToErrorMessages()
    }

    func stopObserving() {
        unsubscribeFromState()
        unsubscribeFromErrorMessages()
    }

    func subscribeToProfileState() {
        profileStateSubscription =
            state
                .distinctUntilChanged()
                .subscribe(onNext: { [weak self] newState in
                    self?.eventResponder?.received(newState: newState)
                })

        profileStateSubscription?.disposed(by: disposeBag)
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
        profileStateSubscription?.dispose()
    }

    func unsubscribeFromErrorMessages() {
        errorStateSubscription?.dispose()
    }

}
