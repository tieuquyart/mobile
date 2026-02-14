//
//  DoNothingUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class DoNothingUseCase: UseCase {

    public init() {
    }

    public func start() {

    }

}

protocol DoNothingUseCaseFactory {
    func makeDoNothingUseCase() -> UseCase
}
