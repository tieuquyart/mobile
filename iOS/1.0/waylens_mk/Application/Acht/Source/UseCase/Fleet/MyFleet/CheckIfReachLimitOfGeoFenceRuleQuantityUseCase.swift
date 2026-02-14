//
//  CheckIfReachLimitOfGeoFenceRuleQuantityUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class CheckIfReachLimitOfGeoFenceRuleQuantityUseCase: UseCase {
    typealias Completion = (_ isReached: Bool, _ error: Error?) -> ()

    let actionDispatcher: ActionDispatcher

    enum Config {
        static let maxGeoFenceRulesCanAdded = 32
    }

    private let completion: Completion

    public init(actionDispatcher: ActionDispatcher, completion: @escaping Completion) {
        self.completion = completion
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .loading))

        WaylensClientS.shared.request(
            .geoFenceRuleList
        ) { (result) in
            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))

            switch result {
            case .success(let value):
                if let fenceRuleList = value["FenceRuleList"] as? [[String : Any]] {
                    if fenceRuleList.count >= Config.maxGeoFenceRulesCanAdded {
                        self.completion(true, nil)
                    }
                    else {
                        self.completion(false, nil)
                    }
                }
            case .failure(let error):
                self.completion(false, error)
            }
        }
    }

}

protocol CheckIfReachLimitOfGeoFenceRuleQuantityUseCaseFactory {
    func makeCheckIfReachLimitOfGeoFenceRuleQuantityUseCase(completion: @escaping CheckIfReachLimitOfGeoFenceRuleQuantityUseCase.Completion) -> UseCase
}
