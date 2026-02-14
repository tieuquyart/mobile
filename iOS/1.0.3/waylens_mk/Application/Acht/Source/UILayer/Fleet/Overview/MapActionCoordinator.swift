//
//  MapActionCoordinator.swift
//  Acht
//
//  Created by forkon on 2019/9/26.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import MapKit
import FloatingPanel

class MapActionCoordinator {

    private lazy var floatingPanelController: MapFloatingPanelController = { [weak self] in
        let floatingPanelController = MapFloatingPanelController()
        floatingPanelController.actionCoordinator = self
        return floatingPanelController
    }()

    private lazy var driverListVC: DriverListViewController = {
        return UIStoryboard(name: "Overview", bundle: nil).instantiateViewController(withIdentifier: "DriverListViewController") as! DriverListViewController
    }()

    private var pinsManager: MapPinsManager? {
        return overviewViewController?.pinsManager
    }

    private var overlayManager: MapOverlayManager? {
        return overviewViewController?.overlayManager
    }

    weak var overviewViewController: OverviewViewController? = nil

    var mapViewDelegate: MKMapViewDelegate? {
        return floatingPanelController.lastSubPanel as? MKMapViewDelegate
    }

    var mapView: MKMapView? {
        return overviewViewController?.mapView
    }

    var isFloatingPanelAdded: Bool {
        if floatingPanelController.contentViewController == nil && floatingPanelController.parent == nil {
            return false
        }
        return true
    }


    deinit {
        debugPrint("\(self) deinit")
    }

    func updateFloatingPanelLayout() {
        floatingPanelController.updateLayout()
    }

    func handleUserTouchInMapView() {
        floatingPanelController.lastSubPanel?.userNeverTouchedMap = false
        floatingPanelController.lastSubPanel?.currentRegion = mapView?.region
    }
    
    
    
    private func handleSurface() {
    
        switch floatingPanelController.position {
        case .tip:
            floatingPanelController.move(to: .full, animated: true)
        default:
            floatingPanelController.move(to: .tip, animated: true)
        }
    }
    
    func presentDriverList(animated: Bool = true) {
        guard let overviewViewController = overviewViewController else {
            return
        }
        
         
        floatingPanelController.setInitialSubPanel(driverListVC)
      //  floatingPanelController.track(scrollView: driverListVC.tableView) // disable scrollview driverListVC tableview -doanvt 08/03/2023
        floatingPanelController.addPanel(toParent: overviewViewController, animated: animated)
    }
    
    

    func presentDetail(of driver: Driver) {
        let ddvc = DriverPanelViewController(driver: driver)
        floatingPanelController.presentSubPanel(ddvc)
    }

    func presentDetail(of event: Event) {
        let ddvc = EventPanelViewController(event: event)
        floatingPanelController.presentSubPanel(ddvc)
    }

    func goBack() {
        floatingPanelController.popLastSubPanel()
    }

    func updateNavigationBar() {
        if floatingPanelController.canPopSubPanel {
            overviewViewController?.showGoBackButton()
        } else {
            overviewViewController?.hideGoBackButton()
        }

        if let lastSubPanelTitle = floatingPanelController.lastSubPanel?.title {
            overviewViewController?.initHeader(text: lastSubPanelTitle, leftButton: false)
        }
    }

    func updateMapViewLayoutMargins() {
        mapView?.layoutMargins = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: floatingPanelController.lastSubPanel?.floatingPanelLayout.insetFor(position: .tip) ?? 0.0,
            right: 0.0
        )
    }
    
}

//MARK: - MapActionCoordination

extension MapActionCoordinator: MapActionCoordination {

    func viewController(_ viewController: UIViewController, showDetailOf driver: Driver) {
        presentDetail(of: driver)
    }

    func viewController(_ viewController: UIViewController, showDetailOf event: Event) {
        presentDetail(of: event)
    }

    func viewController(_ viewController: UIViewController, dropPinsForVehicles vehicles: [Vehicle]) {
        let subPanelController = viewController as? MapFloatingSubPanelController

        if subPanelController?.isActive == false {
            return
        }

        pinsManager?.clearVehiclePins()
        pinsManager?.setVehiclePins(from: vehicles)

        if subPanelController?.userNeverTouchedMap == true {
            mapView?.updateRegionToShowAllAnnotationsAndOverlays()
        } else {
            if let currentRegion = subPanelController?.currentRegion {
                mapView?.setRegion(currentRegion, animated: true)
            }
        }
    }

    func viewController(_ viewController: UIViewController, dropPinsForEvents events: [Event]) {
        let subPanelController = viewController as? MapFloatingSubPanelController

        if subPanelController?.isActive == false {
            return
        }

        pinsManager?.removeAllEventPins()
         pinsManager?.setEventPins(from: events)

        if subPanelController?.userNeverTouchedMap == true {
            mapView?.updateRegionToShowAllAnnotationsAndOverlays()
        } else {
            if let currentRegion = subPanelController?.currentRegion {
                mapView?.setRegion(currentRegion, animated: true)
            }
        }
    }

    func viewController(_ viewController: UIViewController, drawTrackFor trip: Trip) {
        let subPanelController = viewController as? MapFloatingSubPanelController

        if subPanelController?.isActive == false {
            return
        }

        overlayManager?.drawTrack(for: trip)

        if let track = trip.track {
            pinsManager?.setTrackEndpointPins(from: track, isFinish: false/*trip.isFinish*/)
        }

        if subPanelController?.userNeverTouchedMap == true {
            mapView?.updateRegionToShowAllAnnotationsAndOverlays()
        } else {
            if let currentRegion = subPanelController?.currentRegion {
                mapView?.setRegion(currentRegion, animated: true)
            }
        }
    }

    func viewController(_ viewController: UIViewController, drawTracksFor trips: [Trip]) {
        let subPanelController = viewController as? MapFloatingSubPanelController

        if subPanelController?.isActive == false {
            return
        }
        
        overlayManager?.drawTracks(for: trips)

        trips.forEach { (trip) in
            if let track = trip.track {
                pinsManager?.setTrackEndpointPins(from: track, isFinish: false/*trip.isFinish*/)
            }
        }

        if subPanelController?.userNeverTouchedMap == true {
            mapView?.updateRegionToShowAllAnnotationsAndOverlays()
        } else {
            if let currentRegion = subPanelController?.currentRegion {
                mapView?.setRegion(currentRegion, animated: true)
            }
        }
    }

    func viewController(_ viewController: UIViewController, removeTrackFor trip: Trip) {
        overlayManager?.removeTrack(for: trip)

        if let track = trip.track {
            pinsManager?.removeTrackEndpointPins(for: track)
        }

        let subPanelController = viewController as? MapFloatingSubPanelController

        if subPanelController?.userNeverTouchedMap == true {
            mapView?.updateRegionToShowAllAnnotationsAndOverlays()
        } else {
            if let currentRegion = subPanelController?.currentRegion {
                mapView?.setRegion(currentRegion, animated: true)
            }
        }
    }

    func viewControllerWillPresent(_ viewController: UIViewController) {
        guard let mapView = mapView else {
            return
        }

        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }

}
