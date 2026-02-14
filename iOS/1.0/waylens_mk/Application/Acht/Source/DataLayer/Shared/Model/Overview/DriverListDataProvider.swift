//
//  DriverListDataProvider.swift
//  Acht
//
//  Created by forkon on 2019/9/26.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol DriverListDataProviderDelegate: AnyObject {
    func driverListDataProvider(_ driverListDataProvider: DriverListDataProvider, didUpdateVehicles vehicles: [Vehicle])
    func driverListDataProvider(_ driverListDataProvider: DriverListDataProvider, didUpdateDrivers drivers: [Driver])
    func fleetViewPageSize(size: Int32)
    func presentMsg(msg : String)
    func showProgress(value: Bool)
}

class DriverListDataProvider: NSObject {
    private lazy var autoUpdateLogic: AutoUpdateLogic = { [weak self] in
        let autoUpdateLogic = AutoUpdateLogic(updateBlock: {
            self?.fetchDrivers()
        })
        return autoUpdateLogic
    }()

    weak var delegate: DriverListDataProviderDelegate? = nil
    let api : FleetViewAPI = FleetViewService.shared

    private(set) var drivers: [Driver] = []
    var vehicles: [Vehicle] {
        return drivers.map{$0.vehicle}
    }
//    private var vehicles : [Vehicle] = []

    var isActive: Bool = false {
        didSet {
            autoUpdateLogic.isActive = isActive
        }
    }
}

//MARK: - Private

extension DriverListDataProvider {

    func fetchDrivers() {
        print("Fetch deriver")
        
        self.delegate?.showProgress(value: true)
        
        api.fleetview_page(completion: { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.showProgress(value: false)
            switch result {
            case .success(let value):
            
                ConstantMK.parseJson(dict: value) { success,msg in
                    if success{
                        if let data = value["data"] as? JSON {
                            if let records = data["records"] as? [JSON] {
                                
                                strongSelf.drivers = records.compactMap({Driver(records: $0)})
                                strongSelf.delegate?.driverListDataProvider(strongSelf, didUpdateDrivers: strongSelf.drivers)
                                strongSelf.delegate?.driverListDataProvider(strongSelf, didUpdateVehicles: strongSelf.vehicles)
                                if let pageSize = data["pages"] as? Int32{
                                    strongSelf.delegate?.fleetViewPageSize(size: pageSize)
                                }
                                
                            }
                        
                        }
                    }else{
                        strongSelf.delegate?.presentMsg(msg: msg)
                    }
                }
                            
            case .failure(_):
                print("thanh failure(_)")
                break
            }
        })
        
    }
    
    func getMoreDrivers(index: Int32, drivers: [Driver]) {
        self.drivers = drivers
        
        print("get more driver - start: \(self.drivers)")
        
        self.delegate?.showProgress(value: true)
        
        api.fleetview_page(index: index, pageSize: 10, completion: { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.showProgress(value: false)
            switch result {
            case .success(let value):
            
                ConstantMK.parseJson(dict: value) { success,msg in
                    if success{
                        if let data = value["data"] as? JSON {
                            if let records = data["records"] as? [JSON] {
                                strongSelf.drivers.append(contentsOf: records.compactMap({Driver(records: $0)}))
                                strongSelf.delegate?.driverListDataProvider(strongSelf, didUpdateDrivers: strongSelf.drivers)
                                strongSelf.delegate?.driverListDataProvider(strongSelf, didUpdateVehicles: strongSelf.vehicles)
                                if let pageSize = data["pages"] as? Int32{
                                    strongSelf.delegate?.fleetViewPageSize(size: pageSize)
                                }
                            }
                        
                        }
                    }else{
                        strongSelf.delegate?.presentMsg(msg: msg)
                    }
                }
            case .failure(_):
                print("thanh failure(_)")
                break
            }
        })
        
    }
    
    private func updateDriversStatus() {
        
       
        
        WaylensClientS.shared.fetchVehiclesLastLocation { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .success(let value):
                if let cameras = value["cameras"] as? [[String : Any]] {
                    cameras.forEach({ (camera) in
                        let driver = strongSelf.drivers.first(where: { (d) -> Bool in
                            return d.id == (camera["driverID"] as? String)
                        })
                        driver?.updateStatus(with: camera)
                    })

                    strongSelf.delegate?.driverListDataProvider(strongSelf, didUpdateDrivers: strongSelf.drivers)
                    strongSelf.delegate?.driverListDataProvider(strongSelf, didUpdateVehicles: strongSelf.vehicles)
                }
            case .failure(_):
                break
            }
        }

    }

}
