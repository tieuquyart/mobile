//
//  MapPinsManager.swift
//  Fleet
//
//  Created by forkon on 2019/9/26.
//  Copyright © 2019 waylens. All rights reserved.
//

import MapKit

class MapPinsManager {

    private var vehiclePins: [VehicleAnnotation] {
        return (mapView?.annotations.filter{$0 is VehicleAnnotation} as? [VehicleAnnotation]) ?? []
    }

    private weak var mapView: MKMapView? = nil

    init(mapView: MKMapView) {
        self.mapView = mapView
    }

    func clearVehiclePins() {
        mapView?.removeAnnotations(vehiclePins)
    }

    func clearPins() {
        guard let mapView = mapView else {
            return
        }

        mapView.removeAnnotations(mapView.annotations)
    }

    func removeAllEventPins() {
        if let annotations = mapView?.annotations.filter({$0 is EventAnnotation}) {
            mapView?.removeAnnotations(annotations)
        }
    }

    func removeTrackEndpointPins(for track: Track) {
        guard let mapView = mapView else {
            return
        }

        let endpointAnnotations = mapView.annotations.filter{ (annotation) -> Bool in
            if let annotation = annotation as? TrackEndpointAnnotation, annotation.track?.owner?.tripId == track.owner?.tripId {
                return true
            }
            return false
        }

        mapView.removeAnnotations(endpointAnnotations)
    }

    func setVehiclePins(from vehicles: [Vehicle]) {
        guard let mapView = mapView else {
            return
        }

        guard !vehicles.isEmpty else {
            return
        }

        vehicles.forEach { (vehicle) in
            if let coordinate = vehicle.coordinate {
          //      print("thanh coordinate",coordinate)
                let annotation = VehicleAnnotation(vehicle: vehicle)
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
            }
        }
    }

    func setEventPins(from events: [Event]) {
        guard let mapView = mapView else {
            return
        }

        guard !events.isEmpty else {
            return
        }

        for event in events {
            if let coordinate = event.coordinate {
                let annotation = EventAnnotation(event: event)
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
            }
        }
    }

    func setTrackEndpointPins(from track: Track, isFinish: Bool) {
        guard let mapView = mapView else {
            return
        }

        let coordinates = track.coordinates

        guard !coordinates.isEmpty else {
            return
        }

        removeTrackEndpointPins(for: track)

        if let firstCoordinate = coordinates.first {
            let annotation = TrackEndpointAnnotation(track: track, type: .begin, isFinish: isFinish)
            annotation.coordinate = firstCoordinate
            mapView.addAnnotation(annotation)
        }
        
        if let endCoordinate = coordinates.last {
            let anotation = TrackEndpointAnnotation(track: track, type: .end, isFinish: isFinish)
            anotation.coordinate = endCoordinate
            mapView.addAnnotation(anotation)
        }

    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? VehicleAnnotation {
            return vehiclePinView(for: annotation)
        }
        else if let annotation = annotation as? EventAnnotation {
            return eventPinView(for: annotation)
        }
        else if let annotation = annotation as? TrackEndpointAnnotation {
            return trackEndpointPinView(for: annotation)
        }

        return nil
    }

}

//MARK: - Private

extension MapPinsManager {

    private func vehiclePinView(for annotation: VehicleAnnotation) -> VehiclePinAnnotationView {
        return VehiclePinAnnotationView(annotation: annotation)
    }

    private func eventPinView(for annotation: EventAnnotation) -> EventPinAnnotationView {
        return EventPinAnnotationView(annotation: annotation)
    }

    private func trackEndpointPinView(for annotation: TrackEndpointAnnotation) -> TrackEndpointAnnotationView {
        return TrackEndpointAnnotationView(annotation: annotation)
    }
}
