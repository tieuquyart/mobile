//
//  ObserverForMemberProfileInfoComposing.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import RxSwift

class ObserverForMemberProfileInfoComposing: Observer {

    weak var eventResponder: ObserverForMemberProfileInfoComposingEventResponder? {
        willSet {
            if newValue == nil {
                stopObserving()
            }
        }
    }

    let state: Observable<MemberProfileInfoComposingViewControllerState>
    var stateSubscription: Disposable?
    let disposeBag = DisposeBag()

    private var isObserving: Bool {
        if stateSubscription != nil {
            return true
        } else {
            return false
        }
    }

    init(state: Observable<MemberProfileInfoComposingViewControllerState>) {
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
        stateSubscription =
            state
                .distinctUntilChanged()
                .subscribe(onNext: { newProfile in

                })

        stateSubscription?.disposed(by: disposeBag)
    }

    func unsubscribeFromState() {
        stateSubscription?.dispose()
    }
}
