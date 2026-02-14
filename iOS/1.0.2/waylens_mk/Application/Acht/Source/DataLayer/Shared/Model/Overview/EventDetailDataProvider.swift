//
//  EventDetailDataProvider.swift
//  Fleet
//
//  Created by forkon on 2019/9/28.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol EventDetailDataProviderDelegate: AnyObject {
    func eventDetailDataProvider(_ eventDetailDataProvider: EventDetailDataProvider, didFetchDetailOf event: Event)
}

class EventDetailDataProvider {
    weak var delegate: EventDetailDataProviderDelegate? = nil

    func fetchDetail(of event: Event) {
        guard !event.id.isEmpty else {
            return
        }

        WaylensClientS.shared.fetchEventDetail("\(event.driverId ?? 0)", clipID: event.clipId ?? "") { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .success(let value):
//                event.update(with: value)
                if let data = value["data"] as? JSON {
                    if let eventData = try? JSONSerialization.data(withJSONObject: data, options: []),
                       let event = try? JSONDecoder().decode(Event.self, from: eventData){
                        strongSelf.delegate?.eventDetailDataProvider(strongSelf, didFetchDetailOf: event)
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
}
