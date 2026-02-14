//
//  MapOverlayManager.swift
//  Fleet
//
//  Created by forkon on 2019/9/28.
//  Copyright © 2019 waylens. All rights reserved.
//

import MapKit

class MapOverlayManager {

    private weak var mapView: MKMapView? = nil

    init(mapView: MKMapView) {
        self.mapView = mapView
    }

    func drawTracks(for trips: [Trip]) {
        trips.forEach { (trip) in
            drawTrack(for: trip)
        }
    }

    func drawTrack(for trip: Trip) {
        guard let mapView = mapView, let track = trip.track else {
            return
        }

        removeTrack(for: trip)

        let coordinates = track.coordinates

        guard !coordinates.isEmpty else {
            return
        }
        
        
//        var myRoute : MKRoute?
//        let directionsRequest = MKDirections.Request()
//        var placemarks = [MKMapItem]()
//        
//        
//        for item in coordinates {
//            let placemark = MKPlacemark(coordinate: item ,  addressDictionary: nil)
//            placemarks.append(MKMapItem(placemark: placemark))
//        }
//
//        directionsRequest.transportType = MKDirectionsTransportType.automobile
        
        
        var polyline = TrackPolyline(track: track)
        
        
//        for (k, item) in placemarks.enumerated() {
//                if k < (placemarks.count - 1) {
//                    directionsRequest.source = item
//                    directionsRequest.destination = placemarks[k+1]
//
//                    let directions = MKDirections(request: directionsRequest)
//                    directions.calculate { response, error in
//                        if error == nil {
//                            myRoute = response?.routes[0] as? MKRoute
//
//                            let polylineTrack = myRoute!.polyline
//                            polyline = polylineTrack as! TrackPolyline
//
//
//
//                            if let last = mapView.overlays.last {
//                                mapView.insertOverlay(polyline, below: last)
//                            } else {
//                                mapView.addOverlay(polyline, level: .aboveRoads)
//                            }
//
//                        }
//                    }
//                }
//            }
 
     
//
        if let lastTrackPolylineOnMap = mapView.overlays.last as? TrackPolyline {


                mapView.insertOverlay(polyline, below: lastTrackPolylineOnMap)
        } else {
            mapView.addOverlay(polyline, level: .aboveRoads)
        }
    }

    func removeTrack(for trip: Trip) {
        guard let track = trip.track else {
            return
        }

        removePolyline(for: track)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = TrackRenderer(overlay: overlay)
        return renderer
    }
    
}

//MARK: - Private

extension MapOverlayManager {

    private func removePolyline(for track: Track) {
        guard let mapView = mapView else {
            return
        }

        let polylines = mapView.overlays.filter { (overlay) -> Bool in
            if let trackPolyline = overlay as? TrackPolyline, trackPolyline.track?.owner?.tripId == track.owner?.tripId {
                return true
            }
            return false
        }

        mapView.removeOverlays(polylines)
    }

}
