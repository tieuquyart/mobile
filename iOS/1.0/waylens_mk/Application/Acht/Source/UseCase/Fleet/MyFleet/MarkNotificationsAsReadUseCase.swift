//
//  MarkNotificationsAsReadUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class MarkNotificationsAsReadUseCase: UseCase {
    typealias CompletionHandler = (_ success: Bool) -> Void
    private let completion: CompletionHandler
    private let notificationIDs: [String]

    public init(notificationIDs: [String], completion: @escaping CompletionHandler) {
        self.notificationIDs = notificationIDs
        self.completion = completion
    }

    public func start() {
        WaylensClientS.shared.request(
            .markNotificationsAsRead(notificationIDs: notificationIDs)
        ) { (result) in
            switch result {
            case .success(let response):
                self.completion((response["result"] as? Bool) ?? false)
            case .failure(_):
                self.completion(false)
            }
        }
    }

}

protocol MarkNotificationsAsReadUseCaseFactory {
    func makeMarkNotificationsAsReadUseCase(_ notificationIDs: [String], completion: @escaping MarkNotificationsAsReadUseCase.CompletionHandler) -> UseCase
}
