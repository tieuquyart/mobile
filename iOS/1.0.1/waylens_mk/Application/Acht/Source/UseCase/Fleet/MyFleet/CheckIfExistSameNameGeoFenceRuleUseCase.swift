//
//  CheckIfExistSameNameGeoFenceRuleUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class CheckIfExistSameNameGeoFenceRuleUseCase: UseCase {
    typealias Completion = (_ isExisted: Bool, _ error: Error?) -> ()

    let actionDispatcher: ActionDispatcher

    private let rule: GeoFenceRuleForEdit
    private let completion: Completion

    public init(rule: GeoFenceRuleForEdit, actionDispatcher: ActionDispatcher, completion: @escaping Completion) {
        self.rule = rule
        self.completion = completion
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        if let ruleName = rule.name {
            actionDispatcher.dispatch(ActivityIndicatingAction(state: .loading))

            WaylensClientS.shared.request(
                .geoFenceRuleList
            ) { (result) in
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))

                switch result {
                case .success(let value):
                    if let fenceRuleList = value["FenceRuleList"] as? [[String : Any]] {
                        if let existedSameNameRule = fenceRuleList.first(where: {($0["name"] as? String) == ruleName}) {
                            if (existedSameNameRule["fenceRuleID"] as? String) == self.rule.fenceRuleID {
                                self.completion(false, nil)
                            }
                            else {
                                self.completion(true, nil)
                            }
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
        else {
            self.completion(false, nil)
        }
    }

}

protocol CheckIfExistSameNameGeoFenceRuleUseCaseFactory {
    func makeCheckIfExistSameNameGeoFenceRuleUseCase(completion: @escaping CheckIfExistSameNameGeoFenceRuleUseCase.Completion) -> UseCase
}
