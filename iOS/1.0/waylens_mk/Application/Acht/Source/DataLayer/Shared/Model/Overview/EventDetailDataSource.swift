//
//  EventDetailDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/9/28.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol EventDetailDataSourceDelegate: class {
    func dataSource(_ eventDetailDataSource: EventDetailDataSource, didUpdate event: Event)
}

class EventDetailDataSource {
    private lazy var dataProvider: EventDetailDataProvider = { [weak self] in
        let dataProvider = EventDetailDataProvider()
        dataProvider.delegate = self
        return dataProvider
    }()

    private weak var event: Event? = nil

    weak var delegate: EventDetailDataSourceDelegate? = nil
    private(set) var isFetching: Bool = false

    init(event: Event) {
        self.event = event

        isFetching = true
        dataProvider.fetchDetail(of: event)
    }
}

extension EventDetailDataSource: EventDetailDataProviderDelegate {

    func eventDetailDataProvider(_ eventDetailDataProvider: EventDetailDataProvider, didFetchDetailOf event: Event) {
        isFetching = false
        delegate?.dataSource(self, didUpdate: event)
    }

}
