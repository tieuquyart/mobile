//
//  LoadVehicleListUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class LoadVehicleListUseCase: UseCase {

    let actionDispatcher: ActionDispatcher

    public init(actionDispatcher: ActionDispatcher) {
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        actionDispatcher.dispatch(ActivityIndicatingAction(state: .loading))
        
//        VehicleService.shared.vehicle_by_page(completion: { (result) in
//            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))
//            switch result {
//            case .success(let value):
//                if let data = value["data"] as? JSON {
//                    if let vehicleInfos = data["records"] as? [JSON] {
//                        if let infoData = try? JSONSerialization.data(withJSONObject: vehicleInfos, options: []){
//                            do {
//                                let items = try JSONDecoder().decode([VehicleProfile].self, from: infoData)
//                                let list = VehicleListActions.loadVehicleList(items)
//                                self.actionDispatcher.dispatch(list)
//                            } catch let err {
//                                print("err get VehicleProfile",err)
//                            }
//                        }
//                    }
//                  
////                    if let vehicleInfos = data["records"] as? [JSON] {
////                        let listVehice = vehicleInfos.compactMap({ value in
////                            return
////
////                        })
////                        let list = VehicleListActions.loadVehicleList(vehicleInfos.compactMap{
////                            do {
////                                try JSONDecoder().decode(VehicleProfile.self, from: $0.jsonData ?? Data())
////                            } catch let err {
////
////                            }
////
////
////                        })
////                        self.actionDispatcher.dispatch(list)
////                    }
//                }
//               
//            case .failure(let error):
//                let errorDescription: String = error?.localizedDescription ?? ""
//                let message = ErrorMessage(title: NSLocalizedString("Failed to Load", comment: "Failed to Load"), message: errorDescription)
//                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
//            }
//
//        })
//
//        WaylensClientS.shared.request(.vehicleInfoList) { (result) in
//            self.actionDispatcher.dispatch(ActivityIndicatingAction(state: .none))
//
//            switch result {
//            case .success(let value):
//                if let vehicleInfos = value["vehicleInfos"] as? [[String : Any]] {
//                    self.actionDispatcher.dispatch(VehicleListActions.loadVehicleList(vehicleInfos.compactMap{try? JSONDecoder().decode(VehicleProfile.self, from: $0.jsonData ?? Data())}))
//                }
//            case .failure(let error):
//                let errorDescription: String = error?.localizedDescription ?? ""
//                let message = ErrorMessage(title: NSLocalizedString("Failed to Load", comment: "Failed to Load"), message: errorDescription)
//                self.actionDispatcher.dispatch(ErrorActions.failedToProcess(errorMessage: message))
//            }
//        }

    }

}

protocol LoadVehicleListUseCaseFactory {
    func makeLoadVehicleListUseCase() -> UseCase
}
