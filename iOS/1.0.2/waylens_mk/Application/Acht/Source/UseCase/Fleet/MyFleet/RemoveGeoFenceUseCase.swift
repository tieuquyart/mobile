//
//  RemoveGeoFenceRuleUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class RemoveGeoFenceUseCase: UseCase {
    typealias Completion = () -> ()

    let actionDispatcher: ActionDispatcher

    private let fenceID: GeoFenceId
    private let completion: Completion

    public init(
        fenceID: GeoFenceId,
        actionDispatcher: ActionDispatcher,
        completion: @escaping Completion
    ) {
        self.fenceID = fenceID
        self.actionDispatcher = actionDispatcher
        self.completion = completion
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .removing))

        WaylensClientS.shared.request(
            .removeGeoFence(fenceID: fenceID)
        ) { (result) in
            switch result {
            case .success(_):
                self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .doneRemoving))
                self.actionDispatcher.dispatch(GeoFenceListActions.deleteGeoFence(self.fenceID))
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

protocol RemoveGeoFenceUseCaseFactory {
    func makeRemoveGeoFenceUseCase(fenceID: GeoFenceId, completion: @escaping RemoveGeoFenceUseCase.Completion) -> UseCase
}
