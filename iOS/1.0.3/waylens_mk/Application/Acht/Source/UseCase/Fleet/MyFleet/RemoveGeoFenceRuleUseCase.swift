//
//  RemoveGeoFenceRuleUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class RemoveGeoFenceRuleUseCase: UseCase {
    typealias Completion = () -> ()

    let actionDispatcher: ActionDispatcher

    private let fenceRuleID: String
    private let fence: GeoFence?
    private let completion: Completion

    public init(
        fenceRuleID: String,
        fence: GeoFence?,
        actionDispatcher: ActionDispatcher,
        completion: @escaping Completion
    ) {
        self.fenceRuleID = fenceRuleID
        self.fence = fence
        self.actionDispatcher = actionDispatcher
        self.completion = completion
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .removing))

        WaylensClientS.shared.request(
            .removeGeoFenceRule(fenceRuleID: fenceRuleID)
        ) { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneRemoving))

                if self.fence?.fenceRuleList.count == 1,
                    self.fence?.fenceRuleList.contains(self.fenceRuleID) == true,
                    let fenceId = self.fence?.fenceID
                {
                    WaylensClientS.shared.request(.removeGeoFence(fenceID: fenceId), completion: nil)
                }

                self.completion()
            case .failure(let error):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))

                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Remove", comment: "Failed to Remove"), message: errorDescription)

                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol RemoveGeoFenceRuleUseCaseFactory {
    func makeRemoveGeoFenceRuleUseCase(completion: @escaping RemoveGeoFenceRuleUseCase.Completion) -> UseCase
}
