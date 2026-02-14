//
//  FetchBillingDataUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class FetchHistoricalBillingDataUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .loading))

        WaylensClientS.shared.request(
            .historicalBillingData
        ) { (result) in
            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))

            switch result {
            case .success(let response):
                if let billings = response["billings"] as? [[String : Any]] {
                    var billingDataArray: [BillingData] = []

                    billings.forEach({ (billing) in
                        if let billingData = try? JSONDecoder().decode(BillingData.self, from: billing.jsonData ?? Data()) {
                            billingDataArray.append(billingData)
                        }
                    })

                    billingDataArray.sort{$0.cycleEndDate > $1.cycleEndDate}

                    self.actionDispatcher.dispatch(DataUsageActions.loadHistoricalBillingData(billingDataArray))
                }
            case .failure(let error):
                let errorDescription: String = error?.localizedDescription ?? ""
                let message = ErrorMessage(title: NSLocalizedString("Failed to Load", comment: "Failed to Load"), message: errorDescription)
                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
            }
        }
    }

}

protocol FetchHistoricalBillingDataUseCaseFactory {
    func makeFetchHistoricalBillingDataUseCase() -> UseCase
}
