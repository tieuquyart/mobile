//
//  LocationPickerActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum LocationPickerActions: Action {
    case locationSearchComplete(searchResults: [NamedLocation])
    case locationSelected(NamedLocation)
}

struct LocationPickerFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
